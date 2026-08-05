extends Node2D
## Popula a cidade após a grade ser gerada: vegetação, props de rua, NPCs e polícia.
##
## Ordem em `repopulate()`: árvores/arbustos → props → tráfego → polícia.
## Densidades usam `CityNoise` (árvores / tráfego por distrito).
## Filhos ficam em `Actors` (y-sort) para overdraw isométrico correto.
##
## Orçamento (`*_budget`) limita spawns para performance em mapas grandes.

const CityMath = preload("res://scripts/world/city_math.gd")
const CityNoiseScript = preload("res://scripts/world/city_noise.gd")
const AssetArt = preload("res://scripts/world/asset_art.gd")
const NPC_SCENE := preload("res://scenes/npc_car.tscn")
const POLICE_SCENE := preload("res://scenes/police_car.tscn")

@export var tree_budget: int = 140
@export var bush_budget: int = 60
@export var npc_budget: int = 28
@export var police_count: int = 3

var _city: CityGenerator
var _actors: Node2D


## Chamado por CityGenerator no fim de cada `generate()`.
func setup(city: CityGenerator) -> void:
	_city = city
	_actors = get_node_or_null("Actors") as Node2D
	if _actors == null:
		_actors = Node2D.new()
		_actors.name = "Actors"
		_actors.y_sort_enabled = true
		add_child(_actors)
	repopulate()


func clear_actors() -> void:
	if _actors == null:
		return
	for child in _actors.get_children():
		child.queue_free()


## Limpa e respawna tudo. Seed RNG derivada da cidade (determinístico).
func repopulate() -> void:
	if _city == null:
		return
	clear_actors()
	var rng := RandomNumberGenerator.new()
	rng.seed = _city.last_seed ^ 0xA17E
	_spawn_vegetation(rng)
	_spawn_street_props(rng)
	_spawn_npc_cars(rng)
	_spawn_police(rng)


## Vegetação nas bordas de prédios (junto à rua) e em parques.
func _spawn_vegetation(rng: RandomNumberGenerator) -> void:
	var city_noise: Variant = _city.get_noise()
	var stride := _city.block_size + _city.street_width
	var tree_spawned := 0
	var bush_spawned := 0

	var candidates: Array[Vector2i] = []
	for cell in _city.get_building_cells():
		if _touches_road(cell):
			candidates.append(cell)
	# Parques também recebem árvores.
	for y in _city.map_cells.y:
		for x in _city.map_cells.x:
			var cell := Vector2i(x, y)
			if _city.tile_map.get_cell_atlas_coords(cell) == CityMath.ATLAS_PARK:
				candidates.append(cell)

	candidates.shuffle()
	for cell in candidates:
		if tree_spawned >= tree_budget and bush_spawned >= bush_budget:
			break
		var block := Vector2i(int(cell.x / stride), int(cell.y / stride))
		var weight := 0.45
		if city_noise != null:
			weight = city_noise.tree_weight(float(block.x), float(block.y))
		if rng.randf() > weight:
			continue
		var pos: Vector2 = _city.tile_map.map_to_local(cell)
		pos += Vector2(rng.randf_range(-10, 10), rng.randf_range(-6, 6))
		if bush_spawned < bush_budget and rng.randf() < 0.35:
			_actors.add_child(_make_bush(rng, pos))
			bush_spawned += 1
		elif tree_spawned < tree_budget:
			_actors.add_child(_make_tree(rng, pos))
			tree_spawned += 1


## Props (hidrante, banco, cone, poste) só em células de rua que tocam prédio.
func _spawn_street_props(rng: RandomNumberGenerator) -> void:
	var roads := _collect_road_cells()
	roads.shuffle()
	var count := mini(40, roads.size())
	for i in count:
		if rng.randf() > 0.12:
			continue
		var cell: Vector2i = roads[i]
		if not _touches_building(cell):
			continue
		var pos: Vector2 = _city.tile_map.map_to_local(cell)
		_actors.add_child(_make_prop(rng, pos))


## NPCs civis — peso de spawn maior no downtown (`traffic_weight`).
func _spawn_npc_cars(rng: RandomNumberGenerator) -> void:
	var roads := _collect_road_cells()
	if roads.is_empty():
		return
	var city_noise: Variant = _city.get_noise()
	var stride := _city.block_size + _city.street_width
	var spawned := 0
	var attempts := 0
	while spawned < npc_budget and attempts < npc_budget * 8:
		attempts += 1
		var cell: Vector2i = roads[rng.randi_range(0, roads.size() - 1)]
		var block := Vector2i(int(cell.x / stride), int(cell.y / stride))
		var weight := 0.6
		if city_noise != null:
			weight = city_noise.traffic_weight(float(block.x), float(block.y))
		if rng.randf() > weight:
			continue
		var npc := NPC_SCENE.instantiate()
		_actors.add_child(npc)
		npc.global_position = _city.to_global(_city.tile_map.map_to_local(cell))
		if npc.has_method("setup"):
			npc.setup(_city, rng)
		spawned += 1


## Viaturas em células dirigíveis aleatórias (contagem fixa `police_count`).
func _spawn_police(rng: RandomNumberGenerator) -> void:
	var roads := _collect_road_cells()
	if roads.is_empty():
		return
	for i in police_count:
		var cell: Vector2i = roads[rng.randi_range(0, roads.size() - 1)]
		var cop := POLICE_SCENE.instantiate()
		_actors.add_child(cop)
		cop.global_position = _city.to_global(_city.tile_map.map_to_local(cell))
		if cop.has_method("setup"):
			cop.setup(_city, rng)


func _make_tree(rng: RandomNumberGenerator, pos: Vector2) -> Node2D:
	var root := Node2D.new()
	root.position = pos
	root.y_sort_enabled = true
	var sprite := AssetArt.make_sprite_node(
		AssetArt.SPRITE_TREE,
		AssetArt.TREE_PIXEL_HEIGHT * 0.85,
		AssetArt.TREE_PIXEL_HEIGHT
	)
	if sprite.texture != null:
		var h := float(sprite.texture.get_height())
		sprite.offset = Vector2(0.0, h * 0.35)
		sprite.position = Vector2.ZERO
		sprite.scale = Vector2.ONE * rng.randf_range(0.85, 1.15)
		root.add_child(sprite)
		return root
	# Fallback polygons
	var canopy := Polygon2D.new()
	var s := rng.randf_range(11.0, 18.0)
	canopy.color = Color(
		rng.randf_range(0.12, 0.25),
		rng.randf_range(0.50, 0.72),
		rng.randf_range(0.18, 0.34)
	)
	canopy.polygon = PackedVector2Array([
		Vector2(0, -s * 1.4),
		Vector2(s, -s * 0.2),
		Vector2(s * 0.5, s * 0.5),
		Vector2(-s * 0.5, s * 0.5),
		Vector2(-s, -s * 0.2),
	])
	var trunk := Polygon2D.new()
	trunk.color = Color(0.35, 0.22, 0.12)
	trunk.polygon = PackedVector2Array([
		Vector2(-2, 0), Vector2(2, 0), Vector2(2, 9), Vector2(-2, 9),
	])
	root.add_child(trunk)
	root.add_child(canopy)
	return root


func _make_bush(rng: RandomNumberGenerator, pos: Vector2) -> Node2D:
	var root := Node2D.new()
	root.position = pos
	var sprite := AssetArt.make_sprite_node(
		AssetArt.SPRITE_BUSH,
		AssetArt.PROP_PIXEL_HEIGHT,
		AssetArt.PROP_PIXEL_HEIGHT * 0.7
	)
	if sprite.texture != null:
		var h := float(sprite.texture.get_height())
		sprite.offset = Vector2(0.0, h * 0.3)
		sprite.scale = Vector2.ONE * rng.randf_range(0.75, 1.1)
		root.add_child(sprite)
		return root
	var bush := Polygon2D.new()
	var s := rng.randf_range(6.0, 10.0)
	bush.color = Color(0.16, 0.48, 0.24)
	bush.polygon = PackedVector2Array([
		Vector2(-s, 0), Vector2(-s * 0.3, -s), Vector2(s * 0.4, -s * 0.8),
		Vector2(s, 0), Vector2(0, s * 0.35),
	])
	root.add_child(bush)
	return root


func _make_prop(rng: RandomNumberGenerator, pos: Vector2) -> Node2D:
	var root := Node2D.new()
	root.position = pos
	var paths: Array[String] = [
		AssetArt.SPRITE_HYDRANT,
		AssetArt.SPRITE_BENCH,
		AssetArt.SPRITE_CONE,
		AssetArt.SPRITE_LAMP,
	]
	var path: String = paths[rng.randi_range(0, paths.size() - 1)]
	var max_h := AssetArt.PROP_PIXEL_HEIGHT
	if path == AssetArt.SPRITE_LAMP:
		max_h = 72.0
	elif path == AssetArt.SPRITE_BENCH:
		max_h = 36.0
	var sprite := AssetArt.make_sprite_node(path, max_h * 1.2, max_h)
	if sprite.texture != null:
		var h := float(sprite.texture.get_height())
		sprite.offset = Vector2(0.0, h * 0.35)
		sprite.position = Vector2.ZERO
		root.add_child(sprite)
		return root
	var body := Polygon2D.new()
	if rng.randf() < 0.5:
		body.color = Color(0.45, 0.3, 0.18)
		body.polygon = PackedVector2Array([
			Vector2(-8, -2), Vector2(8, -2), Vector2(8, 2), Vector2(-8, 2),
		])
	else:
		body.color = Color(0.85, 0.2, 0.18)
		body.polygon = PackedVector2Array([
			Vector2(-3, -6), Vector2(3, -6), Vector2(3, 4), Vector2(-3, 4),
		])
	root.add_child(body)
	return root


func _collect_road_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in _city.map_cells.y:
		for x in _city.map_cells.x:
			var cell := Vector2i(x, y)
			var atlas := _city.tile_map.get_cell_atlas_coords(cell)
			if CityMath.is_drivable_atlas(atlas):
				cells.append(cell)
	return cells


func _touches_road(cell: Vector2i) -> bool:
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var atlas := _city.tile_map.get_cell_atlas_coords(cell + offset)
		if CityMath.is_drivable_atlas(atlas):
			return true
	return false


func _touches_building(cell: Vector2i) -> bool:
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var atlas := _city.tile_map.get_cell_atlas_coords(cell + offset)
		if CityMath.is_building_atlas(atlas):
			return true
	return false

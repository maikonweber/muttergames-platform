extends Node2D
class_name CityGenerator
## Gera cidade isométrica procedural a partir de uma seed.
##
## Pipeline de `generate()`:
## 1. CityNoise atribui distrito (downtown / residencial / industrial / parque) por bloco
## 2. Grade de células: ruas, avenidas, cruzamentos, prédios, pátios
## 3. Colisores (diamantes isométricos + paredes de borda) em `WorldCollision`
## 4. Populator preenche árvores, props, NPCs e polícia
## 5. Emite `city_generated` com posição de spawn
##
## Colisão do TileMap fica desligada — física vem só de WorldCollision (layer `buildings`).
## Grupo: `city_generator`.

const CityMath = preload("res://scripts/world/city_math.gd")
const CityNoiseScript = preload("res://scripts/world/city_noise.gd")
const PopulatorScript = preload("res://scripts/world/city_populator.gd")
const AssetArt = preload("res://scripts/world/asset_art.gd")

signal city_generated(spawn_position: Vector2)

## Índices no atlas gerado em `_build_tileset` (ordem fixa).
const TILE_ROAD := Vector2i(0, 0)
const TILE_BUILDING := Vector2i(1, 0)
const TILE_CROSSWALK := Vector2i(2, 0)
const TILE_AVENUE := Vector2i(3, 0)
const TILE_PARK := Vector2i(4, 0)
const TILE_BUILDING_RES := Vector2i(5, 0)
const TILE_BUILDING_IND := Vector2i(6, 0)
const SOURCE_ID := 0

## Cores fallback quando arte Meshy não está presente.
const COLOR_ROAD := Color(0.28, 0.30, 0.34)
const COLOR_BUILDING := Color(0.72, 0.22, 0.28)
const COLOR_CROSSWALK := Color(0.95, 0.82, 0.15)
const COLOR_AVENUE := Color(0.34, 0.38, 0.48)
const COLOR_PARK := Color(0.22, 0.55, 0.30)
const COLOR_BUILDING_RES := Color(0.78, 0.48, 0.28)
const COLOR_BUILDING_IND := Color(0.42, 0.44, 0.48)

## Quantidade de quarteirões ao longo de um eixo (cidade ~N×N).
@export var grid_blocks: int = 16
## Células de prédio por lado dentro de um quarteirão.
@export var block_size: int = 3
## Largura das ruas em células (também define avenidas/cruzamentos).
@export var street_width: int = 4
## A cada N índices de rua, pinta avenida (mais larga visualmente / pesos de IA).
@export var avenue_every: int = 3
## Chance base de plaza/parque aberto (modificada pelo Perlin).
@export var plaza_chance: float = 0.12
@export var tile_width: int = 64
@export var tile_height: int = 32
## 0 = seed aleatória em runtime; ≠0 fixa a cidade.
@export var seed_value: int = 0
@export var show_bounds_overlay: bool = true
@export var show_collider_overlay: bool = false
## Se true, tenta PNG Meshy; senão diamantes coloridos procedurais.
@export var use_generated_art: bool = true

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var props_root: Node2D = $Props

var spawn_position: Vector2 = Vector2.ZERO
## Seed efetiva da última geração (debug / reprodutibilidade).
var last_seed: int = 0
## Retângulo mundo onde o carro pode circular (câmera + clamp).
var play_bounds: Rect2 = Rect2()
var map_cells: Vector2i = Vector2i.ZERO
## Instância de CityNoise da seed atual.
var noise: RefCounted

var show_debug_overlay: bool:
	get:
		return show_bounds_overlay or show_collider_overlay
	set(value):
		show_bounds_overlay = value
		if not value:
			show_collider_overlay = false

var _world_body: StaticBody2D
var _debug_draw: Node2D
## Células de prédio (para colliders + populator).
var _building_cells: Array[Vector2i] = []
## Bloco aberto (parque/plaza) → sem collider de prédio.
var _open_blocks: Dictionary = {} # Vector2i -> true
## Bloco → CityNoise.District.
var _block_district: Dictionary = {}
var _populator: Node2D


func _ready() -> void:
	add_to_group("city_generator")
	if props_root == null:
		props_root = Node2D.new()
		props_root.name = "Props"
		add_child(props_root)
	_ensure_world_body()
	_ensure_debug_draw()
	_ensure_populator()
	tile_map.tile_set = _build_tileset()
	# Física do tileset off — usamos WorldCollision custom.
	tile_map.collision_enabled = false
	generate(seed_value)


## Gera (ou regenere) a cidade. `p_seed == 0` → aleatório.
func generate(p_seed: int = 0) -> void:
	last_seed = p_seed if p_seed != 0 else randi()
	noise = CityNoiseScript.new(last_seed)
	var rng := RandomNumberGenerator.new()
	rng.seed = last_seed

	tile_map.clear()
	_clear_props()
	_clear_world_shapes()
	_building_cells.clear()
	_open_blocks.clear()
	_block_district.clear()

	var map_size := CityMath.map_size_cells(grid_blocks, block_size, street_width)
	var map_w := map_size.x
	var map_h := map_size.y
	map_cells = map_size
	var stride := CityMath.stride(block_size, street_width)

	# Passo 1: distrito + plazas por quarteirão (coords de bloco, não célula).
	for by in grid_blocks:
		for bx in grid_blocks:
			var id := Vector2i(bx, by)
			var district: int = noise.district_at(float(bx), float(by))
			_block_district[id] = district
			var open_roll := rng.randf()
			var chance: float = noise.plaza_chance(float(bx), float(by), plaza_chance)
			if district == CityNoiseScript.District.PARK or open_roll < chance:
				_open_blocks[id] = true

	# Passo 2: preencher cada célula do mapa.
	for y in map_h:
		for x in map_w:
			var cell := Vector2i(x, y)
			var block_id := _block_id_for_cell(cell, stride)

			if CityMath.is_intersection(x, y, stride, street_width):
				tile_map.set_cell(cell, SOURCE_ID, TILE_CROSSWALK)
				continue
			if CityMath.is_avenue_cell(x, y, stride, street_width, avenue_every):
				tile_map.set_cell(cell, SOURCE_ID, TILE_AVENUE)
				continue
			if CityMath.is_road_cell(x, y, stride, street_width):
				tile_map.set_cell(cell, SOURCE_ID, TILE_ROAD)
				continue

			if block_id == Vector2i(-1, -1):
				tile_map.set_cell(cell, SOURCE_ID, TILE_ROAD)
				continue

			var district: int = _block_district.get(block_id, CityNoiseScript.District.RESIDENTIAL)
			var is_open: bool = _open_blocks.has(block_id)

			# Pátios internos (estacionamento) — dirigíveis, sem collider.
			if not is_open and noise.courtyard_hole(float(x), float(y)):
				tile_map.set_cell(cell, SOURCE_ID, TILE_ROAD)
				continue

			if is_open or district == CityNoiseScript.District.PARK:
				tile_map.set_cell(cell, SOURCE_ID, TILE_PARK)
				continue

			match district:
				CityNoiseScript.District.DOWNTOWN:
					tile_map.set_cell(cell, SOURCE_ID, TILE_BUILDING)
				CityNoiseScript.District.INDUSTRIAL:
					tile_map.set_cell(cell, SOURCE_ID, TILE_BUILDING_IND)
				_:
					tile_map.set_cell(cell, SOURCE_ID, TILE_BUILDING_RES)
			_building_cells.append(cell)

	# Passo 3–4: bounds, física, debug, spawn, atores.
	_rebuild_play_bounds(map_w, map_h)
	_rebuild_block_colliders(stride)
	_rebuild_border_walls()
	if _debug_draw != null:
		_debug_draw.queue_redraw()

	var spawn_cell := CityMath.spawn_cell(street_width)
	spawn_position = to_global(tile_map.map_to_local(spawn_cell))

	if _populator != null and _populator.has_method("setup"):
		_populator.setup(self)

	city_generated.emit(spawn_position)


func regenerate(p_seed: int = 0) -> Vector2:
	generate(p_seed)
	return spawn_position


func get_spawn_position() -> Vector2:
	return spawn_position


func get_play_bounds() -> Rect2:
	return play_bounds


func get_building_cells() -> Array[Vector2i]:
	return _building_cells


func get_block_district(block_id: Vector2i) -> int:
	return int(_block_district.get(block_id, CityNoiseScript.District.RESIDENTIAL))


func is_open_block(block_id: Vector2i) -> bool:
	return _open_blocks.has(block_id)


func get_noise() -> RefCounted:
	return noise


func clamp_to_play_bounds(global_pos: Vector2) -> Vector2:
	return CityMath.clamp_point(global_pos, play_bounds)


## True se o tile sob a posição é rua/avenida/cruzamento/parque.
func is_drivable(global_pos: Vector2) -> bool:
	var local_pos := tile_map.to_local(global_pos)
	var cell := tile_map.local_to_map(local_pos)
	if cell.x < 0 or cell.y < 0 or cell.x >= map_cells.x or cell.y >= map_cells.y:
		return false
	return CityMath.is_drivable_atlas(tile_map.get_cell_atlas_coords(cell))


## Amostra o centro + 8 pontos ao redor — evita clipar o sprite no prédio.
func is_drivable_radius(global_pos: Vector2, radius: float) -> bool:
	if not is_drivable(global_pos):
		return false
	var offsets := [
		Vector2(radius, 0.0),
		Vector2(-radius, 0.0),
		Vector2(0.0, radius),
		Vector2(0.0, -radius),
		Vector2(radius * 0.7, radius * 0.7),
		Vector2(-radius * 0.7, radius * 0.7),
		Vector2(radius * 0.7, -radius * 0.7),
		Vector2(-radius * 0.7, -radius * 0.7),
	]
	for offset in offsets:
		if not is_drivable(global_pos + offset):
			return false
	return true


## (-1,-1) = célula de rua; senão ID do quarteirão.
func _block_id_for_cell(cell: Vector2i, stride: int) -> Vector2i:
	if CityMath.is_road_cell(cell.x, cell.y, stride, street_width):
		return Vector2i(-1, -1)
	var local_x := (cell.x % stride) - street_width
	var local_y := (cell.y % stride) - street_width
	if local_x < 0 or local_y < 0 or local_x >= block_size or local_y >= block_size:
		return Vector2i(-1, -1)
	return Vector2i(int(cell.x / stride), int(cell.y / stride))


func _ensure_world_body() -> void:
	_world_body = get_node_or_null("WorldCollision") as StaticBody2D
	if _world_body == null:
		_world_body = StaticBody2D.new()
		_world_body.name = "WorldCollision"
		add_child(_world_body)
	_world_body.collision_layer = 1
	_world_body.collision_mask = 0


func _ensure_debug_draw() -> void:
	_debug_draw = get_node_or_null("DebugDraw") as Node2D
	if _debug_draw != null:
		return
	_debug_draw = Node2D.new()
	_debug_draw.name = "DebugDraw"
	_debug_draw.z_index = 100
	_debug_draw.set_script(load("res://scripts/world/city_debug_draw.gd"))
	add_child(_debug_draw)


func _ensure_populator() -> void:
	_populator = get_node_or_null("Populator") as Node2D
	if _populator != null:
		return
	_populator = Node2D.new()
	_populator.name = "Populator"
	_populator.set_script(PopulatorScript)
	add_child(_populator)


func _clear_world_shapes() -> void:
	_ensure_world_body()
	for child in _world_body.get_children():
		_world_body.remove_child(child)
		child.free()


## AABB do mapa em world space, com padding interno (play area).
func _rebuild_play_bounds(map_w: int, map_h: int) -> void:
	var min_v := Vector2(INF, INF)
	var max_v := Vector2(-INF, -INF)
	for x in map_w:
		for y in [0, map_h - 1]:
			var world := to_global(tile_map.map_to_local(Vector2i(x, y)))
			min_v = min_v.min(world)
			max_v = max_v.max(world)
	for y in map_h:
		for x in [0, map_w - 1]:
			var world := to_global(tile_map.map_to_local(Vector2i(x, y)))
			min_v = min_v.min(world)
			max_v = max_v.max(world)
	var pad := Vector2(float(tile_width) * 0.15, float(tile_height) * 0.2)
	play_bounds = CityMath.tighten_bounds(min_v, max_v, pad)


## Um diamante isométrico por célula de prédio (pátios ficam abertos).
func _rebuild_block_colliders(_stride: int) -> void:
	var hw := float(tile_width) * 0.46
	var hh := float(tile_height) * 0.46
	var diamond := PackedVector2Array([
		Vector2(0.0, -hh),
		Vector2(hw, 0.0),
		Vector2(0.0, hh),
		Vector2(-hw, 0.0),
	])
	for cell in _building_cells:
		var shape := ConvexPolygonShape2D.new()
		shape.points = diamond
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = tile_map.map_to_local(cell)
		_world_body.add_child(col)


## Quatro paredes grossas ao redor de play_bounds (impede sair do mapa).
func _rebuild_border_walls() -> void:
	if play_bounds.size.x <= 0.0 or play_bounds.size.y <= 0.0:
		return
	var thickness := 80.0
	var b := play_bounds
	_add_wall_global(Rect2(b.position.x - thickness, b.position.y - thickness, b.size.x + thickness * 2.0, thickness))
	_add_wall_global(Rect2(b.position.x - thickness, b.end.y, b.size.x + thickness * 2.0, thickness))
	_add_wall_global(Rect2(b.position.x - thickness, b.position.y, thickness, b.size.y))
	_add_wall_global(Rect2(b.end.x, b.position.y, thickness, b.size.y))


func _add_wall_global(rect: Rect2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = to_local(rect.get_center())
	_world_body.add_child(col)


func _clear_props() -> void:
	if props_root == null:
		return
	for child in props_root.get_children():
		child.queue_free()
	if _populator != null and _populator.has_method("clear_actors"):
		_populator.clear_actors()


## Monta TileSet isométrico em runtime (7 tiles no atlas horizontal).
func _build_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	tileset.tile_size = Vector2i(tile_width, tile_height)

	var atlas_img := Image.create(tile_width * 7, tile_height, false, Image.FORMAT_RGBA8)
	atlas_img.fill(Color(0, 0, 0, 0))
	if use_generated_art:
		_blit_art_or_diamond(atlas_img, 0, AssetArt.TILE_ROAD, COLOR_ROAD, Color(0.40, 0.42, 0.46))
		_blit_art_or_diamond(atlas_img, tile_width, AssetArt.TILE_BUILDING, COLOR_BUILDING, Color(0.95, 0.35, 0.40))
		_blit_art_or_diamond(atlas_img, tile_width * 2, AssetArt.TILE_CROSSWALK, COLOR_CROSSWALK, Color(1.0, 0.92, 0.35))
		_blit_art_or_diamond(atlas_img, tile_width * 3, AssetArt.TILE_AVENUE, COLOR_AVENUE, Color(0.50, 0.55, 0.70))
		_blit_art_or_diamond(atlas_img, tile_width * 4, AssetArt.TILE_PARK, COLOR_PARK, Color(0.35, 0.72, 0.40))
		_blit_art_or_diamond(atlas_img, tile_width * 5, AssetArt.TILE_BUILDING_RES, COLOR_BUILDING_RES, Color(0.95, 0.62, 0.38))
		_blit_art_or_diamond(atlas_img, tile_width * 6, AssetArt.TILE_BUILDING_IND, COLOR_BUILDING_IND, Color(0.58, 0.60, 0.64))
	else:
		_blit_diamond(atlas_img, 0, COLOR_ROAD, Color(0.40, 0.42, 0.46))
		_blit_diamond(atlas_img, tile_width, COLOR_BUILDING, Color(0.95, 0.35, 0.40))
		_blit_diamond(atlas_img, tile_width * 2, COLOR_CROSSWALK, Color(1.0, 0.92, 0.35))
		_blit_diamond(atlas_img, tile_width * 3, COLOR_AVENUE, Color(0.50, 0.55, 0.70))
		_blit_diamond(atlas_img, tile_width * 4, COLOR_PARK, Color(0.35, 0.72, 0.40))
		_blit_diamond(atlas_img, tile_width * 5, COLOR_BUILDING_RES, Color(0.95, 0.62, 0.38))
		_blit_diamond(atlas_img, tile_width * 6, COLOR_BUILDING_IND, Color(0.58, 0.60, 0.64))

	var texture := ImageTexture.create_from_image(atlas_img)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(tile_width, tile_height)
	source.create_tile(TILE_ROAD)
	source.create_tile(TILE_BUILDING)
	source.create_tile(TILE_CROSSWALK)
	source.create_tile(TILE_AVENUE)
	source.create_tile(TILE_PARK)
	source.create_tile(TILE_BUILDING_RES)
	source.create_tile(TILE_BUILDING_IND)
	tileset.add_source(source, SOURCE_ID)
	return tileset


## Preferência: arte Meshy; fallback: diamante procedural.
func _blit_art_or_diamond(img: Image, offset_x: int, path: String, fill: Color, outline: Color) -> void:
	var cell := AssetArt.make_tile_cell(path, tile_width, tile_height)
	if cell == null:
		_blit_diamond(img, offset_x, fill, outline)
		return
	img.blit_rect(cell, Rect2i(0, 0, tile_width, tile_height), Vector2i(offset_x, 0))


## Diamante Manhattan (|nx|+|ny| ≤ 1) = tile isométrico simples.
func _blit_diamond(img: Image, offset_x: int, fill: Color, outline: Color) -> void:
	var w := tile_width
	var h := tile_height
	var cx := w * 0.5
	var cy := h * 0.5
	for y in h:
		for x in w:
			var nx: float = absf(float(x) - cx) / cx
			var ny: float = absf(float(y) - cy) / cy
			var d: float = nx + ny
			if d <= 1.0:
				var color := outline if d >= 0.82 else fill
				img.set_pixel(offset_x + x, y, color)

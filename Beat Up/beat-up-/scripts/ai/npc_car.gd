extends CharacterBody2D
## Tráfego civil — anda em linha reta nas ruas e vira ocasionalmente em cruzamentos.
##
## Direção lógica `_dir` é um Vector2i cardinal; `facing` suaviza a rotação visual.
## Ao colidir ou sair do dirigível, inverte `_dir` (reação simples — Fase 2
## melhorará faixas / semáforos). Grupo: `npc_cars`. Layer 4 = traffic.

const CarMath = preload("res://scripts/vehicle/car_math.gd")
const CityMath = preload("res://scripts/world/city_math.gd")
const AssetArt = preload("res://scripts/world/asset_art.gd")

@export var max_speed: float = 140.0
@export var turn_speed: float = 2.4

var facing: float = 0.0
var current_speed: float = 0.0
var _city: CityGenerator
## Direção de grade: (1,0), (-1,0), (0,1) ou (0,-1).
var _dir: Vector2i = Vector2i(1, 0)


func _ready() -> void:
	add_to_group("npc_cars")
	collision_layer = 4
	collision_mask = 1
	motion_mode = MOTION_MODE_FLOATING
	y_sort_enabled = true


func setup(city: CityGenerator, rng: RandomNumberGenerator) -> void:
	_city = city
	var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	_dir = dirs[rng.randi_range(0, dirs.size() - 1)]
	facing = Vector2(_dir).angle()
	current_speed = rng.randf_range(max_speed * 0.55, max_speed)
	var path := AssetArt.SPRITE_TAXI if rng.randf() < 0.55 else AssetArt.SPRITE_VAN
	if not AssetArt.apply_car_sprite($Visual, path):
		_paint(Color(rng.randf_range(0.2, 0.9), rng.randf_range(0.2, 0.9), rng.randf_range(0.2, 0.9)))


func _physics_process(delta: float) -> void:
	if _city == null:
		return

	_maybe_turn()
	facing = lerp_angle(facing, Vector2(_dir).angle(), clampf(turn_speed * delta, 0.0, 1.0))
	velocity = CarMath.velocity_from_facing(facing, current_speed)
	move_and_slide()

	if get_slide_collision_count() > 0 or not _city.is_drivable_radius(global_position, 8.0):
		_reverse_or_turn()
	else:
		global_position = _city.clamp_to_play_bounds(global_position)

	$Visual.rotation = _snapped_car_facing()


func _snapped_car_facing() -> float:
	var step := PI * 0.25
	return round(facing / step) * step + AssetArt.CAR_FACING_OFFSET


## Chance pequena de escolher nova direção em cruzamento / avenida.
func _maybe_turn() -> void:
	var local := _city.tile_map.to_local(global_position)
	var cell := _city.tile_map.local_to_map(local)
	var atlas := _city.tile_map.get_cell_atlas_coords(cell)
	if atlas != CityMath.ATLAS_CROSSWALK and atlas != CityMath.ATLAS_AVENUE:
		return
	if randf() > 0.02:
		return
	var options: Array[Vector2i] = []
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var next_atlas := _city.tile_map.get_cell_atlas_coords(cell + d)
		if CityMath.is_drivable_atlas(next_atlas):
			options.append(d)
	if options.is_empty():
		return
	_dir = options[randi_range(0, options.size() - 1)]


## Reação a colisão / off-road: vira 180° e reduz velocidade.
func _reverse_or_turn() -> void:
	_dir = -_dir
	facing = Vector2(_dir).angle()
	current_speed *= 0.7


## Fallback se sprite Meshy não carregar (Polygon2D na cena).
func _paint(color: Color) -> void:
	var body := get_node_or_null("Visual/Body") as Polygon2D
	if body != null:
		body.color = color

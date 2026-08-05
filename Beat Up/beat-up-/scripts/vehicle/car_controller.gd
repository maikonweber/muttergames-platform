extends CharacterBody2D
class_name CarController
## Carro do jogador — física arcade + restrição às superfícies dirigíveis.
##
## Camadas (project.godot):
## - layer 2 = `car` (nósso corpo)
## - mask 1 = `buildings` (bate em WorldCollision da cidade)
##
## Fluxo por frame (`_physics_process`):
## 1. Ler teclas → throttle / steer
## 2. CarMath integra velocidade e facing
## 3. `move_and_slide` + desacelera se colidir
## 4. `_enforce_drivable_surface` (rollback se entrou em prédio/void)
## 5. `_constrain_to_map` (borda do play area)
##
## Grupo: `player_car` (polícia e debug procuram aqui).

const CarMath = preload("res://scripts/vehicle/car_math.gd")
const AssetArt = preload("res://scripts/world/asset_art.gd")

@export var acceleration: float = 520.0
@export var max_speed: float = 280.0
@export var friction: float = 420.0
@export var reverse_max_speed: float = 110.0
@export var turn_speed: float = 3.2
## Abaixo desta velocidade (|u|), não vira — evita spin parado.
@export var min_turn_speed: float = 12.0
@export var camera_follow_smoothing: float = 10.0
## Quanto a câmera olha à frente na direção do movimento.
@export var camera_look_ahead: float = 40.0

var current_speed: float = 0.0
## Ângulo de direção em radianos (lógica); visual é “snapped” a 45°.
var facing: float = 0.0
## Espelhado para DebugManager (overlay).
var debug_throttle: float = 0.0
var debug_steer: float = 0.0

## Estado de teclas pressionado (keycode → bool). Evita InputMap atrasado / stuck.
var _key_down: Dictionary = {}
var _city: CityGenerator
## Última posição ainda em superfície dirigível — usado no rollback.
var _last_valid_position: Vector2 = Vector2.ZERO

@onready var _visual: Node2D = $Visual
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	add_to_group("player_car")
	y_sort_enabled = true
	collision_layer = 2
	collision_mask = 1
	motion_mode = MOTION_MODE_FLOATING
	safe_margin = 0.08
	# Continua processando com árvore pausada (debug pause não trava o carro).
	process_mode = Node.PROCESS_MODE_ALWAYS
	rotation = 0.0
	_last_valid_position = global_position
	AssetArt.apply_car_sprite(_visual, AssetArt.SPRITE_PLAYER)
	_apply_visual_facing()
	if _camera != null:
		_camera.make_current()
		_camera.enabled = true
		_camera.position_smoothing_enabled = true
		_camera.position_smoothing_speed = camera_follow_smoothing
	# Cidade pode ainda não estar no grupo no mesmo frame.
	call_deferred("_bind_city")


func _bind_city() -> void:
	_city = get_tree().get_first_node_in_group("city_generator") as CityGenerator
	_apply_camera_limits()


## Ligação explícita quando Main reposiciona o spawn (mais confiável que lookup).
func bind_to_city(city: CityGenerator) -> void:
	_city = city
	_apply_camera_limits()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		var key_event := event as InputEventKey
		if key_event.physical_keycode != KEY_NONE:
			_key_down[key_event.physical_keycode] = key_event.pressed
		if key_event.keycode != KEY_NONE:
			_key_down[key_event.keycode] = key_event.pressed


func _physics_process(delta: float) -> void:
	var throttle := _axis_from_keys([KEY_W, KEY_UP], [KEY_S, KEY_DOWN])
	var steer := _axis_from_keys([KEY_D, KEY_RIGHT], [KEY_A, KEY_LEFT])
	debug_throttle = throttle
	debug_steer = steer

	current_speed = CarMath.integrate_speed(
		current_speed,
		throttle,
		max_speed,
		reverse_max_speed,
		acceleration,
		friction,
		delta,
	)
	facing = CarMath.integrate_facing(
		facing,
		steer,
		current_speed,
		max_speed,
		turn_speed,
		min_turn_speed,
		delta,
	)

	_apply_visual_facing()

	velocity = CarMath.velocity_from_facing(facing, current_speed)
	move_and_slide()

	# Bateu em parede/prédio físico → corta velocidade (sensação de impacto).
	if get_slide_collision_count() > 0:
		current_speed *= 0.35
		velocity = Vector2.ZERO

	_enforce_drivable_surface()
	_constrain_to_map()
	_update_camera_look_ahead()


## Impede atravessar tiles não dirigíveis (prédio sem collider, buraco, etc.).
## Se o raio ao redor do carro deixar de ser dirigível, rollback à última posição válida.
func _enforce_drivable_surface() -> void:
	if _city == null:
		_city = get_tree().get_first_node_in_group("city_generator") as CityGenerator
		if _city == null:
			return
		_apply_camera_limits()

	# Probe ao redor evita clipar metade do sprite dentro do prédio.
	if _city.is_drivable_radius(global_position, 10.0):
		_last_valid_position = global_position
		return

	global_position = _last_valid_position
	velocity = Vector2.ZERO
	current_speed *= 0.2


## Clamp ao retângulo de jogo + freia se bater na borda.
func _constrain_to_map() -> void:
	if _city == null:
		return

	var bounds: Rect2 = _city.get_play_bounds()
	if bounds.size == Vector2.ZERO:
		return

	var before := global_position
	var clamped: Vector2 = _city.clamp_to_play_bounds(global_position)
	if not clamped.is_equal_approx(before):
		global_position = clamped
		velocity = Vector2.ZERO
		current_speed *= 0.2
		if _city.is_drivable(global_position):
			_last_valid_position = global_position


func _apply_camera_limits() -> void:
	if _camera == null or _city == null:
		return
	var bounds: Rect2 = _city.get_play_bounds()
	if bounds.size == Vector2.ZERO:
		_camera.limit_enabled = false
		return
	_camera.limit_enabled = true
	_camera.limit_left = int(bounds.position.x)
	_camera.limit_top = int(bounds.position.y)
	_camera.limit_right = int(bounds.end.x)
	_camera.limit_bottom = int(bounds.end.y)


func reset_motion() -> void:
	current_speed = 0.0
	velocity = Vector2.ZERO
	facing = 0.0
	_key_down.clear()
	_apply_visual_facing()
	_last_valid_position = global_position
	if _camera != null:
		_camera.offset = Vector2.ZERO


## Teleporta para o spawn e zera física (regen / início de corrida).
func set_spawn(global_pos: Vector2) -> void:
	current_speed = 0.0
	velocity = Vector2.ZERO
	facing = 0.0
	_key_down.clear()
	global_position = global_pos
	_last_valid_position = global_pos
	_apply_visual_facing()
	if _camera != null:
		_camera.offset = Vector2.ZERO


## Usado por `scenes/test_physics.tscn` para validar clamps sem wait de frame.
func force_constrain_for_test() -> void:
	_enforce_drivable_surface()
	_constrain_to_map()


## Força a câmera a atualizar após teleport (evita smear de suavização).
func snap_camera() -> void:
	if _camera == null:
		return
	_apply_camera_limits()
	_camera.make_current()
	_camera.reset_smoothing()
	_camera.force_update_scroll()


func get_speed_kmh() -> float:
	return absf(current_speed) * 0.36


func _apply_visual_facing() -> void:
	if _visual != null:
		# Snap a 45°: arte isométrica do carro permanece estável ao virar.
		var step := PI * 0.25
		var snapped: float = round(facing / step) * step
		_visual.rotation = snapped + AssetArt.CAR_FACING_OFFSET


func _update_camera_look_ahead() -> void:
	if _camera == null:
		return
	var ahead := Vector2.RIGHT.rotated(facing) * signf(current_speed) * camera_look_ahead
	_camera.offset = _camera.offset.lerp(ahead, 0.08)


func _axis_from_keys(positive: Array, negative: Array) -> float:
	return CarMath.axis_from_bools(_any_key_down(positive), _any_key_down(negative))


func _any_key_down(keys: Array) -> bool:
	for key in keys:
		if _key_down.get(key, false):
			return true
	return false

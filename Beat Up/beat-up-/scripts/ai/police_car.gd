extends CharacterBody2D
## IA da polícia — persegue o jogador com predição adaptativa (“stalker learn”).
##
## Ideia: suaviza a velocidade observada do jogador (`_learned_velocity`) e mira
## um ponto à frente. `aggro` sobe com o tempo de chase (mais rápido / mais
## alcance de predição). Ao bater em prédio, desvia lateralmente.
##
## Camada 4 = `traffic` (mesmo layer dos NPCs). Grupo: `police`.

const CarMath = preload("res://scripts/vehicle/car_math.gd")
const AssetArt = preload("res://scripts/world/asset_art.gd")

@export var max_speed: float = 255.0
@export var accel: float = 480.0
@export var turn_speed: float = 3.4
## Quanto do velocity atual do jogador entra na média por frame (0–1).
@export var learn_rate: float = 0.12
## Segundos de look-ahead base da predição de posição.
@export var predict_time: float = 0.55

var facing: float = 0.0
var current_speed: float = 0.0
var _city: CityGenerator
## Média móvel da velocity do jogador (direção “típica” de fuga).
var _learned_velocity: Vector2 = Vector2.ZERO
## 0 = acabei de ver o jogador; 1 = chase longo / mais agressivo.
var _aggro: float = 0.0


func _ready() -> void:
	add_to_group("police")
	collision_layer = 4
	collision_mask = 1
	motion_mode = MOTION_MODE_FLOATING
	y_sort_enabled = true


## Chamado pelo Populator após instanciar na rua.
func setup(city: CityGenerator, rng: RandomNumberGenerator) -> void:
	_city = city
	facing = rng.randf() * TAU
	current_speed = rng.randf_range(80.0, 140.0)
	AssetArt.apply_car_sprite($Visual, AssetArt.SPRITE_POLICE)


func _physics_process(delta: float) -> void:
	if _city == null:
		return

	var player := get_tree().get_first_node_in_group("player_car") as CarController
	if player == null:
		_wander(delta)
		return

	# Aprende tendência de movimento do jogador ao longo do tempo.
	var player_vel := player.velocity
	_learned_velocity = _learned_velocity.lerp(player_vel, learn_rate)
	_aggro = clampf(_aggro + delta * 0.15, 0.0, 1.0)

	# Mira posição futura (look-ahead cresce com aggro).
	var predicted := player.global_position + _learned_velocity * predict_time * (0.5 + _aggro * 0.5)
	var to_target := predicted - global_position
	var desired_facing := to_target.angle()
	facing = lerp_angle(facing, desired_facing, clampf(turn_speed * delta, 0.0, 1.0))

	var target_speed := max_speed * (0.65 + 0.35 * _aggro)
	# Burst se o jogador está fugindo alinhado à direção aprendida.
	if player_vel.length() > 40.0 and player_vel.normalized().dot(_learned_velocity.normalized()) > 0.6:
		target_speed = max_speed * 1.08

	current_speed = move_toward(current_speed, target_speed, accel * delta)
	velocity = CarMath.velocity_from_facing(facing, current_speed)
	move_and_slide()

	if get_slide_collision_count() > 0 or not _city.is_drivable_radius(global_position, 8.0):
		# Contorna obstáculo usando normal lateral da velocity aprendida.
		var side := Vector2(-_learned_velocity.y, _learned_velocity.x)
		if side.length_squared() < 0.01:
			side = Vector2.RIGHT.rotated(facing + PI * 0.5)
		facing = lerp_angle(facing, side.angle(), 0.35)
		current_speed *= 0.6
	else:
		global_position = _city.clamp_to_play_bounds(global_position)

	$Visual.rotation = _snapped_car_facing()


## Patrulha leve se não há jogador (ex.: menu / testes).
func _wander(delta: float) -> void:
	current_speed = move_toward(current_speed, max_speed * 0.4, accel * delta)
	facing += delta * 0.4
	velocity = CarMath.velocity_from_facing(facing, current_speed)
	move_and_slide()
	$Visual.rotation = _snapped_car_facing()


## Mesmo snap 45° do carro do jogador (arte isométrica).
func _snapped_car_facing() -> float:
	var step := PI * 0.25
	return round(facing / step) * step + AssetArt.CAR_FACING_OFFSET

extends RefCounted
class_name CarMath
## Matemática pura do carro arcade — sem nós Godot, unit-testável.
##
## Usado por `CarController`, polícia e NPCs. Testes: `tests/unit/test_car_math.gd`.
##
## Convenções:
## - `throttle` / `steer` em [-1, 1]
## - `facing` em radianos (0 = +X / direita)
## - velocidade positiva = frente; negativa = ré


## Velocidade-alvo a partir do acelerador (ré mais lenta que frente).
static func target_speed(throttle: float, max_speed: float, reverse_max_speed: float) -> float:
	if throttle > 0.0:
		return max_speed * throttle
	if throttle < 0.0:
		return reverse_max_speed * throttle
	return 0.0


## Integra velocidade: acelera em direção ao alvo ou aplica atrito se solto.
static func integrate_speed(
	current: float,
	throttle: float,
	max_speed: float,
	reverse_max_speed: float,
	acceleration: float,
	friction: float,
	delta: float,
) -> float:
	var target := target_speed(throttle, max_speed, reverse_max_speed)
	if absf(throttle) > 0.01:
		return move_toward(current, target, acceleration * delta)
	return move_toward(current, 0.0, friction * delta)


## Integra ângulo de direção: só vira se estiver acima de `min_turn_speed`.
## Escala a virada pela razão |speed|/max_speed (mais rápido = vira mais).
## `signf(speed)` inverte o stering na ré (comportamento de carro).
static func integrate_facing(
	facing: float,
	steer: float,
	speed: float,
	max_speed: float,
	turn_speed: float,
	min_turn_speed: float,
	delta: float,
) -> float:
	if absf(speed) <= min_turn_speed or absf(steer) <= 0.01:
		return facing
	var turn_scale := clampf(absf(speed) / max_speed, 0.3, 1.0)
	return facing + steer * turn_speed * turn_scale * signf(speed) * delta


## Converte facing + velocidade escalar em vetor de movimento 2D.
static func velocity_from_facing(facing: float, speed: float) -> Vector2:
	return Vector2.RIGHT.rotated(facing) * speed


## Converte dois booleans (ex.: teclas) em eixo [-1, 1].
static func axis_from_bools(positive: bool, negative: bool) -> float:
	var value := 0.0
	if positive:
		value += 1.0
	if negative:
		value -= 1.0
	return clampf(value, -1.0, 1.0)

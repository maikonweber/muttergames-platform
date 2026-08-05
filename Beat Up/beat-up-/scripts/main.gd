extends Node2D
## Cena raiz do jogo (`scenes/main.tscn`).
##
## Responsabilidades:
## - Garantir InputMap (WASD / setas) mesmo se o project.godot mudou
## - Instanciar HUD, carro do jogador e conectar regeneração de cidade
## - Expor API usada pelo DebugManager (regen, seed, carro)
##
## Grupos: entra em `main_game` para o debug achar este nó.

const CAR_SCENE := preload("res://scenes/car.tscn")

@onready var city_map: CityGenerator = $CityMap

## Instância do carro do jogador (criada em `_ready`).
var car: CarController


func _ready() -> void:
	_ensure_input_actions()
	add_to_group("main_game")
	RenderingServer.set_default_clear_color(Color(0.10, 0.12, 0.14))

	# HUD é um CanvasLayer criado em código (sem cena própria ainda).
	var hud := preload("res://scripts/ui/game_hud.gd").new()
	add_child(hud)

	car = CAR_SCENE.instantiate() as CarController
	add_child(car)
	_place_car_at_spawn()

	# Quando a cidade regenera (seed nova), reposiciona o carro no spawn.
	city_map.city_generated.connect(_on_city_generated)
	GameManager.start_game()


## Regenera a cidade procedural. `p_seed == 0` escolhe seed aleatória.
func regenerate_city(p_seed: int = 0) -> void:
	city_map.regenerate(p_seed)
	_place_car_at_spawn()


func get_car() -> CarController:
	return car


## Seed usada na última geração (útil para reprodutibilidade / debug).
func get_city_seed() -> int:
	return city_map.last_seed


## Liga o carro à cidade, coloca no spawn e reseta câmera.
func _place_car_at_spawn() -> void:
	if car == null:
		return
	car.bind_to_city(city_map)
	car.set_spawn(city_map.get_spawn_position())
	car.rotation = 0.0
	car.snap_camera()


func _on_city_generated(_spawn_position: Vector2) -> void:
	_place_car_at_spawn()


## Garante actions de movimento no InputMap em runtime (idempotente).
func _ensure_input_actions() -> void:
	_bind_action("move_forward", [KEY_W, KEY_UP])
	_bind_action("move_back", [KEY_S, KEY_DOWN])
	_bind_action("turn_left", [KEY_A, KEY_LEFT])
	_bind_action("turn_right", [KEY_D, KEY_RIGHT])


func _bind_action(action: String, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode in keycodes:
		var key := keycode as Key
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		if not _action_has_event(action, event):
			InputMap.action_add_event(action, event)


func _action_has_event(action: String, event: InputEventKey) -> bool:
	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey \
				and (existing.physical_keycode == event.physical_keycode \
				or existing.keycode == event.keycode):
			return true
	return false

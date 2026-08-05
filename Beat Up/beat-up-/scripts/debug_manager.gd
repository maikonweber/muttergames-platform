extends CanvasLayer
## Overlay de debug + cheats — só existe em builds de debug (`OS.is_debug_build()`).
##
## Atalhos (também listados no painel):
## F1 toggle HUD | F2 +score | F3 game over | F4 restart
## F5 colliders Godot | F6 overlay cidade | P pause | R regen cidade
##
## Autoload em project.godot como `DebugManager`. layer 100 (acima do HUD).

const CHEAT_SCORE_AMOUNT := 100

var _panel: PanelContainer
var _label: Label
var _visible_overlay: bool = true


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_ui()
	_refresh()
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.state_changed.connect(_on_state_changed)
	if RadioManager != null:
		RadioManager.station_changed.connect(_on_radio_changed)
		RadioManager.radio_toggled.connect(_on_radio_toggled)


func _on_radio_changed(_station: RadioStation) -> void:
	_refresh()


func _on_radio_toggled(_is_on: bool) -> void:
	_refresh()


func _process(_delta: float) -> void:
	if _visible_overlay:
		_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed:
		return

	var code: Key = key_event.keycode
	if code == KEY_NONE:
		code = key_event.physical_keycode

	match code:
		KEY_F1:
			_visible_overlay = not _visible_overlay
			_panel.visible = _visible_overlay
			get_viewport().set_input_as_handled()
		KEY_F2:
			GameManager.add_score(CHEAT_SCORE_AMOUNT)
			get_viewport().set_input_as_handled()
		KEY_F3:
			GameManager.game_over()
			get_viewport().set_input_as_handled()
		KEY_F4:
			get_tree().paused = false
			GameManager.start_game()
			get_viewport().set_input_as_handled()
		KEY_P:
			_toggle_pause()
			get_viewport().set_input_as_handled()
		KEY_R:
			_regenerate_city()
			get_viewport().set_input_as_handled()
		KEY_F5:
			_toggle_collision_debug()
			get_viewport().set_input_as_handled()
		KEY_F6:
			_toggle_city_debug_overlay()
			get_viewport().set_input_as_handled()


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.position = Vector2(12, 12)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.75)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	_panel.add_theme_stylebox_override("panel", style)

	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color(0.85, 0.95, 0.85))
	_panel.add_child(_label)

	add_child(_panel)


func _toggle_pause() -> void:
	if GameManager.state == GameManager.GameState.PAUSED:
		GameManager.resume_game()
	elif GameManager.state == GameManager.GameState.PLAYING:
		GameManager.pause_game()


func _regenerate_city() -> void:
	var main := get_tree().get_first_node_in_group("main_game")
	if main != null and main.has_method("regenerate_city"):
		main.regenerate_city()


func _toggle_collision_debug() -> void:
	get_tree().debug_collisions_hint = not get_tree().debug_collisions_hint


## Cicla overlay: bounds → bounds+colliders → off.
func _toggle_city_debug_overlay() -> void:
	var city := get_tree().get_first_node_in_group("city_generator") as CityGenerator
	if city == null:
		return
	if city.show_bounds_overlay and not city.show_collider_overlay:
		city.show_collider_overlay = true
	elif city.show_bounds_overlay and city.show_collider_overlay:
		city.show_bounds_overlay = false
		city.show_collider_overlay = false
	else:
		city.show_bounds_overlay = true
		city.show_collider_overlay = false
	var debug_draw := city.get_node_or_null("DebugDraw") as Node2D
	if debug_draw != null:
		debug_draw.queue_redraw()


func _on_score_changed(_score: int) -> void:
	_refresh()


func _on_state_changed(_state: GameManager.GameState) -> void:
	_refresh()


func _refresh() -> void:
	if _label == null:
		return

	var state_name: String = GameManager.GameState.keys()[GameManager.state]
	var speed_text := "Speed: --"
	var seed_text := "Seed: --"

	var car := get_tree().get_first_node_in_group("player_car") as CarController
	if car != null:
		speed_text = "Speed: %.0f  Throttle: %.0f" % [absf(car.current_speed), car.debug_throttle]

	var main := get_tree().get_first_node_in_group("main_game")
	if main != null and main.has_method("get_city_seed"):
		seed_text = "Seed: %d" % main.get_city_seed()

	var collisions_on := get_tree().debug_collisions_hint
	var city := get_tree().get_first_node_in_group("city_generator") as CityGenerator
	var overlay_mode := "off"
	if city != null:
		if city.show_bounds_overlay and city.show_collider_overlay:
			overlay_mode = "bounds+colliders"
		elif city.show_bounds_overlay:
			overlay_mode = "bounds"
		elif city.show_collider_overlay:
			overlay_mode = "colliders"

	_label.text = "\n".join([
		"DEBUG CITY",
		"State: %s" % state_name,
		speed_text,
		seed_text,
		"Radio: %s" % RadioManager.get_station_label(),
		"Physics shapes: %s" % str(collisions_on),
		"Overlay: %s" % overlay_mode,
		"FPS: %.0f" % Engine.get_frames_per_second(),
		"",
		"RED downtown | ORANGE residential | GRAY industrial",
		"GREEN park/plaza (driveable) | BLUE-GRAY avenue",
		"Trees/bushes denser in green districts (Perlin)",
		"",
		"[ ] radio | 1-5 station | M mute",
		"F1 HUD | F5 physics | F6 overlay | R regen",
		"WASD drive — evade the police",
	])

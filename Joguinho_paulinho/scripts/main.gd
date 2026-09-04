extends Node3D

func _ready() -> void:
	_build_atmosphere()
	_ensure_actions()
	var plaza := Node3D.new()
	plaza.set_script(preload("res://scripts/plaza.gd"))
	add_child(plaza)
	var player := preload("res://scenes/player.tscn").instantiate()
	player.position = Vector3(0, 0.1, 11.5)
	add_child(player)
	var hud := CanvasLayer.new()
	hud.set_script(preload("res://scripts/hud.gd"))
	add_child(hud)
	if "--capture" in OS.get_cmdline_args() or "--capture" in OS.get_cmdline_user_args():
		_run_capture()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and GameState.phase == GameState.Phase.TITLE:
		GameState.start_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		if GameState.phase == GameState.Phase.PLAY or GameState.phase == GameState.Phase.PAUSE:
			GameState.toggle_pause()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and GameState.is_talking():
		GameState.close_dialogue()
		get_viewport().set_input_as_handled()


func _build_atmosphere() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.98, 0.48, 0.22)
	sky_mat.sky_horizon_color = Color(1.0, 0.72, 0.46)
	sky_mat.ground_bottom_color = Color(0.18, 0.14, 0.1)
	sky_mat.ground_horizon_color = Color(0.72, 0.42, 0.28)
	sky_mat.sun_angle_max = 18.0
	sky_mat.sun_curve = 0.12
	sky.sky_material = sky_mat
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.glow_enabled = true
	environment.glow_intensity = 0.35
	environment.glow_bloom = 0.12
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.95, 0.62, 0.38)
	environment.fog_density = 0.012
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 1.12
	env.environment = environment
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, 42, 0)
	sun.light_color = Color(1.0, 0.82, 0.58)
	sun.light_energy = 1.45
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 48.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, -120, 0)
	fill.light_color = Color(0.45, 0.55, 0.85)
	fill.light_energy = 0.28
	fill.shadow_enabled = false
	add_child(fill)


func _run_capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var title_shot := get_viewport().get_texture().get_image()
	var title_path := ProjectSettings.globalize_path("res://tools/capture_title.png")
	var title_err := title_shot.save_png(title_path)
	print("capture title ", title_err, " ", title_path)
	GameState.start_game()
	await get_tree().create_timer(2.4).timeout
	var play_path := ProjectSettings.globalize_path("res://tools/capture_play.png")
	var play_err := get_viewport().get_texture().get_image().save_png(play_path)
	print("capture play ", play_err, " ", play_path)
	get_tree().quit()


func _ensure_actions() -> void:
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("move_forward", [KEY_W, KEY_UP])
	_bind("move_back", [KEY_S, KEY_DOWN])
	_bind_one("jump", KEY_SPACE)
	_bind_one("interact", KEY_E)
	_bind_one("pause", KEY_ESCAPE)


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)


func _bind_one(action: String, key: Key) -> void:
	_bind(action, [key])

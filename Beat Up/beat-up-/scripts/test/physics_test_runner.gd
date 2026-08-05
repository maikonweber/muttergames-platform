extends Node2D
## Physics / bounds test harness for the isometric city + car.
## Open scenes/test_physics.tscn and press F6 (Run Current Scene).

const CAR_SCENE := preload("res://scenes/car.tscn")
const FIXED_SEED := 42

@onready var city_map: CityGenerator = $CityMap
@onready var results_label: Label = $UI/Panel/Margin/Results

var car: CarController
var _lines: PackedStringArray = []
var _passed: int = 0
var _failed: int = 0
var _running: bool = false


func _ready() -> void:
	_ensure_input_actions()
	add_to_group("main_game")
	RenderingServer.set_default_clear_color(Color(0.08, 0.09, 0.11))
	get_tree().debug_collisions_hint = true

	city_map.seed_value = FIXED_SEED
	city_map.regenerate(FIXED_SEED)

	car = CAR_SCENE.instantiate() as CarController
	add_child(car)
	_place_car()

	GameManager.start_game()
	_log("TEST SETUP — seed %d" % FIXED_SEED)
	_log("Collision shapes: ON (debug_collisions_hint)")
	_log("WASD to drive | T re-run tests | Esc quit")
	_refresh_ui()

	await get_tree().physics_frame
	await get_tree().physics_frame
	await _run_all_tests()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_T:
				if not _running:
					_run_all_tests()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				get_tree().quit()
				get_viewport().set_input_as_handled()


func regenerate_city(p_seed: int = 0) -> void:
	city_map.regenerate(p_seed if p_seed != 0 else FIXED_SEED)
	_place_car()


func get_car() -> CarController:
	return car


func get_city_seed() -> int:
	return city_map.last_seed


func _place_car() -> void:
	if car == null:
		return
	car.bind_to_city(city_map)
	car.set_spawn(city_map.get_spawn_position())
	car.rotation = 0.0
	car.snap_camera()


func _run_all_tests() -> void:
	_running = true
	_passed = 0
	_failed = 0
	_lines.clear()
	_log("— Running automated checks —")

	_place_car()
	await get_tree().physics_frame
	await get_tree().physics_frame

	_test_spawn_on_road()
	_test_world_collision_exists()
	_test_car_collision_layers()
	_test_play_bounds_valid()
	await _test_building_blocks_car()
	await _test_bounds_clamp()
	await _test_stays_on_road_when_driving()

	_log("")
	_log("RESULT: %d passed, %d failed" % [_passed, _failed])
	if _failed == 0:
		_log("ALL TESTS PASSED")
	else:
		_log("SOME TESTS FAILED")
	_refresh_ui()
	_running = false


func _test_spawn_on_road() -> void:
	var ok := city_map.is_drivable(car.global_position)
	_assert(ok, "Spawn is on drivable road", "spawn at %s" % car.global_position)


func _test_world_collision_exists() -> void:
	var body := city_map.get_node_or_null("WorldCollision") as StaticBody2D
	if body == null:
		_assert(false, "WorldCollision StaticBody2D exists", "missing node")
		return
	var shape_count := body.get_child_count()
	_assert(shape_count > 4, "WorldCollision has building+border shapes", "count=%d" % shape_count)
	_assert(body.collision_layer == 1, "WorldCollision layer is buildings(1)", "layer=%d" % body.collision_layer)


func _test_car_collision_layers() -> void:
	_assert(car.collision_layer == 2, "Car collision_layer=2", "layer=%d" % car.collision_layer)
	_assert(car.collision_mask == 1, "Car collision_mask=1 (hits buildings)", "mask=%d" % car.collision_mask)
	var shape := car.get_node_or_null("CollisionShape2D") as CollisionShape2D
	_assert(shape != null and shape.shape != null and not shape.disabled, "Car has active CollisionShape2D", "")


func _test_play_bounds_valid() -> void:
	var b := city_map.get_play_bounds()
	_assert(b.size.x > 100.0 and b.size.y > 100.0, "Play bounds have area", "size=%s" % b.size)
	_assert(b.has_point(car.global_position), "Spawn inside play bounds", "pos=%s bounds=%s" % [car.global_position, b])


func _test_building_blocks_car() -> void:
	_place_car()
	await get_tree().physics_frame

	var building_pos := _find_nearby_building_world_pos()
	if building_pos == Vector2.INF:
		_assert(false, "Found a building cell near spawn for collision probe", "none found")
		return

	var start := car.global_position
	car.global_position = building_pos
	car.velocity = Vector2.ZERO
	car.current_speed = 0.0
	await get_tree().physics_frame
	await get_tree().physics_frame

	# Force a shove into the building collider from the road side.
	car.global_position = start
	var dir := (building_pos - start).normalized()
	car.velocity = dir * 600.0
	car.current_speed = 600.0
	for i in 8:
		car.move_and_slide()
		await get_tree().physics_frame

	var still_on_building := not city_map.is_drivable(car.global_position) \
			and city_map.get_play_bounds().has_point(car.global_position)
	var hit_wall := car.get_slide_collision_count() > 0
	var blocked := hit_wall or city_map.is_drivable(car.global_position) or car.global_position.distance_to(building_pos) > 24.0

	_assert(
		blocked and not (still_on_building and car.global_position.distance_to(building_pos) < 8.0),
		"Car is blocked by building collision",
		"pos=%s building=%s slides=%d" % [car.global_position, building_pos, car.get_slide_collision_count()]
	)
	_place_car()
	await get_tree().physics_frame


func _test_bounds_clamp() -> void:
	_place_car()
	await get_tree().physics_frame

	var bounds := city_map.get_play_bounds()
	car.global_position = Vector2(bounds.position.x - 200.0, bounds.position.y - 200.0)
	car.force_constrain_for_test()
	await get_tree().physics_frame

	var inside := bounds.has_point(car.global_position)
	_assert(inside, "Out-of-bounds position is clamped into play area", "pos=%s" % car.global_position)
	_place_car()
	await get_tree().physics_frame


func _test_stays_on_road_when_driving() -> void:
	_place_car()
	await get_tree().physics_frame

	car.facing = 0.0
	car.current_speed = 180.0
	car.velocity = Vector2.RIGHT * 180.0
	for i in 20:
		car.move_and_slide()
		car.force_constrain_for_test()
		await get_tree().physics_frame

	_assert(
		city_map.is_drivable(car.global_position),
		"After drive burst car remains on drivable road",
		"pos=%s" % car.global_position
	)
	_place_car()


func _find_nearby_building_world_pos() -> Vector2:
	var spawn_local := city_map.tile_map.to_local(city_map.get_spawn_position())
	var origin := city_map.tile_map.local_to_map(spawn_local)
	for radius in range(1, 12):
		for ox in range(-radius, radius + 1):
			for oy in range(-radius, radius + 1):
				var cell := origin + Vector2i(ox, oy)
				if city_map.tile_map.get_cell_atlas_coords(cell) == CityGenerator.TILE_BUILDING:
					return city_map.to_global(city_map.tile_map.map_to_local(cell))
	return Vector2.INF


func _assert(condition: bool, title: String, detail: String) -> void:
	if condition:
		_passed += 1
		_log("[PASS] %s" % title)
	else:
		_failed += 1
		if detail.is_empty():
			_log("[FAIL] %s" % title)
		else:
			_log("[FAIL] %s (%s)" % [title, detail])
	_refresh_ui()


func _log(msg: String) -> void:
	_lines.append(msg)
	print("[PhysicsTest] ", msg)


func _refresh_ui() -> void:
	if results_label != null:
		results_label.text = "\n".join(_lines)


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
		var exists := false
		for existing in InputMap.action_get_events(action):
			if existing is InputEventKey and existing.physical_keycode == event.physical_keycode:
				exists = true
				break
		if not exists:
			InputMap.action_add_event(action, event)

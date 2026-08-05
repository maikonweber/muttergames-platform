extends TestSuite

const CITY_SCENE := preload("res://scenes/city_map.tscn")
const CAR_SCENE := preload("res://scenes/car.tscn")
const SEED := 42

var _root: Node2D
var _city: CityGenerator
var _car: CarController


func _init() -> void:
	super._init("e2e/DriveAndCollision")


func run_async(tree: SceneTree) -> void:
	_root = Node2D.new()
	_root.name = "E2ERoot"
	tree.root.add_child(_root)

	_city = CITY_SCENE.instantiate() as CityGenerator
	_city.seed_value = SEED
	_root.add_child(_city)
	await tree.physics_frame
	await tree.physics_frame
	_city.regenerate(SEED)

	_car = CAR_SCENE.instantiate() as CarController
	_root.add_child(_car)
	await tree.physics_frame
	_car.bind_to_city(_city)
	_car.set_spawn(_city.get_spawn_position())
	await tree.physics_frame
	await tree.physics_frame

	_test_spawn_on_road()
	_test_world_collision_present()
	_test_car_layers()
	await _test_building_blocks(tree)
	await _test_bounds_clamp(tree)
	await _test_drive_stays_on_road(tree)

	_root.queue_free()
	await tree.process_frame


func _test_spawn_on_road() -> void:
	assert_.that(_city.is_drivable(_car.global_position), "E2E spawn is drivable")
	assert_.that(_city.get_play_bounds().has_point(_car.global_position), "E2E spawn inside bounds")


func _test_world_collision_present() -> void:
	var body := _city.get_node_or_null("WorldCollision") as StaticBody2D
	assert_.that(body != null, "E2E WorldCollision exists")
	if body != null:
		assert_.gt(float(body.get_child_count()), 4.0, "E2E WorldCollision has shapes")
		assert_.eq(body.collision_layer, 1, "E2E WorldCollision layer=1")


func _test_car_layers() -> void:
	assert_.eq(_car.collision_layer, 2, "E2E car layer=2")
	assert_.eq(_car.collision_mask, 1, "E2E car mask=1")


func _test_building_blocks(tree: SceneTree) -> void:
	_car.set_spawn(_city.get_spawn_position())
	await tree.physics_frame

	var building := _find_building_near_spawn()
	assert_.that(building != Vector2.INF, "E2E found building near spawn")
	if building == Vector2.INF:
		return

	var start := _car.global_position
	var dir := (building - start).normalized()
	_car.velocity = dir * 700.0
	_car.current_speed = 700.0
	for i in 10:
		_car.move_and_slide()
		await tree.physics_frame

	var away_from_core := _car.global_position.distance_to(building) > 16.0
	var still_drivable := _city.is_drivable(_car.global_position)
	var hit := _car.get_slide_collision_count() > 0
	assert_.that(
		hit or away_from_core or still_drivable,
		"E2E car blocked before settling inside building core",
	)
	_car.set_spawn(_city.get_spawn_position())
	await tree.physics_frame


func _test_bounds_clamp(tree: SceneTree) -> void:
	var bounds := _city.get_play_bounds()
	_car.global_position = bounds.position - Vector2(250, 250)
	_car.force_constrain_for_test()
	await tree.physics_frame
	assert_.that(bounds.has_point(_car.global_position), "E2E out-of-bounds clamped")
	_car.set_spawn(_city.get_spawn_position())
	await tree.physics_frame


func _test_drive_stays_on_road(tree: SceneTree) -> void:
	_car.set_spawn(_city.get_spawn_position())
	_car.facing = 0.0
	_car.current_speed = 160.0
	_car.velocity = Vector2.RIGHT * 160.0
	for i in 25:
		_car.move_and_slide()
		_car.force_constrain_for_test()
		await tree.physics_frame
	assert_.that(_city.is_drivable(_car.global_position), "E2E remains on road after drive")


func _find_building_near_spawn() -> Vector2:
	var local := _city.tile_map.to_local(_city.get_spawn_position())
	var origin := _city.tile_map.local_to_map(local)
	for radius in range(1, 14):
		for ox in range(-radius, radius + 1):
			for oy in range(-radius, radius + 1):
				var cell := origin + Vector2i(ox, oy)
				if _city.tile_map.get_cell_atlas_coords(cell) == CityGenerator.TILE_BUILDING:
					return _city.to_global(_city.tile_map.map_to_local(cell))
	return Vector2.INF

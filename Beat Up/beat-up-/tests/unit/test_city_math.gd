extends TestSuite

const CityMath = preload("res://scripts/world/city_math.gd")

func _init() -> void:
	super._init("unit/CityMath")


func run() -> void:
	_test_map_size()
	_test_street_axis()
	_test_intersection_and_road()
	_test_spawn_cell()
	_test_clamp_point()
	_test_drivable_atlas()
	_test_tighten_bounds()


func _test_map_size() -> void:
	assert_.eq(CityMath.map_size_cells(8, 4, 2), Vector2i(50, 50), "8x4 blocks + streets => 50 cells")
	assert_.eq(CityMath.map_size_cells(1, 4, 2), Vector2i(8, 8), "1 block grid size")


func _test_street_axis() -> void:
	var stride := CityMath.stride(4, 2)
	assert_.eq(stride, 6, "stride = block+street")
	assert_.that(CityMath.is_street_axis(0, stride, 2), "coord 0 is street")
	assert_.that(CityMath.is_street_axis(1, stride, 2), "coord 1 is street")
	assert_.that(not CityMath.is_street_axis(2, stride, 2), "coord 2 is block")
	assert_.that(CityMath.is_street_axis(6, stride, 2), "next street row starts at 6")


func _test_intersection_and_road() -> void:
	var stride := 6
	assert_.that(CityMath.is_intersection(0, 0, stride, 2), "0,0 intersection")
	assert_.that(CityMath.is_road_cell(0, 5, stride, 2), "vertical street is road")
	assert_.that(CityMath.is_road_cell(5, 0, stride, 2), "horizontal street is road")
	assert_.that(not CityMath.is_road_cell(3, 3, stride, 2), "block interior is not road")


func _test_spawn_cell() -> void:
	assert_.eq(CityMath.spawn_cell(2), Vector2i(1, 1), "spawn near street center")
	assert_.eq(CityMath.spawn_cell(3), Vector2i(1, 1), "spawn for odd street width")


func _test_clamp_point() -> void:
	var bounds := Rect2(0, 0, 100, 50)
	assert_.approx_vec(CityMath.clamp_point(Vector2(10, 10), bounds), Vector2(10, 10), "inside unchanged")
	assert_.approx_vec(CityMath.clamp_point(Vector2(-5, 200), bounds), Vector2(0, 50), "outside clamped")
	assert_.approx_vec(CityMath.clamp_point(Vector2(3, 3), Rect2()), Vector2(3, 3), "empty bounds no-op")


func _test_drivable_atlas() -> void:
	assert_.that(CityMath.is_drivable_atlas(Vector2i(0, 0)), "road atlas drivable")
	assert_.that(CityMath.is_drivable_atlas(Vector2i(2, 0)), "crosswalk atlas drivable")
	assert_.that(CityMath.is_drivable_atlas(Vector2i(3, 0)), "avenue atlas drivable")
	assert_.that(CityMath.is_drivable_atlas(Vector2i(4, 0)), "park atlas drivable")
	assert_.that(not CityMath.is_drivable_atlas(Vector2i(1, 0)), "building atlas not drivable")
	assert_.that(CityMath.is_building_atlas(Vector2i(5, 0)), "residential is building")
	assert_.that(CityMath.is_building_atlas(Vector2i(6, 0)), "industrial is building")


func _test_tighten_bounds() -> void:
	var rect := CityMath.tighten_bounds(Vector2(0, 0), Vector2(100, 100), Vector2(10, 10))
	assert_.approx_vec(rect.position, Vector2(10, 10), "tightened origin")
	assert_.approx_vec(rect.size, Vector2(80, 80), "tightened size")

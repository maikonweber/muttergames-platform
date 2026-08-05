extends TestSuite

const CarMath = preload("res://scripts/vehicle/car_math.gd")

func _init() -> void:
	super._init("unit/CarMath")


func run() -> void:
	_test_target_speed()
	_test_integrate_speed()
	_test_integrate_facing()
	_test_velocity()
	_test_axis()


func _test_target_speed() -> void:
	assert_.approx(CarMath.target_speed(1.0, 280.0, 110.0), 280.0, "full throttle")
	assert_.approx(CarMath.target_speed(-1.0, 280.0, 110.0), -110.0, "full reverse")
	assert_.approx(CarMath.target_speed(0.0, 280.0, 110.0), 0.0, "neutral")


func _test_integrate_speed() -> void:
	var accelerated := CarMath.integrate_speed(0.0, 1.0, 280.0, 110.0, 520.0, 420.0, 0.1)
	assert_.approx(accelerated, 52.0, "accel 520 * 0.1")

	var coast := CarMath.integrate_speed(100.0, 0.0, 280.0, 110.0, 520.0, 420.0, 0.1)
	assert_.approx(coast, 58.0, "friction 420 * 0.1 from 100")


func _test_integrate_facing() -> void:
	var stopped := CarMath.integrate_facing(0.0, 1.0, 0.0, 280.0, 3.2, 12.0, 0.1)
	assert_.approx(stopped, 0.0, "no turn when stopped")

	var turning := CarMath.integrate_facing(0.0, 1.0, 280.0, 280.0, 3.2, 12.0, 0.1)
	assert_.approx(turning, 0.32, "full-speed turn")


func _test_velocity() -> void:
	assert_.approx_vec(CarMath.velocity_from_facing(0.0, 100.0), Vector2(100, 0), "facing east")
	var northish := CarMath.velocity_from_facing(-PI * 0.5, 50.0)
	assert_.approx(northish.x, 0.0, "facing -90deg x~0", 0.01)
	assert_.approx(northish.y, -50.0, "facing -90deg y~-speed", 0.01)


func _test_axis() -> void:
	assert_.approx(CarMath.axis_from_bools(true, false), 1.0, "positive only")
	assert_.approx(CarMath.axis_from_bools(false, true), -1.0, "negative only")
	assert_.approx(CarMath.axis_from_bools(true, true), 0.0, "both cancel")
	assert_.approx(CarMath.axis_from_bools(false, false), 0.0, "none")

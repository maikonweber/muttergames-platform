extends SceneTree
## Headless entry:
## godot --headless --path . -s res://tests/run_all.gd


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var suites: Array = [
		load("res://tests/unit/test_city_math.gd").new(),
		load("res://tests/unit/test_car_math.gd").new(),
		load("res://tests/e2e/test_drive_and_collision.gd").new(),
	]

	var total_passed := 0
	var total_failed := 0

	print("========================================")
	print(" Beat Up — Unit + E2E tests")
	print("========================================")

	for suite in suites:
		print("")
		print(">> ", suite.name)
		await suite.run_async(self)
		total_passed += suite.assert_.passed
		total_failed += suite.assert_.failed
		print("   passed=%d failed=%d" % [suite.assert_.passed, suite.assert_.failed])
		for failure in suite.assert_.failures:
			print("   - ", failure)

	print("")
	print("========================================")
	print(" TOTAL: %d passed, %d failed" % [total_passed, total_failed])
	print("========================================")

	quit(0 if total_failed == 0 else 1)

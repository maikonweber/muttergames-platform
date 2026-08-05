extends Node
## Open scenes/test_runner.tscn and press F6.


func _ready() -> void:
	var suites: Array = [
		load("res://tests/unit/test_city_math.gd").new(),
		load("res://tests/unit/test_car_math.gd").new(),
		load("res://tests/e2e/test_drive_and_collision.gd").new(),
	]

	var passed := 0
	var failed := 0

	print("========================================")
	print(" Beat Up — Unit + E2E (editor)")
	print("========================================")

	for suite in suites:
		print("")
		print(">> ", suite.name)
		await suite.run_async(get_tree())
		passed += suite.assert_.passed
		failed += suite.assert_.failed
		print("   passed=%d failed=%d" % [suite.assert_.passed, suite.assert_.failed])
		for failure in suite.assert_.failures:
			print("   - ", failure)

	print("")
	print("TOTAL: %d passed, %d failed" % [passed, failed])
	if failed > 0:
		push_error("Test run failed")
	else:
		print("ALL TESTS PASSED")

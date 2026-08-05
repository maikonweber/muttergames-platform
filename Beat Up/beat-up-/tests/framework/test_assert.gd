extends RefCounted
class_name TestAssert

var passed: int = 0
var failed: int = 0
var failures: PackedStringArray = []


func that(condition: bool, message: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		failures.append(message)
		push_error("[FAIL] %s" % message)


func eq(actual: Variant, expected: Variant, message: String) -> void:
	that(actual == expected, "%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func approx(actual: float, expected: float, message: String, eps: float = 0.001) -> void:
	that(absf(actual - expected) <= eps, "%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func approx_vec(actual: Vector2, expected: Vector2, message: String, eps: float = 0.05) -> void:
	that(actual.distance_to(expected) <= eps, "%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func gt(actual: float, minimum: float, message: String) -> void:
	that(actual > minimum, "%s (expected > %s, got %s)" % [message, str(minimum), str(actual)])


func total() -> int:
	return passed + failed

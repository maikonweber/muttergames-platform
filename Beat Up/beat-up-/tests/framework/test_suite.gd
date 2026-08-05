extends RefCounted
class_name TestSuite

var name: String = ""
var assert_: TestAssert = TestAssert.new()


func _init(p_name: String = "") -> void:
	name = p_name


func run() -> void:
	pass


func run_async(tree: SceneTree) -> void:
	run()
	await tree.process_frame

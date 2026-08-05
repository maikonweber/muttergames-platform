extends Node2D
## Short slash arc VFX at world position.


static func spawn(parent: Node, global_pos: Vector2, angle: float = 0.0) -> void:
	var script_res: GDScript = load("res://scripts/combat/slash_vfx.gd") as GDScript
	var n: Node2D = script_res.new() as Node2D
	parent.add_child(n)
	n.global_position = global_pos
	n.rotation = angle
	n.call("_play")


func _play() -> void:
	var spr := Sprite2D.new()
	spr.centered = true
	if ResourceLoader.exists("res://assets/vfx/slash_arc.png"):
		spr.texture = load("res://assets/vfx/slash_arc.png")
	else:
		var poly := Line2D.new()
		poly.width = 4.0
		poly.default_color = Color(0.85, 0.95, 1.0, 0.9)
		poly.points = PackedVector2Array([
			Vector2(-28, 12), Vector2(-10, -18), Vector2(18, -22), Vector2(32, 4)
		])
		add_child(poly)
		var tw0 := create_tween()
		tw0.tween_property(poly, "modulate:a", 0.0, 0.28)
		tw0.tween_callback(queue_free)
		return
	spr.modulate = Color(1, 1, 1, 0.95)
	spr.scale = Vector2(0.55, 0.55)
	add_child(spr)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(spr, "scale", Vector2(0.95, 0.95), 0.18).set_ease(Tween.EASE_OUT)
	tw.tween_property(spr, "modulate:a", 0.0, 0.28).set_delay(0.08)
	await tw.finished
	queue_free()

class_name FloatingText
extends Node2D
## Damage / block / heal popup over units.


static func spawn(parent: Node, world_pos: Vector2, text: String, color: Color, rise: float = 28.0) -> void:
	var ft := FloatingText.new()
	parent.add_child(ft)
	ft.global_position = world_pos
	ft._run(text, color, rise)


func _run(text: String, color: Color, rise: float) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 4)
	label.position = Vector2(-40, -10)
	label.custom_minimum_size = Vector2(80, 20)
	add_child(label)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position", position + Vector2(0, -rise), 0.55).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 0.55).set_delay(0.15)
	await tw.finished
	queue_free()

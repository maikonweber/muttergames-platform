class_name VfxBurst
extends Sprite2D

@export var duration := 0.55
@export var initial_scale := 0.05
@export var final_scale := 0.18
@export var rotation_speed := 0.45

var _elapsed := 0.0

func play_burst(at_position: Vector2) -> void:
	position = at_position
	_elapsed = 0.0
	visible = true
	modulate = Color.WHITE
	scale = Vector2.ONE * initial_scale

func _process(delta: float) -> void:
	if not visible:
		return
	_elapsed += delta
	var progress := clampf(_elapsed / duration, 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - progress, 3.0)
	scale = Vector2.ONE * lerpf(initial_scale, final_scale, eased)
	rotation += rotation_speed * delta
	modulate.a = 1.0 - progress
	if progress >= 1.0:
		visible = false

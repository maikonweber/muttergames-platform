class_name CombatFx
extends RefCounted
## Lightweight combat juice without final art.

const _FloatingTextScript = preload("res://scripts/combat/floating_text.gd")


static func floating(parent: Node, pos: Vector2, text: String, color: Color) -> void:
	_FloatingTextScript.spawn(parent, pos, text, color)


static func damage_number(parent: Node, pos: Vector2, amount: int, blocked: bool = false) -> void:
	if amount <= 0 and blocked:
		floating(parent, pos, "BLOCK", Color("7eb6ff"))
	elif amount <= 0:
		floating(parent, pos, "0", Color("aaaaaa"))
	else:
		floating(parent, pos + Vector2(randf_range(-6, 6), 0), str(-amount), Color("ff6b5a"))


static func heal_number(parent: Node, pos: Vector2, amount: int) -> void:
	floating(parent, pos, "+%d" % amount, Color("6dffa0"))


static func miss_or_parry(parent: Node, pos: Vector2, kind: String = "PARRY") -> void:
	floating(parent, pos, kind, Color("ffe08a"))


static func status(parent: Node, pos: Vector2, text: String) -> void:
	floating(parent, pos, text, Color("e0a8ff"))


static func slash(parent: Node, from_pos: Vector2, to_pos: Vector2) -> void:
	var mid := (from_pos + to_pos) * 0.5 + Vector2(0, -18)
	var angle := (to_pos - from_pos).angle()
	var slash_script: GDScript = load("res://scripts/combat/slash_vfx.gd") as GDScript
	if slash_script == null or parent == null:
		return
	var n: Node2D = slash_script.new() as Node2D
	parent.add_child(n)
	n.global_position = mid
	n.rotation = angle
	if n.has_method("_play"):
		n.call("_play")
	if Engine.has_singleton("AudioBus") or parent.get_tree():
		var ab := parent.get_node_or_null("/root/AudioBus")
		if ab and ab.has_method("slash"):
			ab.slash()


static func impact(parent: Node, pos: Vector2, kind: String = "hit") -> void:
	var script_res: GDScript = load("res://scripts/combat/impact_vfx.gd") as GDScript
	if script_res == null or parent == null:
		return
	var n: Node2D = script_res.new() as Node2D
	parent.add_child(n)
	n.global_position = pos
	if n.has_method("_play"):
		n.call("_play", kind)
	var ab := parent.get_node_or_null("/root/AudioBus")
	if ab == null:
		return
	match kind:
		"block":
			if ab.has_method("block"):
				ab.block()
		"parry":
			if ab.has_method("parry"):
				ab.parry()
		"death":
			if ab.has_method("death"):
				ab.death()
		_:
			if ab.has_method("hit"):
				ab.hit()

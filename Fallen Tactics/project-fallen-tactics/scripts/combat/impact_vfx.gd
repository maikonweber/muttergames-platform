extends Node2D
## Block / parry / death burst VFX (procedural).


func _play(kind: String) -> void:
	var col := Color("ff6b5a")
	var scale0 := 0.4
	match kind:
		"block":
			col = Color("7eb6ff")
			scale0 = 0.5
		"parry":
			col = Color("ffe08a")
			scale0 = 0.55
		"death":
			col = Color("c9a0ff")
			scale0 = 0.7
		_:
			col = Color("ff8a7a")
	# ring
	var ring := Line2D.new()
	ring.width = 3.0
	ring.default_color = col
	var pts: PackedVector2Array = []
	var r := 10.0
	for i in 17:
		var a := TAU * float(i) / 16.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	ring.points = pts
	add_child(ring)
	# sparks
	for i in 5:
		var spark := Line2D.new()
		spark.width = 2.0
		spark.default_color = col
		var ang := randf() * TAU
		var len := 12.0 + randf() * 16.0
		spark.points = PackedVector2Array([Vector2.ZERO, Vector2(cos(ang), sin(ang)) * len])
		add_child(spark)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(scale0 + 0.8, scale0 + 0.8), 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 0.0, 0.28)
	await tw.finished
	queue_free()

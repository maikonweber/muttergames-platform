extends Area3D

@export var kind: String = "limao"

var _spin: float = 0.0
var _taken: bool = false
var _visual: Node3D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	_visual = Node3D.new()
	add_child(_visual)
	_build_visual()
	_spin = randf() * TAU
	GameState.register_pickup(kind)


func _process(delta: float) -> void:
	if _taken:
		return
	_spin += delta * 2.2
	_visual.rotation.y = _spin
	_visual.position.y = 0.35 + sin(_spin * 2.0) * 0.08


func _build_visual() -> void:
	match kind:
		"gelo":
			_ice()
		"tampinha":
			_cap()
		_:
			_lime()


func _lime() -> void:
	var fruit := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.38
	fruit.mesh = sphere
	fruit.material_override = _mat(Color(0.62, 0.86, 0.18), 0.45)
	_visual.add_child(fruit)
	var leaf := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.12, 0.03, 0.07)
	leaf.mesh = box
	leaf.position = Vector3(0.08, 0.14, 0.0)
	leaf.rotation = Vector3(0.2, 0.4, 0.6)
	leaf.material_override = _mat(Color(0.22, 0.48, 0.16), 0.7)
	_visual.add_child(leaf)


func _ice() -> void:
	var cube := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.28, 0.28, 0.28)
	cube.mesh = box
	cube.rotation = Vector3(0.4, 0.5, 0.2)
	var mat := _mat(Color(0.78, 0.93, 1.0, 0.72), 0.08)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.metallic = 0.15
	cube.material_override = mat
	_visual.add_child(cube)


func _cap() -> void:
	var cap := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.18
	cyl.bottom_radius = 0.18
	cyl.height = 0.06
	cap.mesh = cyl
	cap.material_override = _mat(Color(0.86, 0.68, 0.16), 0.25, 0.7)
	_visual.add_child(cap)
	var emblem := MeshInstance3D.new()
	var decal := CylinderMesh.new()
	decal.top_radius = 0.07
	decal.bottom_radius = 0.07
	decal.height = 0.02
	emblem.mesh = decal
	emblem.position.y = 0.03
	emblem.material_override = _mat(Color(0.75, 0.18, 0.18), 0.5)
	_visual.add_child(emblem)


func _mat(color: Color, roughness: float = 0.6, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


func _on_body_entered(body: Node) -> void:
	if _taken or GameState.phase != GameState.Phase.PLAY:
		return
	if not body.is_in_group("player"):
		return
	_taken = true
	GameState.collect(kind)
	_burst()
	var sfx := AudioStreamPlayer3D.new()
	sfx.stream = load("res://assets/sfx_collect.wav")
	sfx.volume_db = -4.0
	add_child(sfx)
	sfx.play()
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector3.ZERO, 0.18).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(queue_free)


func _burst() -> void:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = 16
	particles.lifetime = 0.45
	particles.explosiveness = 1.0
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 70.0
	mat.initial_velocity_min = 1.4
	mat.initial_velocity_max = 3.2
	mat.gravity = Vector3(0, -4, 0)
	mat.scale_min = 0.05
	mat.scale_max = 0.12
	match kind:
		"gelo":
			mat.color = Color(0.8, 0.95, 1.0)
		"tampinha":
			mat.color = Color(0.9, 0.72, 0.2)
		_:
			mat.color = Color(0.7, 0.9, 0.25)
	particles.process_material = mat
	var draw := SphereMesh.new()
	draw.radius = 0.06
	draw.height = 0.12
	particles.draw_pass_1 = draw
	add_child(particles)

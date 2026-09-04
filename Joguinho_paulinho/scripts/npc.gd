extends Area3D

@export var npc_name: String = "Amiguinho"
@export var lines: PackedStringArray = PackedStringArray()
@export var body_color: Color = Color(0.75, 0.82, 0.88)
@export var label_color: Color = Color(0.92, 0.88, 0.72)
@export var accent_color: Color = Color(0.72, 0.2, 0.22)

var _index: int = 0
var _player_near: bool = false
var _visual: Node3D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	monitoring = true
	monitorable = true
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	_visual = Node3D.new()
	add_child(_visual)
	_build_bottle()


func _process(delta: float) -> void:
	_visual.position.y = sin(Time.get_ticks_msec() * 0.002 + global_position.x) * 0.03
	_visual.rotation.y += delta * 0.25
	if _player_near and GameState.phase == GameState.Phase.PLAY:
		if Input.is_action_just_pressed("interact"):
			_talk()


func _talk() -> void:
	if lines.is_empty():
		return
	if GameState.is_talking():
		_index = (_index + 1) % lines.size()
		if _index == 0:
			GameState.close_dialogue()
			return
	var sfx := AudioStreamPlayer.new()
	sfx.stream = load("res://assets/sfx_talk.wav")
	sfx.volume_db = -8.0
	add_child(sfx)
	sfx.finished.connect(sfx.queue_free)
	sfx.play()
	GameState.show_dialogue(npc_name, lines[_index])


func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true
		GameState.set_nearby_prompt("E — conversar com %s" % npc_name)


func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
		GameState.set_nearby_prompt("")
		if GameState.is_talking():
			GameState.close_dialogue()
			_index = 0


func _build_bottle() -> void:
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.22
	cyl.bottom_radius = 0.26
	cyl.height = 0.95
	body.mesh = cyl
	body.position.y = 0.55
	body.material_override = _mat(body_color, 0.25, 0.15)
	_visual.add_child(body)

	var neck := MeshInstance3D.new()
	var neck_mesh := CylinderMesh.new()
	neck_mesh.top_radius = 0.08
	neck_mesh.bottom_radius = 0.12
	neck_mesh.height = 0.22
	neck.mesh = neck_mesh
	neck.position.y = 1.12
	neck.material_override = _mat(body_color.darkened(0.1), 0.2, 0.2)
	_visual.add_child(neck)

	var cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.09
	cap_mesh.bottom_radius = 0.09
	cap_mesh.height = 0.08
	cap.mesh = cap_mesh
	cap.position.y = 1.26
	cap.material_override = _mat(accent_color, 0.4)
	_visual.add_child(cap)

	var label := MeshInstance3D.new()
	var label_mesh := BoxMesh.new()
	label_mesh.size = Vector3(0.38, 0.28, 0.02)
	label.mesh = label_mesh
	label.position = Vector3(0.0, 0.62, 0.24)
	label.material_override = _mat(label_color, 0.7)
	_visual.add_child(label)

	var stripe := MeshInstance3D.new()
	var stripe_mesh := BoxMesh.new()
	stripe_mesh.size = Vector3(0.38, 0.06, 0.025)
	stripe.mesh = stripe_mesh
	stripe.position = Vector3(0.0, 0.5, 0.245)
	stripe.material_override = _mat(accent_color, 0.5)
	_visual.add_child(stripe)

	var eye_l := _eye(Vector3(-0.07, 0.88, 0.2))
	var eye_r := _eye(Vector3(0.07, 0.88, 0.2))
	_visual.add_child(eye_l)
	_visual.add_child(eye_r)


func _eye(pos: Vector3) -> MeshInstance3D:
	var eye := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.035
	mesh.height = 0.07
	eye.mesh = mesh
	eye.position = pos
	eye.material_override = _mat(Color(0.12, 0.1, 0.08), 0.4)
	return eye


func _mat(color: Color, roughness: float = 0.5, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

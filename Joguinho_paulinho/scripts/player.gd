extends CharacterBody3D

const PAULINHO_PATH := "res://assets/paulinho/paulinho.glb"

@export var move_speed: float = 5.4
@export var acceleration: float = 22.0
@export var air_control: float = 8.0
@export var jump_velocity: float = 6.4
@export var gravity: float = 18.0
@export var turn_speed: float = 12.0
@export var model_scale: float = 1.72
@export var model_yaw_offset: float = 0.0
@export var mouse_sensitivity: float = 0.0032

@onready var visual: Node3D = $Visual
@onready var model_pivot: Node3D = $Visual/ModelPivot
@onready var spring: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var _walk_phase: float = 0.0
var _look_yaw: float = 0.62
var _look_pitch: float = -0.22
var _can_move: bool = false


func _ready() -> void:
	_spawn_model()
	_look_yaw = rotation.y
	rotation = Vector3.ZERO
	visual.rotation.y = 0.0
	spring.add_excluded_object(get_rid())
	spring.collision_mask = 1
	spring.spring_length = 7.2
	spring.position = Vector3(0.35, 1.42, 0.0)
	GameState.started.connect(_on_started)
	GameState.paused_changed.connect(_on_paused)
	GameState.won.connect(_on_won)
	GameState.dialogue_shown.connect(_on_dialogue_shown)
	GameState.dialogue_closed.connect(_on_dialogue_closed)


func _spawn_model() -> void:
	var packed := load(PAULINHO_PATH) as PackedScene
	if packed == null:
		push_error("Não achei o modelo do Paulinho em %s" % PAULINHO_PATH)
		return
	var model := packed.instantiate() as Node3D
	model_pivot.add_child(model)
	model.scale = Vector3.ONE * model_scale
	model.rotation.y = model_yaw_offset
	_silence_imported_bodies(model)
	_make_shadow()


func _silence_imported_bodies(node: Node) -> void:
	if node is CollisionObject3D:
		var body := node as CollisionObject3D
		body.collision_layer = 0
		body.collision_mask = 0
	for child in node.get_children():
		_silence_imported_bodies(child)


func _make_shadow() -> void:
	var blob := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.42
	mesh.height = 0.08
	blob.mesh = mesh
	blob.position = Vector3(0.0, 0.03, 0.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.04, 0.03, 0.35)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = false
	blob.material_override = mat
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual.add_child(blob)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_move:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		_look_yaw -= motion.relative.x * mouse_sensitivity
		_look_pitch = clampf(_look_pitch - motion.relative.y * mouse_sensitivity, -1.15, 0.15)


func _physics_process(delta: float) -> void:
	spring.rotation.y = _look_yaw
	spring.rotation.x = _look_pitch

	if not is_on_floor():
		velocity.y -= gravity * delta

	var wish := Vector3.ZERO
	if _can_move and not GameState.is_talking():
		var input := Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_back", "move_forward")
		)
		if input.length() > 1.0:
			input = input.normalized()
		var cam_yaw := _look_yaw
		var forward := Vector3.FORWARD.rotated(Vector3.UP, cam_yaw)
		var right := Vector3.RIGHT.rotated(Vector3.UP, cam_yaw)
		wish = (right * input.x + forward * input.y)
		if wish.length() > 0.01:
			wish = wish.normalized()
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			_play("res://assets/sfx_jump.wav")

	var target := wish * move_speed
	var accel := acceleration if is_on_floor() else air_control
	var planar := Vector3(velocity.x, 0.0, velocity.z)
	planar = planar.move_toward(target, accel * delta)
	velocity.x = planar.x
	velocity.z = planar.z
	move_and_slide()
	_animate(delta, wish)


func _animate(delta: float, wish: Vector3) -> void:
	var speed := Vector3(velocity.x, 0.0, velocity.z).length()
	if wish.length() > 0.05 and is_on_floor():
		_walk_phase += delta * (8.0 + speed * 1.4)
		var facing := atan2(wish.x, wish.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, facing, turn_speed * delta)
	else:
		_walk_phase += delta * 2.2

	var bob := 0.0
	var sway := 0.0
	if is_on_floor() and speed > 0.4:
		bob = absf(sin(_walk_phase)) * 0.055
		sway = sin(_walk_phase) * 0.09
	visual.position.y = bob

	var breath := 1.0 + sin(Time.get_ticks_msec() * 0.0024) * 0.018
	var squash := Vector3.ONE
	if not is_on_floor():
		squash = Vector3(0.92, 1.12, 0.92)
		sway *= 0.2
	visual.scale = squash * breath
	visual.rotation.z = sway


func _on_started() -> void:
	_can_move = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var tween := create_tween()
	tween.tween_property(visual, "rotation:y", PI, 0.45).set_trans(Tween.TRANS_SINE)


func _on_paused(is_paused: bool) -> void:
	_can_move = not is_paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED


func _on_won() -> void:
	_can_move = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_play("res://assets/sfx_win.wav")


func _on_dialogue_shown(_speaker: String, _line: String) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_dialogue_closed() -> void:
	if GameState.phase == GameState.Phase.PLAY:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _play(path: String) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.volume_db = -6.0
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

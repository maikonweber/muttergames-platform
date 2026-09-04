extends Node3D

const CollectibleScript := preload("res://scripts/collectible.gd")
const NpcScript := preload("res://scripts/npc.gd")

var _mats: Dictionary = {}


func _ready() -> void:
	_build_ground()
	_build_plaza_ring()
	_build_kiosk()
	_build_fountain()
	_build_grove()
	_build_picnic()
	_build_entrance()
	_build_border()
	_build_lamps()
	_scatter_decor()
	_spawn_pickups()
	_spawn_friends()


func _mat(color: Color, roughness: float = 0.72, metallic: float = 0.0) -> StandardMaterial3D:
	var key := "%s_%.2f_%.2f" % [color.to_html(), roughness, metallic]
	if _mats.has(key):
		return _mats[key]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	_mats[key] = mat
	return mat


func _solid(mesh: Mesh, pos: Vector3, mat: Material, shape: Shape3D, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.material_override = mat
	add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	mi.add_child(body)
	var col := CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
	return mi


func _box(pos: Vector3, size: Vector3, color: Color, roughness := 0.72) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var shape := BoxShape3D.new()
	shape.size = size
	_solid(mesh, pos, _mat(color, roughness), shape)


func _cyl(pos: Vector3, radius: float, height: float, color: Color, roughness := 0.7, metallic := 0.0) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	_solid(mesh, pos, _mat(color, roughness, metallic), shape)


func _sphere(pos: Vector3, radius: float, color: Color, collision := false) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = _mat(color, 0.85)
	add_child(mi)
	if collision:
		var shape := SphereShape3D.new()
		shape.radius = radius
		var body := StaticBody3D.new()
		body.collision_layer = 1
		mi.add_child(body)
		var col := CollisionShape3D.new()
		col.shape = shape
		body.add_child(col)


func _build_ground() -> void:
	var grass := BoxMesh.new()
	grass.size = Vector3(56, 0.4, 56)
	var shape := BoxShape3D.new()
	shape.size = grass.size
	_solid(grass, Vector3(0, -0.2, 0), _mat(Color(0.36, 0.52, 0.24)), shape)

	var dirt := BoxMesh.new()
	dirt.size = Vector3(8.4, 0.08, 36)
	var path_a := MeshInstance3D.new()
	path_a.mesh = dirt
	path_a.position = Vector3(0, 0.02, 0)
	path_a.material_override = _mat(Color(0.62, 0.42, 0.26), 0.9)
	add_child(path_a)
	var path_b := MeshInstance3D.new()
	var dirt_b := BoxMesh.new()
	dirt_b.size = Vector3(36, 0.08, 8.4)
	path_b.mesh = dirt_b
	path_b.position = Vector3(0, 0.021, 0)
	path_b.material_override = _mat(Color(0.62, 0.42, 0.26), 0.9)
	add_child(path_b)


func _build_plaza_ring() -> void:
	_cyl(Vector3(0, 0.04, 0), 8.6, 0.1, Color(0.78, 0.62, 0.46), 0.85)
	_cyl(Vector3(0, 0.06, 0), 6.4, 0.08, Color(0.84, 0.7, 0.52), 0.8)


func _build_kiosk() -> void:
	_box(Vector3(0, 0.55, 0), Vector3(4.2, 1.1, 2.4), Color(0.45, 0.28, 0.16), 0.65)
	_box(Vector3(0, 1.25, 0), Vector3(4.6, 0.12, 2.8), Color(0.32, 0.18, 0.1), 0.55)
	_box(Vector3(0, 1.85, 0), Vector3(5.0, 0.16, 3.2), Color(0.55, 0.18, 0.16), 0.5)
	_box(Vector3(-1.4, 1.05, 1.15), Vector3(0.16, 1.0, 0.16), Color(0.3, 0.16, 0.1))
	_box(Vector3(1.4, 1.05, 1.15), Vector3(0.16, 1.0, 0.16), Color(0.3, 0.16, 0.1))
	_box(Vector3(0, 0.85, 1.28), Vector3(2.4, 0.08, 0.55), Color(0.72, 0.5, 0.28), 0.6)
	_box(Vector3(0, 2.35, 0), Vector3(1.8, 0.55, 0.12), Color(0.16, 0.22, 0.38), 0.45)
	var sign := MeshInstance3D.new()
	var sign_mesh := BoxMesh.new()
	sign_mesh.size = Vector3(1.7, 0.42, 0.04)
	sign.mesh = sign_mesh
	sign.position = Vector3(0, 2.35, 0.08)
	sign.material_override = _mat(Color(0.93, 0.86, 0.68), 0.7)
	add_child(sign)
	_box(Vector3(-1.7, 0.38, 0.9), Vector3(0.55, 0.76, 0.55), Color(0.2, 0.28, 0.42), 0.35)
	_box(Vector3(1.7, 0.38, 0.9), Vector3(0.55, 0.76, 0.55), Color(0.2, 0.28, 0.42), 0.35)


func _build_fountain() -> void:
	var origin := Vector3(0, 0, -13.5)
	_cyl(origin + Vector3(0, 0.18, 0), 2.6, 0.36, Color(0.72, 0.7, 0.66), 0.4)
	_cyl(origin + Vector3(0, 0.42, 0), 1.9, 0.28, Color(0.32, 0.5, 0.62), 0.15)
	_cyl(origin + Vector3(0, 0.85, 0), 0.28, 1.1, Color(0.78, 0.76, 0.72), 0.35)
	_sphere(origin + Vector3(0, 1.55, 0), 0.32, Color(0.45, 0.72, 0.82))
	var water := MeshInstance3D.new()
	var water_mesh := CylinderMesh.new()
	water_mesh.top_radius = 1.75
	water_mesh.bottom_radius = 1.75
	water_mesh.height = 0.08
	water.mesh = water_mesh
	water.position = origin + Vector3(0, 0.5, 0)
	var wmat := _mat(Color(0.28, 0.58, 0.72, 0.7), 0.08)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.material_override = wmat
	add_child(water)


func _tree(pos: Vector3) -> void:
	_cyl(pos + Vector3(0, 0.7, 0), 0.16, 1.4, Color(0.38, 0.24, 0.14), 0.85)
	_sphere(pos + Vector3(0, 1.85, 0), 0.95, Color(0.28, 0.52, 0.2), true)
	_sphere(pos + Vector3(0.45, 1.55, 0.15), 0.55, Color(0.34, 0.58, 0.22))
	_sphere(pos + Vector3(-0.35, 1.6, -0.2), 0.5, Color(0.24, 0.46, 0.18))


func _build_grove() -> void:
	var spots := [
		Vector3(12.5, 0, -4.5), Vector3(15.5, 0, -1.5), Vector3(14.2, 0, 2.8),
		Vector3(17.8, 0, 1.0), Vector3(11.8, 0, 5.2), Vector3(-13.5, 0, -6.0)
	]
	for p in spots:
		_tree(p)


func _bench(pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	add_child(root)
	var seat := MeshInstance3D.new()
	var seat_mesh := BoxMesh.new()
	seat_mesh.size = Vector3(1.6, 0.12, 0.48)
	seat.mesh = seat_mesh
	seat.position = Vector3(0, 0.42, 0)
	seat.material_override = _mat(Color(0.48, 0.3, 0.16), 0.7)
	root.add_child(seat)
	var back := MeshInstance3D.new()
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(1.6, 0.45, 0.1)
	back.mesh = back_mesh
	back.position = Vector3(0, 0.68, -0.2)
	back.material_override = _mat(Color(0.42, 0.26, 0.14), 0.7)
	root.add_child(back)
	for x in [-0.7, 0.7]:
		var leg := MeshInstance3D.new()
		var leg_mesh := BoxMesh.new()
		leg_mesh.size = Vector3(0.1, 0.4, 0.4)
		leg.mesh = leg_mesh
		leg.position = Vector3(x, 0.2, 0)
		leg.material_override = _mat(Color(0.3, 0.18, 0.1), 0.75)
		root.add_child(leg)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	root.add_child(body)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.6, 0.7, 0.5)
	col.shape = shape
	col.position.y = 0.35
	body.add_child(col)


func _table(pos: Vector3) -> void:
	_cyl(pos + Vector3(0, 0.72, 0), 0.7, 0.08, Color(0.7, 0.48, 0.28), 0.55)
	_cyl(pos + Vector3(0, 0.36, 0), 0.08, 0.72, Color(0.4, 0.24, 0.12), 0.7)
	var cloth := MeshInstance3D.new()
	var cloth_mesh := SphereMesh.new()
	cloth_mesh.radius = 0.95
	cloth_mesh.height = 0.16
	cloth.mesh = cloth_mesh
	cloth.position = pos + Vector3(0, 1.62, 0)
	var cmat := _mat(Color(0.82, 0.22, 0.2, 0.9), 0.55)
	cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloth.material_override = cmat
	add_child(cloth)
	_cyl(pos + Vector3(0, 1.12, 0), 0.05, 0.85, Color(0.85, 0.82, 0.75), 0.4)


func _build_picnic() -> void:
	_table(Vector3(-12.5, 0, 3.5))
	_table(Vector3(-15.5, 0, -1.2))
	_bench(Vector3(-8.5, 0, 8.5), 0.4)
	_bench(Vector3(8.2, 0, 9.0), -0.5)
	_bench(Vector3(-7.5, 0, -8.8), PI + 0.2)
	_bench(Vector3(7.8, 0, -8.4), PI - 0.3)


func _build_entrance() -> void:
	_box(Vector3(-3.4, 1.4, 20.6), Vector3(0.35, 2.8, 0.35), Color(0.34, 0.2, 0.12))
	_box(Vector3(3.4, 1.4, 20.6), Vector3(0.35, 2.8, 0.35), Color(0.34, 0.2, 0.12))
	_box(Vector3(0, 2.85, 20.6), Vector3(7.2, 0.28, 0.45), Color(0.18, 0.24, 0.4))
	_box(Vector3(0, 3.25, 20.6), Vector3(3.6, 0.55, 0.18), Color(0.72, 0.2, 0.18))
	_box(Vector3(-5.0, 0.45, 20.4), Vector3(1.4, 0.9, 0.7), Color(0.55, 0.18, 0.16))
	_box(Vector3(5.0, 0.45, 20.4), Vector3(1.4, 0.9, 0.7), Color(0.55, 0.18, 0.16))


func _build_border() -> void:
	var half := 22.0
	for i in range(-5, 6):
		if abs(i) <= 1:
			continue
		_box(Vector3(i * 3.6, 0.45, half), Vector3(2.4, 0.9, 0.35), Color(0.42, 0.28, 0.16))
		_box(Vector3(i * 3.6, 0.45, -half), Vector3(2.4, 0.9, 0.35), Color(0.42, 0.28, 0.16))
		_box(Vector3(half, 0.45, i * 3.6), Vector3(0.35, 0.9, 2.4), Color(0.42, 0.28, 0.16))
		_box(Vector3(-half, 0.45, i * 3.6), Vector3(0.35, 0.9, 2.4), Color(0.42, 0.28, 0.16))


func _lamp(pos: Vector3) -> void:
	_cyl(pos + Vector3(0, 1.2, 0), 0.07, 2.4, Color(0.22, 0.2, 0.18), 0.4, 0.3)
	_sphere(pos + Vector3(0, 2.5, 0), 0.22, Color(1.0, 0.82, 0.45))
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 2.45, 0)
	light.light_color = Color(1.0, 0.78, 0.48)
	light.light_energy = 2.4
	light.omni_range = 8.5
	light.shadow_enabled = false
	add_child(light)


func _build_lamps() -> void:
	var spots := [
		Vector3(6, 0, 6), Vector3(-6, 0, 6), Vector3(6, 0, -6), Vector3(-6, 0, -6),
		Vector3(0, 0, 16), Vector3(16, 0, 0), Vector3(-16, 0, 0), Vector3(0, 0, -18)
	]
	for p in spots:
		_lamp(p)


func _scatter_decor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 18:
		var p := Vector3(rng.randf_range(-18, 18), 0.08, rng.randf_range(-18, 18))
		if p.length() < 7.0:
			continue
		_sphere(p, rng.randf_range(0.12, 0.22), Color(0.55, 0.5, 0.46))
	var flower_colors := [
		Color(0.92, 0.35, 0.42), Color(0.95, 0.78, 0.28), Color(0.86, 0.55, 0.9)
	]
	for i in 26:
		var p := Vector3(rng.randf_range(-20, 20), 0.12, rng.randf_range(-20, 20))
		if absf(p.x) < 4.2 and absf(p.z) < 18.0:
			continue
		_sphere(p, 0.08, flower_colors[i % flower_colors.size()])


func _pickup(kind: String, pos: Vector3) -> void:
	var item := Area3D.new()
	item.set_script(CollectibleScript)
	item.set("kind", kind)
	item.position = pos
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.55
	shape.shape = sphere
	item.add_child(shape)
	add_child(item)


func _spawn_pickups() -> void:
	var limes := [
		Vector3(12.6, 0.15, -3.8), Vector3(15.2, 0.15, -0.8), Vector3(14.6, 0.15, 3.4),
		Vector3(17.2, 0.15, 1.6), Vector3(11.4, 0.15, 5.8), Vector3(-13.0, 0.15, -5.4)
	]
	for p in limes:
		_pickup("limao", p)
	var ices := [
		Vector3(-1.4, 0.2, -12.6), Vector3(1.5, 0.2, -14.4), Vector3(0.2, 0.2, -11.6),
		Vector3(-12.2, 0.2, 4.2), Vector3(3.2, 0.2, -13.8)
	]
	for p in ices:
		_pickup("gelo", p)
	var caps := [
		Vector3(-2.2, 0.15, 2.4), Vector3(2.2, 0.15, 8.6), Vector3(-15.0, 0.15, -0.4),
		Vector3(8.6, 0.15, 8.4)
	]
	for p in caps:
		_pickup("tampinha", p)


func _friend(npc_name: String, pos: Vector3, body: Color, label: Color, accent: Color, lines: PackedStringArray) -> void:
	var npc := Area3D.new()
	npc.set_script(NpcScript)
	npc.set("npc_name", npc_name)
	npc.set("lines", lines)
	npc.set("body_color", body)
	npc.set("label_color", label)
	npc.set("accent_color", accent)
	npc.position = pos
	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 1.15
	cyl.height = 2.0
	shape.shape = cyl
	shape.position.y = 0.8
	npc.add_child(shape)
	add_child(npc)


func _spawn_friends() -> void:
	_friend(
		"Dona Tônica",
		Vector3(-3.4, 0, 2.6),
		Color(0.82, 0.88, 0.92),
		Color(0.95, 0.93, 0.86),
		Color(0.18, 0.36, 0.55),
		PackedStringArray([
			"Paulinho! Chegou o astro da praça.",
			"Se você achar os limões, a tarde fica perfeita.",
			"Vai com calma, amiguinho. O sol ainda tá gostoso."
		])
	)
	_friend(
		"Seu Zé",
		Vector3(13.2, 0, 0.8),
		Color(0.92, 0.58, 0.18),
		Color(0.96, 0.9, 0.7),
		Color(0.7, 0.18, 0.16),
		PackedStringArray([
			"E aí, garrafinha! Os limoeiros tão carregados hoje.",
			"Pega uns limãozinho pra nós, faz favor.",
			"Depois a gente brinda, sem pressa."
		])
	)
	_friend(
		"Mel",
		Vector3(-14.6, 0, 2.2),
		Color(0.22, 0.42, 0.24),
		Color(0.93, 0.86, 0.55),
		Color(0.82, 0.62, 0.16),
		PackedStringArray([
			"Oi, Paulinho! Vi tampinhas rolando perto das mesas.",
			"E tem gelo perto da fonte, se você curtir um geladinho.",
			"Quando juntar tudo, a praça vira festa."
		])
	)

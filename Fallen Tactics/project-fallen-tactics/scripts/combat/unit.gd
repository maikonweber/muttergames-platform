class_name BattleUnit
extends Node2D
## Combat unit: stats, stance, deck, facing + placeholder visuals (P0).

signal died(unit: BattleUnit)
signal hp_changed(unit: BattleUnit)
signal energy_changed(unit: BattleUnit)
signal damage_resolved(unit: BattleUnit, dealt: int, blocked: int, parried: bool)

enum Facing { NORTH, EAST, SOUTH, WEST }
const FACING_VEC := {
	Facing.NORTH: Vector2i(0, -1),
	Facing.EAST: Vector2i(1, 0),
	Facing.SOUTH: Vector2i(0, 1),
	Facing.WEST: Vector2i(-1, 0),
}

const COL_ALLY := Color("4aa3ff")
const COL_ENEMY := Color("e85d4c")
const COL_OUTLINE_ALLY := Color("8ec8ff")
const COL_OUTLINE_ENEMY := Color("ff8a7a")

var unit_id: String = ""
var display_name: String = ""
var is_player: bool = false
var max_hp: int = 30
var hp: int = 30
var max_energy: int = 3
var energy: int = 3
var energy_regen: int = 3
var base_initiative: int = 10
var timeline_value: int = 0
var block: int = 0
var stance: String = "balance"
var cell: Vector2i = Vector2i.ZERO
var facing: Facing = Facing.EAST
var ai_profile: String = "rusher"
var color: Color = Color.WHITE
var alive: bool = true
var is_active_turn: bool = false

var no_attack_this_turn: bool = false
var pressure_ready: bool = false
var next_attack_bonus: int = 0
var duel_target: BattleUnit = null
var duel_bonus: int = 0
var vulnerable_stacks: int = 0
var prepared_reaction: String = ""
var marked_by: BattleUnit = null
## If set, AI enemies prefer attacking this unit (taunt from Guardião).
var taunt_from: BattleUnit = null
## Party index for rewards (-1 = not party / enemy)
var party_index: int = -1
var class_id: String = ""
## Hidden by combat fog of war (enemies outside vision).
var fog_hidden: bool = false

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var hand: Array[String] = []
var exhaust_pile: Array[String] = []

const HAND_SIZE := 5

var _body: Polygon2D
var _outline: Polygon2D
var _shadow: Polygon2D
var _dir_marker: Polygon2D
var _label: Label
var _hp_label: Label
var _stance_badge: Label
var _hp_bar_bg: Polygon2D
var _hp_bar_fg: Polygon2D
var _active_ring: Polygon2D
var _sprite: Sprite2D
var _base_body_color: Color = Color.WHITE
var _pulse_t: float = 0.0
var _use_sprite: bool = false
var _pose: String = "idle" # idle | attack_slash | hit
var _pose_reset_token: int = 0
const FOOT_Y_RATIO := 0.72


func setup(def: Dictionary, player: bool) -> void:
	unit_id = str(def.get("id", "unit"))
	class_id = str(def.get("class_id", unit_id))
	display_name = str(def.get("display_name", unit_id))
	is_player = player
	party_index = int(def.get("party_index", -1))
	max_hp = int(def.get("max_hp", 30))
	hp = max_hp
	max_energy = int(def.get("max_energy", 3))
	energy = max_energy
	energy_regen = int(def.get("energy_regen", 3))
	base_initiative = int(def.get("base_initiative", 10))
	timeline_value = base_initiative
	ai_profile = str(def.get("ai_profile", "rusher"))
	stance = str(def.get("starting_stance", "balance"))
	color = def.get("color", Color.WHITE) as Color
	_base_body_color = color
	var deck: Array = def.get("deck_ids", [])
	draw_pile.clear()
	for id in deck:
		draw_pile.append(str(id))
	_shuffle(draw_pile)
	_build_visuals_if_needed()
	_apply_visuals()
	_refresh_labels()
	_try_load_sprite()


func _ready() -> void:
	_build_visuals_if_needed()
	_apply_visuals()
	_refresh_labels()
	_try_load_sprite()


func _process(delta: float) -> void:
	if not alive or _active_ring == null:
		return
	if is_active_turn:
		_pulse_t += delta * 4.0
		var s := 1.0 + 0.06 * sin(_pulse_t)
		_active_ring.scale = Vector2(s, s)
		_active_ring.visible = true
		_active_ring.modulate.a = 0.55 + 0.25 * sin(_pulse_t)
	else:
		_active_ring.visible = false


func _build_visuals_if_needed() -> void:
	if has_node("Body"):
		_body = $Body
		_outline = get_node_or_null("Outline") as Polygon2D
		_shadow = get_node_or_null("Shadow") as Polygon2D
		_dir_marker = get_node_or_null("DirMarker") as Polygon2D
		_label = get_node_or_null("Label") as Label
		_hp_label = get_node_or_null("HpLabel") as Label
		_stance_badge = get_node_or_null("StanceBadge") as Label
		_active_ring = get_node_or_null("ActiveRing") as Polygon2D
		_hp_bar_bg = get_node_or_null("HpBarBg") as Polygon2D
		_hp_bar_fg = get_node_or_null("HpBarFg") as Polygon2D
		_sprite = get_node_or_null("UnitSprite") as Sprite2D
		return
	# Built from code when spawned without scene
	_shadow = Polygon2D.new()
	_shadow.name = "Shadow"
	_shadow.color = Color(0, 0, 0, 0.35)
	# Iso-flattened oval under feet (position is foot/center of diamond)
	_shadow.polygon = PackedVector2Array([
		Vector2(-20, -4), Vector2(20, -4), Vector2(14, 6), Vector2(-14, 6)
	])
	add_child(_shadow)

	_active_ring = Polygon2D.new()
	_active_ring.name = "ActiveRing"
	_active_ring.color = Color("ffe08a")
	_active_ring.polygon = _iso_ring_poly()
	_active_ring.visible = false
	add_child(_active_ring)

	_sprite = Sprite2D.new()
	_sprite.name = "UnitSprite"
	_sprite.centered = false
	_sprite.visible = false
	add_child(_sprite)

	_outline = Polygon2D.new()
	_outline.name = "Outline"
	add_child(_outline)

	_body = Polygon2D.new()
	_body.name = "Body"
	add_child(_body)

	_dir_marker = Polygon2D.new()
	_dir_marker.name = "DirMarker"
	_dir_marker.color = Color(1, 1, 1, 0.95)
	_dir_marker.polygon = PackedVector2Array([
		Vector2(18, -5), Vector2(30, 0), Vector2(18, 5)
	])
	add_child(_dir_marker)

	_label = Label.new()
	_label.name = "Label"
	_label.position = Vector2(-42, -78)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 3)
	_label.custom_minimum_size = Vector2(84, 14)
	add_child(_label)

	_stance_badge = Label.new()
	_stance_badge.name = "StanceBadge"
	_stance_badge.position = Vector2(18, -52)
	_stance_badge.add_theme_font_size_override("font_size", 12)
	_stance_badge.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_stance_badge.add_theme_constant_override("outline_size", 3)
	add_child(_stance_badge)

	_hp_bar_bg = Polygon2D.new()
	_hp_bar_bg.name = "HpBarBg"
	_hp_bar_bg.color = Color(0.1, 0.1, 0.12, 0.85)
	_hp_bar_bg.polygon = PackedVector2Array([
		Vector2(-18, 10), Vector2(18, 10), Vector2(18, 15), Vector2(-18, 15)
	])
	add_child(_hp_bar_bg)

	_hp_bar_fg = Polygon2D.new()
	_hp_bar_fg.name = "HpBarFg"
	_hp_bar_fg.color = Color("6dffa0")
	add_child(_hp_bar_fg)

	_hp_label = Label.new()
	_hp_label.name = "HpLabel"
	_hp_label.position = Vector2(-30, 16)
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.add_theme_font_size_override("font_size", 11)
	_hp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_hp_label.add_theme_constant_override("outline_size", 3)
	_hp_label.custom_minimum_size = Vector2(60, 14)
	add_child(_hp_label)


func _iso_ring_poly() -> PackedVector2Array:
	## Flattened diamond ring around feet (iso).
	return PackedVector2Array([
		Vector2(0, -14), Vector2(28, 0), Vector2(0, 14), Vector2(-28, 0),
		Vector2(0, -10), Vector2(-20, 0), Vector2(0, 10), Vector2(20, 0),
	])


func _shape_for_unit() -> PackedVector2Array:
	var id := unit_id.to_lower()
	if id.begins_with("goblin"):
		# small crouched
		return PackedVector2Array([
			Vector2(0, -14), Vector2(12, 4), Vector2(8, 12), Vector2(-8, 12), Vector2(-12, 4)
		])
	if id.begins_with("orc"):
		# wide shoulders
		return PackedVector2Array([
			Vector2(0, -20), Vector2(20, -4), Vector2(16, 14), Vector2(-16, 14), Vector2(-20, -4)
		])
	if id.begins_with("archer") or id.begins_with("arqueiro"):
		# tall thin + bow hint
		return PackedVector2Array([
			Vector2(0, -24), Vector2(10, -8), Vector2(8, 14), Vector2(-8, 14), Vector2(-10, -8)
		])
	if id.begins_with("captain") or id.begins_with("capitao"):
		# broad boss diamond
		return PackedVector2Array([
			Vector2(0, -26), Vector2(18, -6), Vector2(14, 14), Vector2(0, 18), Vector2(-14, 14), Vector2(-18, -6)
		])
	if id.begins_with("guardiao"):
		# wide shield tank
		return PackedVector2Array([
			Vector2(-6, -20), Vector2(14, -16), Vector2(18, 12), Vector2(-14, 14), Vector2(-18, -4)
		])
	if id.begins_with("patrulheiro"):
		# lean bow shape
		return PackedVector2Array([
			Vector2(0, -24), Vector2(12, -6), Vector2(8, 14), Vector2(-10, 12), Vector2(-14, -8)
		])
	# espadachim default — blade-like triangle
	return PackedVector2Array([
		Vector2(0, -22), Vector2(16, 12), Vector2(0, 8), Vector2(-16, 12)
	])


func _apply_visuals() -> void:
	if _body == null:
		return
	var shape := _shape_for_unit()
	_body.polygon = shape
	_body.color = _base_body_color
	if _outline:
		var grown: PackedVector2Array = []
		for p in shape:
			grown.append(p * 1.12)
		_outline.polygon = grown
		_outline.color = COL_OUTLINE_ALLY if is_player else COL_OUTLINE_ENEMY
		_outline.z_index = -1
	if _dir_marker:
		_dir_marker.color = Color(1, 1, 1, 0.95) if is_player else Color(1, 0.9, 0.85, 0.95)
	if _active_ring:
		_active_ring.color = Color("ffe08a") if is_player else Color("ffaa66")
	_update_facing_visual()
	_update_hp_bar()
	_apply_sprite_mode()


func _try_load_sprite() -> void:
	if _sprite == null:
		return
	var path := _sprite_path_for_facing()
	if path != "" and ResourceLoader.exists(path):
		_sprite.texture = load(path)
		_use_sprite = true
	else:
		# Fallback: any idle_se for hero id family
		var fallback := "res://assets/units/%s/%s_idle_se.png" % [_folder_id(), _folder_id()]
		if ResourceLoader.exists(fallback):
			_sprite.texture = load(fallback)
			_use_sprite = true
		else:
			_use_sprite = false
	_apply_sprite_mode()


func _folder_id() -> String:
	var id := unit_id.to_lower()
	var cid := class_id.to_lower()
	if cid == "espadachim" or id.begins_with("espadachim"):
		return "espadachim"
	if cid == "guardiao" or id.begins_with("guardiao"):
		return "guardiao"
	if cid == "patrulheiro" or id.begins_with("patrulheiro"):
		return "patrulheiro"
	if id.begins_with("goblin"):
		return "goblin"
	if id.begins_with("orc"):
		return "orc"
	if id.begins_with("archer") or id.begins_with("arqueiro"):
		return "arqueiro"
	if id.begins_with("captain") or id.begins_with("capitao"):
		return "capitao"
	if is_player:
		return "espadachim"
	return id


func _iso_dir_code() -> String:
	## Logical facing → iso file suffix (ASSET_INSTRUCTIONS).
	match facing:
		Facing.EAST:
			return "se"
		Facing.SOUTH:
			return "sw"
		Facing.WEST:
			return "nw"
		Facing.NORTH:
			return "ne"
	return "se"


func _sprite_path_for_facing() -> String:
	var folder := _folder_id()
	var d := _iso_dir_code()
	var candidates: Array[String] = []
	if _pose == "attack_slash":
		candidates.append("res://assets/units/%s/%s_attack_slash_%s.png" % [folder, folder, d])
		candidates.append("res://assets/units/%s/%s_attack_slash_se.png" % [folder, folder])
	if _pose == "hit":
		candidates.append("res://assets/units/%s/%s_hit_%s.png" % [folder, folder, d])
		candidates.append("res://assets/units/%s/%s_hit_se.png" % [folder, folder])
	if _pose == "death":
		candidates.append("res://assets/units/%s/%s_death_%s.png" % [folder, folder, d])
		candidates.append("res://assets/units/%s/%s_death_se.png" % [folder, folder])
	candidates.append("res://assets/units/%s/%s_idle_%s.png" % [folder, folder, d])
	candidates.append("res://assets/units/%s/%s_idle_se.png" % [folder, folder])
	candidates.append("res://assets/units/%s/%s_idle_sw.png" % [folder, folder])
	for p in candidates:
		if ResourceLoader.exists(p):
			return p
	return ""


func set_pose(pose: String, hold_sec: float = 0.0) -> void:
	_pose = pose
	_try_load_sprite()
	if hold_sec > 0.0 and is_inside_tree():
		_pose_reset_token += 1
		var token := _pose_reset_token
		_reset_pose_after(hold_sec, token)


func _reset_pose_after(sec: float, token: int) -> void:
	await get_tree().create_timer(sec).timeout
	if token != _pose_reset_token:
		return
	if not alive:
		return
	_pose = "idle"
	_try_load_sprite()


func play_attack_pose() -> void:
	set_pose("attack_slash", 0.35)


func _apply_sprite_mode() -> void:
	if _sprite and _use_sprite and _sprite.texture:
		_sprite.visible = true
		# Feet at unit origin (diamond center)
		var th := float(_sprite.texture.get_height())
		var tw := float(_sprite.texture.get_width())
		_sprite.position = Vector2(-tw * 0.5, -th * FOOT_Y_RATIO)
		if _body:
			_body.visible = false
		if _outline:
			_outline.visible = false
		if _dir_marker:
			_dir_marker.visible = false
		if _shadow:
			_shadow.visible = false # baked in sprite often
	else:
		if _sprite:
			_sprite.visible = false
		if _body:
			_body.visible = true
		if _outline:
			_outline.visible = true
		if _dir_marker:
			_dir_marker.visible = true
		if _shadow:
			_shadow.visible = true


func set_active_turn(active: bool) -> void:
	is_active_turn = active
	if _active_ring:
		_active_ring.visible = active


func place_on_grid(grid: TacticalGrid, new_cell: Vector2i) -> void:
	cell = new_cell
	position = grid.cell_to_world(new_cell)
	# Y-sort: higher (x+y) draws in front
	z_index = cell.x + cell.y
	grid.set_unit_at(new_cell, self)
	_refresh_labels()


func set_fog_hidden(hidden: bool) -> void:
	fog_hidden = hidden
	if not alive:
		return
	# Players always visible; enemies hide in fog
	if is_player:
		fog_hidden = false
		visible = true
		return
	visible = not fog_hidden


func start_turn() -> void:
	block = 0
	no_attack_this_turn = false
	energy = mini(max_energy, energy + energy_regen)
	energy_changed.emit(self)
	if is_player:
		draw_cards(HAND_SIZE - hand.size())
	_refresh_labels()


func end_turn() -> void:
	if not is_player:
		return
	while hand.size() > 0:
		discard_pile.append(hand.pop_back())


func draw_cards(n: int) -> void:
	for i in n:
		if draw_pile.is_empty():
			_reshuffle_discard()
		if draw_pile.is_empty():
			break
		hand.append(draw_pile.pop_back())


func _reshuffle_discard() -> void:
	if discard_pile.is_empty():
		return
	for c in discard_pile:
		draw_pile.append(c)
	discard_pile.clear()
	_shuffle(draw_pile)


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := randi() % (i + 1)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func spend_energy(amount: int) -> bool:
	if energy < amount:
		return false
	energy -= amount
	energy_changed.emit(self)
	_refresh_labels()
	return true


func discard_card_from_hand(index: int) -> void:
	if index < 0 or index >= hand.size():
		return
	var id: String = hand[index]
	hand.remove_at(index)
	discard_pile.append(id)


func take_damage(amount: int, from_dir: Vector2i = Vector2i.ZERO, attacker: BattleUnit = null) -> int:
	if not alive:
		return 0
	var dmg := amount
	if from_dir != Vector2i.ZERO:
		var relation := _hit_relation(from_dir)
		match relation:
			"back":
				dmg = int(dmg * 1.5)
			"flank":
				dmg = int(dmg * 1.25)
			"front":
				if stance == "guard":
					dmg = maxi(0, dmg - 2)
	if stance == "offense" and from_dir != Vector2i.ZERO:
		dmg += 1
	if vulnerable_stacks > 0:
		dmg = int(dmg * 1.5)
		vulnerable_stacks -= 1
	if prepared_reaction == "parry" and attacker and _hit_relation(from_dir) == "front":
		prepared_reaction = ""
		energy = mini(max_energy, energy + 1)
		energy_changed.emit(self)
		_refresh_labels()
		damage_resolved.emit(self, 0, 0, true)
		play_hit_fx(true)
		return 0
	var blocked := mini(block, dmg)
	block -= blocked
	dmg -= blocked
	hp -= dmg
	hp_changed.emit(self)
	_refresh_labels()
	damage_resolved.emit(self, dmg, blocked, false)
	if dmg > 0 or blocked > 0:
		play_hit_fx(false, from_dir)
	if hp <= 0:
		hp = 0
		alive = false
		play_death_fx()
		died.emit(self)
	return dmg


func heal(amount: int) -> void:
	hp = mini(max_hp, hp + amount)
	hp_changed.emit(self)
	_refresh_labels()


func add_block(amount: int) -> void:
	if stance == "guard":
		amount += 1
	block += amount
	_refresh_labels()


func set_stance(s: String) -> void:
	stance = s
	_refresh_labels()
	# slight color shift by stance
	if _body:
		match stance:
			"guard":
				_body.color = _base_body_color.lerp(Color("7eb6ff"), 0.25)
			"offense":
				_body.color = _base_body_color.lerp(Color("ff8a6a"), 0.25)
			_:
				_body.color = _base_body_color


func face_toward(target_cell: Vector2i) -> void:
	var d: Vector2i = target_cell - cell
	if abs(d.x) >= abs(d.y):
		facing = Facing.EAST if d.x > 0 else Facing.WEST
	else:
		facing = Facing.SOUTH if d.y > 0 else Facing.NORTH
	_update_facing_visual()


func set_facing(f: Facing) -> void:
	facing = f
	_update_facing_visual()


func facing_vector() -> Vector2i:
	return FACING_VEC[facing]


func _hit_relation(from_dir: Vector2i) -> String:
	if from_dir == Vector2i.ZERO:
		return "front"
	var fv := facing_vector()
	var to_attacker := from_dir
	if to_attacker == fv:
		return "front"
	if to_attacker == -fv:
		return "back"
	return "flank"


func _update_facing_visual() -> void:
	# Reload sprite for iso dir when available
	if _use_sprite:
		_try_load_sprite()
	if not _dir_marker or _use_sprite:
		if _dir_marker and _use_sprite:
			_dir_marker.visible = false
		return
	# Iso-ish chevron: point along screen diagonal for facing
	var angle := 0.0
	match facing:
		Facing.EAST: # se
			angle = PI * 0.25
		Facing.SOUTH: # sw
			angle = PI * 0.75
		Facing.WEST: # nw
			angle = PI * 1.25
		Facing.NORTH: # ne
			angle = PI * 1.75
	_dir_marker.rotation = angle


func play_hit_fx(parried: bool = false, from_dir: Vector2i = Vector2i.ZERO) -> void:
	var target: CanvasItem = _sprite if (_use_sprite and _sprite) else _body
	if target == null:
		return
	if not parried and _use_sprite:
		set_pose("hit", 0.25)
	var tw := create_tween()
	if parried:
		tw.tween_property(target, "modulate", Color("ffe08a"), 0.05)
		tw.tween_property(target, "modulate", Color.WHITE, 0.12)
		return
	tw.tween_property(target, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	tw.tween_property(target, "modulate", Color.WHITE, 0.12)
	# Iso knockback along logical step projected roughly
	var kb := Vector2(from_dir.x - from_dir.y, from_dir.x + from_dir.y) * 4.0
	if kb == Vector2.ZERO:
		kb = Vector2(4, 2)
	var origin := position
	var tw2 := create_tween()
	tw2.tween_property(self, "position", origin + kb, 0.06)
	tw2.tween_property(self, "position", origin, 0.1)


func play_death_fx() -> void:
	_pose = "death"
	_try_load_sprite()
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.45)
	tw.parallel().tween_property(self, "scale", Vector2(0.75, 0.75), 0.45)


func _update_hp_bar() -> void:
	if _hp_bar_fg == null or _hp_bar_bg == null:
		return
	var ratio := 0.0 if max_hp <= 0 else clampf(float(hp) / float(max_hp), 0.0, 1.0)
	var w := 36.0 * ratio
	var y0 := 10.0
	_hp_bar_bg.polygon = PackedVector2Array([
		Vector2(-18, y0), Vector2(18, y0), Vector2(18, y0 + 5), Vector2(-18, y0 + 5)
	])
	_hp_bar_fg.polygon = PackedVector2Array([
		Vector2(-18, y0), Vector2(-18 + w, y0), Vector2(-18 + w, y0 + 5), Vector2(-18, y0 + 5)
	])
	if ratio > 0.5:
		_hp_bar_fg.color = Color("6dffa0")
	elif ratio > 0.25:
		_hp_bar_fg.color = Color("ffe08a")
	else:
		_hp_bar_fg.color = Color("ff6b5a")


func _refresh_labels() -> void:
	if _label:
		_label.text = display_name
		_label.add_theme_color_override("font_color", COL_ALLY if is_player else COL_ENEMY)
	if _stance_badge:
		match stance:
			"guard":
				_stance_badge.text = "🛡"
				_stance_badge.visible = true
			"offense":
				_stance_badge.text = "⚔"
				_stance_badge.visible = true
			_:
				_stance_badge.text = ""
				_stance_badge.visible = prepared_reaction != ""
				if prepared_reaction == "parry":
					_stance_badge.text = "✋"
					_stance_badge.visible = true
	if _hp_label:
		var blk := (" +%d" % block) if block > 0 else ""
		_hp_label.text = "%d/%d%s" % [hp, max_hp, blk]
	_update_hp_bar()

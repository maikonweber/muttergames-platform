class_name BattleUnit
extends Node2D
## Combat unit: stats, stance, deck, facing.

signal died(unit: BattleUnit)
signal hp_changed(unit: BattleUnit)
signal energy_changed(unit: BattleUnit)

enum Facing { NORTH, EAST, SOUTH, WEST }
const FACING_VEC := {
	Facing.NORTH: Vector2i(0, -1),
	Facing.EAST: Vector2i(1, 0),
	Facing.SOUTH: Vector2i(0, 1),
	Facing.WEST: Vector2i(-1, 0),
}

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
var stance: String = "balance" # guard | offense | balance
var cell: Vector2i = Vector2i.ZERO
var facing: Facing = Facing.EAST
var ai_profile: String = "rusher"
var color: Color = Color.WHITE
var alive: bool = true

# Flags this turn / combat
var no_attack_this_turn: bool = false
var pressure_ready: bool = false
var next_attack_bonus: int = 0
var duel_target: BattleUnit = null
var duel_bonus: int = 0
var vulnerable_stacks: int = 0
var prepared_reaction: String = ""
var marked_by: BattleUnit = null

# Deck
var draw_pile: Array[String] = []
var discard_pile: Array[String] = []
var hand: Array[String] = []
var exhaust_pile: Array[String] = []

const HAND_SIZE := 5

@onready var _body: Polygon2D = $Body
@onready var _label: Label = $Label
@onready var _hp_label: Label = $HpLabel
@onready var _dir_marker: Polygon2D = $DirMarker


func setup(def: Dictionary, player: bool) -> void:
	unit_id = str(def.get("id", "unit"))
	display_name = str(def.get("display_name", unit_id))
	is_player = player
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
	var deck: Array = def.get("deck_ids", [])
	draw_pile.clear()
	for id in deck:
		draw_pile.append(str(id))
	_shuffle(draw_pile)
	if has_node("Body"):
		_apply_visuals()


func _ready() -> void:
	_apply_visuals()
	_refresh_labels()


func _apply_visuals() -> void:
	if _body:
		_body.color = color
	_update_facing_visual()


func place_on_grid(grid: TacticalGrid, new_cell: Vector2i) -> void:
	cell = new_cell
	position = grid.cell_to_world(new_cell)
	grid.set_unit_at(new_cell, self)
	_refresh_labels()


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
	# Discard hand at end of turn (StS-like for clarity in VS)
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
	# Facing modifiers
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
		dmg += 1 # glass cannon
	if vulnerable_stacks > 0:
		dmg = int(dmg * 1.5)
		vulnerable_stacks -= 1
	# Parry reaction
	if prepared_reaction == "parry" and attacker and _hit_relation(from_dir) == "front":
		prepared_reaction = ""
		energy = mini(max_energy, energy + 1)
		energy_changed.emit(self)
		_refresh_labels()
		return 0
	var blocked := mini(block, dmg)
	block -= blocked
	dmg -= blocked
	hp -= dmg
	hp_changed.emit(self)
	_refresh_labels()
	if hp <= 0:
		hp = 0
		alive = false
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


func face_toward(target_cell: Vector2i) -> void:
	var d: Vector2i = target_cell - cell
	if abs(d.x) >= abs(d.y):
		facing = Facing.EAST if d.x > 0 else Facing.WEST
	else:
		facing = Facing.SOUTH if d.y > 0 else Facing.NORTH
	_update_facing_visual()


func facing_vector() -> Vector2i:
	return FACING_VEC[facing]


func _hit_relation(from_dir: Vector2i) -> String:
	# from_dir: vector from self to attacker (or attack origin)
	var fv := facing_vector()
	var incoming := -from_dir # direction attack comes from relative to facing check
	# Simpler: compare attacker position relative to facing
	if from_dir == Vector2i.ZERO:
		return "front"
	var to_attacker := from_dir
	if to_attacker == fv:
		return "front"
	if to_attacker == -fv:
		return "back"
	return "flank"


func _update_facing_visual() -> void:
	if not _dir_marker:
		return
	var angle := 0.0
	match facing:
		Facing.NORTH:
			angle = -PI / 2
		Facing.EAST:
			angle = 0.0
		Facing.SOUTH:
			angle = PI / 2
		Facing.WEST:
			angle = PI
	_dir_marker.rotation = angle


func _refresh_labels() -> void:
	if _label:
		var stance_icon := ""
		match stance:
			"guard":
				stance_icon = " [G]"
			"offense":
				stance_icon = " [O]"
			_:
				stance_icon = ""
		_label.text = "%s%s" % [display_name, stance_icon]
	if _hp_label:
		var blk := (" +%d" % block) if block > 0 else ""
		_hp_label.text = "%d/%d%s" % [hp, max_hp, blk]

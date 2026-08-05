class_name CombatManager
extends Node2D
## Main combat loop: timeline, cards, win/loss.

signal combat_ended(won: bool)
signal log_message(text: String)
signal hand_changed
signal timeline_changed
signal turn_changed(unit: BattleUnit)

enum Phase { IDLE, PLAYER_TURN, SELECT_TARGET, ENEMY_TURN, RESOLVING, ENDED }

var grid: TacticalGrid
var units: Array[BattleUnit] = []
var phase: Phase = Phase.IDLE
var active_unit: BattleUnit = null
var selected_card_index: int = -1
var selected_card: CardDef = null
var valid_targets: Array = []
var boss_phase2_done: bool = false
var boss_phase3_done: bool = false
var encounter_id: String = "encounter_01"

@onready var units_root: Node2D = $Units
@onready var grid_node: TacticalGrid = $Board
@onready var camera: Camera2D = $Camera2D

const UNIT_SCENE_PATH := "res://scenes/combat/unit.tscn"


func _ready() -> void:
	grid = grid_node
	grid.tile_clicked.connect(_on_tile_clicked)
	if not GameState.run_active:
		GameState.start_new_run()
	start_encounter(GameState.next_encounter())


func start_encounter(enc_id: String) -> void:
	encounter_id = enc_id
	boss_phase2_done = false
	boss_phase3_done = false
	_clear_units()
	_spawn_encounter(enc_id)
	for u in units:
		u.timeline_value = u.base_initiative + randi() % 3
	emit_signal("log_message", "— Combate: %s —" % enc_id)
	phase = Phase.IDLE
	_advance_timeline()


func _clear_units() -> void:
	for u in units:
		if is_instance_valid(u):
			u.queue_free()
	units.clear()


func _spawn_encounter(enc_id: String) -> void:
	var hero_def := {
		"id": "espadachim",
		"display_name": "Espadachim",
		"max_hp": 36,
		"max_energy": 3,
		"energy_regen": 3,
		"base_initiative": 8,
		"color": Color("4aa3ff"),
		"deck_ids": GameState.hero_card_ids.duplicate(),
		"starting_stance": "balance",
		"ai_profile": "player",
	}
	var hero := _spawn_unit(hero_def, true, Vector2i(1, 3))
	hero.facing = BattleUnit.Facing.EAST

	match enc_id:
		"encounter_01":
			_spawn_unit(_enemy("goblin", "Goblin", 14, 12, Color("7cba5a"), "flanker"), false, Vector2i(6, 2))
			_spawn_unit(_enemy("orc", "Orc", 22, 6, Color("c45c26"), "rusher"), false, Vector2i(5, 4))
		"encounter_02":
			_spawn_unit(_enemy("goblin", "Goblin", 14, 12, Color("7cba5a"), "flanker"), false, Vector2i(6, 1))
			_spawn_unit(_enemy("goblin2", "Goblin", 14, 11, Color("6aaa4a"), "flanker"), false, Vector2i(7, 4))
			_spawn_unit(_enemy("archer", "Arqueiro", 16, 9, Color("c9a227"), "ranged"), false, Vector2i(6, 0))
		_:
			_spawn_unit(_enemy("captain", "Capitão", 48, 7, Color("b33a3a"), "boss"), false, Vector2i(5, 3))


func _enemy(id: String, name: String, hp: int, ini: int, col: Color, ai: String) -> Dictionary:
	return {
		"id": id,
		"display_name": name,
		"max_hp": hp,
		"max_energy": 2,
		"energy_regen": 2,
		"base_initiative": ini,
		"color": col,
		"deck_ids": [],
		"ai_profile": ai,
	}


func _spawn_unit(def: Dictionary, player: bool, cell: Vector2i) -> BattleUnit:
	var u := BattleUnit.new()
	# Build visual children
	var body := Polygon2D.new()
	body.name = "Body"
	body.polygon = PackedVector2Array([
		Vector2(0, -22), Vector2(18, 14), Vector2(-18, 14)
	])
	u.add_child(body)
	var dir_m := Polygon2D.new()
	dir_m.name = "DirMarker"
	dir_m.color = Color(1, 1, 1, 0.85)
	dir_m.polygon = PackedVector2Array([
		Vector2(20, -4), Vector2(30, 0), Vector2(20, 4)
	])
	u.add_child(dir_m)
	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-40, -40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.custom_minimum_size = Vector2(80, 14)
	u.add_child(label)
	var hp_l := Label.new()
	hp_l.name = "HpLabel"
	hp_l.position = Vector2(-30, 16)
	hp_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_l.add_theme_font_size_override("font_size", 12)
	hp_l.custom_minimum_size = Vector2(60, 14)
	u.add_child(hp_l)

	units_root.add_child(u)
	u.setup(def, player)
	u.place_on_grid(grid, cell)
	u.died.connect(_on_unit_died)
	units.append(u)
	return u


func get_hero() -> BattleUnit:
	for u in units:
		if u.is_player and u.alive:
			return u
	return null


func get_all_units() -> Array:
	return units


func _advance_timeline() -> void:
	if phase == Phase.ENDED:
		return
	# Find lowest timeline value among alive
	var next: BattleUnit = null
	var best := 999999
	for u in units:
		if not u.alive:
			continue
		if u.timeline_value < best:
			best = u.timeline_value
			next = u
	if next == null:
		_end_combat(false)
		return
	# Normalize: subtract best from all so next is at 0-ish
	if best > 0:
		for u in units:
			if u.alive:
				u.timeline_value -= best
	active_unit = next
	timeline_changed.emit()
	turn_changed.emit(active_unit)
	if active_unit.is_player:
		_begin_player_turn()
	else:
		_begin_enemy_turn()


func _begin_player_turn() -> void:
	phase = Phase.PLAYER_TURN
	selected_card_index = -1
	selected_card = null
	grid.clear_highlights()
	active_unit.start_turn()
	# After acting, CT recharge
	emit_signal("log_message", "Seu turno — Energia: %d | Postura: %s" % [active_unit.energy, active_unit.stance])
	hand_changed.emit()
	timeline_changed.emit()


func _begin_enemy_turn() -> void:
	phase = Phase.ENEMY_TURN
	selected_card_index = -1
	selected_card = null
	grid.clear_highlights()
	active_unit.start_turn()
	emit_signal("log_message", "Turno de %s..." % active_unit.display_name)
	_run_enemy_turn()


func _run_enemy_turn() -> void:
	await get_tree().create_timer(0.45).timeout
	if phase == Phase.ENDED or active_unit == null or not active_unit.alive:
		if phase != Phase.ENDED:
			_check_end()
			if phase != Phase.ENDED:
				_advance_timeline()
		return
	var logs := AIController.take_turn(active_unit, self)
	for line in logs:
		emit_signal("log_message", line)
	await get_tree().create_timer(0.35).timeout
	if phase == Phase.ENDED:
		return
	_finish_unit_turn(active_unit)


func _finish_unit_turn(unit: BattleUnit) -> void:
	if phase == Phase.ENDED:
		return
	if unit and unit.alive:
		unit.end_turn()
		# CT: lower initiative = acts more often. Add base after turn.
		unit.timeline_value += unit.base_initiative
	selected_card_index = -1
	selected_card = null
	grid.clear_highlights()
	hand_changed.emit()
	timeline_changed.emit()
	_check_end()
	if phase != Phase.ENDED:
		phase = Phase.IDLE
		_advance_timeline()


func end_player_turn() -> void:
	if phase != Phase.PLAYER_TURN and phase != Phase.SELECT_TARGET:
		return
	if active_unit == null or not active_unit.is_player:
		return
	emit_signal("log_message", "Fim do turno.")
	_finish_unit_turn(active_unit)


func select_card(index: int) -> void:
	if phase != Phase.PLAYER_TURN and phase != Phase.SELECT_TARGET:
		return
	if active_unit == null or not active_unit.is_player:
		return
	if index < 0 or index >= active_unit.hand.size():
		return
	var card_id: String = active_unit.hand[index]
	var card := CardLibrary.get_card(card_id)
	if active_unit.energy < card.cost:
		emit_signal("log_message", "Energia insuficiente.")
		return
	if active_unit.no_attack_this_turn and card.card_type == CardDef.CardType.ATTACK:
		emit_signal("log_message", "Sprint: não pode atacar neste turno.")
		return
	selected_card_index = index
	selected_card = card
	_show_valid_targets(card)
	if card.target_mode == CardDef.TargetMode.SELF or card.target_mode == CardDef.TargetMode.NONE:
		_play_card(active_unit, null, active_unit.cell)
	else:
		phase = Phase.SELECT_TARGET
		emit_signal("log_message", "Escolha alvo para %s" % card.display_name)


func _show_valid_targets(card: CardDef) -> void:
	valid_targets.clear()
	var origin := active_unit.cell
	match card.target_mode:
		CardDef.TargetMode.TILE:
			var max_r := card.range_max
			for e in card.effects:
				if typeof(e) == TYPE_DICTIONARY and str(e.get("op", "")) == "move":
					max_r = int(e.get("max_tiles", max_r))
			valid_targets = grid.reachable_cells(origin, max_r)
			# also allow 0-cost giro on self
			if card.range_min == 0:
				valid_targets.append(origin)
			grid.set_highlights(valid_targets, Color(0.3, 0.7, 1.0))
		CardDef.TargetMode.ENEMY:
			for u in units:
				if not u.alive or u.is_player:
					continue
				var d := grid.manhattan(origin, u.cell)
				if d >= card.range_min and d <= card.range_max:
					valid_targets.append(u.cell)
			grid.set_highlights(valid_targets, Color(1.0, 0.35, 0.25))
		_:
			grid.clear_highlights()


func _on_tile_clicked(cell: Vector2i) -> void:
	if phase != Phase.SELECT_TARGET or selected_card == null:
		return
	if cell not in valid_targets:
		emit_signal("log_message", "Alvo inválido.")
		return
	var target_unit: BattleUnit = grid.get_unit_at(cell) as BattleUnit
	_play_card(active_unit, target_unit, cell)


func _play_card(caster: BattleUnit, target: BattleUnit, cell: Vector2i) -> void:
	if selected_card == null or selected_card_index < 0:
		return
	var card := selected_card
	if not caster.spend_energy(card.cost):
		emit_signal("log_message", "Energia insuficiente.")
		return
	var result := EffectResolver.resolve(card.effects, caster, target, cell, grid, self)
	for line in result.get("log", []):
		emit_signal("log_message", str(line))
	# Consume card
	caster.discard_card_from_hand(selected_card_index)
	selected_card = null
	selected_card_index = -1
	grid.clear_highlights()
	phase = Phase.PLAYER_TURN
	hand_changed.emit()
	timeline_changed.emit()
	_check_end()


func cancel_targeting() -> void:
	if phase != Phase.SELECT_TARGET:
		return
	selected_card = null
	selected_card_index = -1
	grid.clear_highlights()
	phase = Phase.PLAYER_TURN
	emit_signal("log_message", "Alvo cancelado.")


func _on_unit_died(unit: BattleUnit) -> void:
	emit_signal("log_message", "%s caiu!" % unit.display_name)
	grid.set_unit_at(unit.cell, null)
	unit.visible = false
	_check_end()


func _check_end() -> void:
	if phase == Phase.ENDED:
		return
	var hero_alive := false
	var enemy_alive := false
	for u in units:
		if not u.alive:
			continue
		if u.is_player:
			hero_alive = true
		else:
			enemy_alive = true
	if not hero_alive:
		_end_combat(false)
	elif not enemy_alive:
		_end_combat(true)


func _end_combat(won: bool) -> void:
	phase = Phase.ENDED
	GameState.last_combat_won = won
	if won:
		emit_signal("log_message", "★★ VITÓRIA ★★")
		GameState.encounter_index += 1
	else:
		emit_signal("log_message", "✕ DERROTA — a run termina.")
		GameState.run_active = false
	combat_ended.emit(won)


func boss_try_phase2() -> bool:
	if boss_phase2_done:
		return false
	boss_phase2_done = true
	# Open a pit near hero / center
	grid.tiles[4][2] = TacticalGrid.TileType.PIT
	grid.tiles[4][3] = TacticalGrid.TileType.PIT
	grid.queue_redraw()
	_spawn_unit(_enemy("goblin_r", "Reforço", 12, 10, Color("7cba5a"), "flanker"), false, Vector2i(7, 2))
	return true


func boss_try_phase3() -> bool:
	if boss_phase3_done:
		return false
	boss_phase3_done = true
	for u in units:
		if u.alive and u.ai_profile == "boss":
			u.base_initiative = maxi(4, u.base_initiative - 2)
			u.timeline_value = maxi(0, u.timeline_value - 3)
	return true


func offer_rewards() -> Array[String]:
	return ["investida", "corte_arco", "desafio", "lamina_final", "ofensiva", "quebra_guarda", "respiracao"]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		end_player_turn()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_targeting()

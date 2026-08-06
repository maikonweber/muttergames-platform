class_name CombatManager
extends Node2D
## Main combat loop: timeline, cards, win/loss.

const _CombatFx = preload("res://scripts/combat/combat_fx.gd")

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
	if units_root:
		units_root.y_sort_enabled = true
	_center_camera()
	if not GameState.run_active:
		GameState.start_new_run()

	## Zone handoff: keep combat_setup / return_to_zone and start that encounter.
	## Direct combat (debug): linear encounters without zone loop.
	var from_zone := bool(GameState.combat_setup.get("from_zone", false)) or GameState.return_to_zone
	if from_zone:
		var enc_id := str(GameState.combat_setup.get("encounter_id", GameState.next_encounter()))
		start_encounter(enc_id)
		if bool(GameState.combat_setup.get("surprise", false)) or bool(GameState.zone.get("altar_buff", false)):
			GameState.zone["altar_buff"] = false
			emit_signal("log_message", "Emboscada! Inimigos começam atrasados na timeline.")
			for u in units:
				if u.alive and not u.is_player:
					u.timeline_value += 4
			emit_signal("timeline_changed")
	else:
		GameState.return_to_zone = false
		GameState.combat_setup.clear()
		start_encounter(GameState.next_encounter())


func _center_camera() -> void:
	if camera == null or grid == null:
		return
	var local_center := grid.board_center_world()
	camera.position = grid.position + local_center
	# Larger map → zoom out
	camera.zoom = Vector2(0.55, 0.55)


func _focus_camera_on(unit: BattleUnit, smooth: bool = true) -> void:
	if camera == null or unit == null or not is_instance_valid(unit):
		return
	var target := unit.global_position + Vector2(0, -20)
	if smooth and is_inside_tree():
		var tw := create_tween()
		tw.tween_property(camera, "position", target, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	else:
		camera.position = target


func start_encounter(enc_id: String) -> void:
	encounter_id = enc_id
	boss_phase2_done = false
	boss_phase3_done = false
	_clear_units()
	if grid:
		grid.explored.clear()
		grid.visible_now.clear()
	_spawn_encounter(enc_id)
	for u in units:
		u.timeline_value = u.base_initiative + randi() % 3
	_refresh_fog()
	_center_camera()
	if grid:
		grid.queue_redraw()
	emit_signal("log_message", "— Campo de batalha amplo + FOW: %s —" % enc_id)
	emit_signal("log_message", "Explore com movimento. Inimigos só aparecem na visão da party.")
	phase = Phase.IDLE
	_advance_timeline()


func _refresh_fog() -> void:
	if grid == null:
		return
	var origins: Array = []
	for u in units:
		if u.is_player and u.alive:
			origins.append(u.cell)
	grid.recompute_vision_from_cells(origins, grid.vision_range)
	for u in units:
		if not is_instance_valid(u) or not u.alive:
			continue
		if u.is_player:
			u.set_fog_hidden(false)
		else:
			u.set_fog_hidden(not grid.is_cell_visible(u.cell))


func _clear_units() -> void:
	for u in units:
		if is_instance_valid(u):
			u.queue_free()
	units.clear()


func _spawn_encounter(enc_id: String) -> void:
	_spawn_party()

	match enc_id:
		"encounter_01":
			# 3v2 — enemies mid-map in fog
			_spawn_unit(_enemy("goblin", "Goblin", 16, 12, Color("7cba5a"), "flanker"), false, Vector2i(9, 3))
			_spawn_unit(_enemy("orc", "Orc", 24, 6, Color("c45c26"), "rusher"), false, Vector2i(11, 6))
		"encounter_02":
			# 3v3 — spread across the field
			_spawn_unit(_enemy("goblin", "Goblin", 16, 12, Color("7cba5a"), "flanker"), false, Vector2i(10, 2))
			_spawn_unit(_enemy("orc", "Orc", 24, 7, Color("c45c26"), "rusher"), false, Vector2i(12, 5))
			_spawn_unit(_enemy("archer", "Arqueiro", 18, 9, Color("c9a227"), "ranged"), false, Vector2i(14, 1))
		_:
			# Boss deep east + escort
			_spawn_unit(_enemy("captain", "Capitão", 56, 7, Color("b33a3a"), "boss"), false, Vector2i(13, 5))
			_spawn_unit(_enemy("goblin_b", "Escudeiro", 14, 11, Color("6aaa4a"), "flanker"), false, Vector2i(12, 3))
			_spawn_unit(_enemy("orc_b", "Bruto", 22, 6, Color("c45c26"), "rusher"), false, Vector2i(14, 7))


func _spawn_party() -> void:
	if GameState.party.is_empty():
		GameState.start_new_run()
	# West deployment — open field to the east under fog
	var slots: Array[Vector2i] = [Vector2i(1, 3), Vector2i(0, 5), Vector2i(1, 7)]
	for i in GameState.party.size():
		var hs: Dictionary = GameState.party[i]
		var cell: Vector2i = slots[i] if i < slots.size() else Vector2i(0, 3 + i)
		var def := {
			"id": str(hs.get("class_id", "espadachim")),
			"class_id": str(hs.get("class_id", "espadachim")),
			"display_name": str(hs.get("display_name", "Herói")),
			"max_hp": int(hs.get("max_hp", 30)),
			"max_energy": int(hs.get("max_energy", 3)),
			"energy_regen": int(hs.get("energy_regen", 3)),
			"base_initiative": int(hs.get("base_initiative", 10)),
			"color": hs.get("color", Color("4aa3ff")),
			"deck_ids": (hs.get("card_ids", []) as Array).duplicate(),
			"starting_stance": str(hs.get("starting_stance", "balance")),
			"ai_profile": "player",
			"party_index": i,
		}
		var hero := _spawn_unit(def, true, cell)
		hero.set_facing(BattleUnit.Facing.EAST)


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
	units_root.add_child(u)
	u.setup(def, player)
	u.place_on_grid(grid, cell)
	u.died.connect(_on_unit_died)
	u.damage_resolved.connect(_on_damage_resolved)
	units.append(u)
	return u


func _set_active_visuals(active: BattleUnit) -> void:
	for u in units:
		if is_instance_valid(u):
			u.set_active_turn(u == active and u.alive)


func _on_damage_resolved(unit: BattleUnit, dealt: int, blocked: int, parried: bool) -> void:
	if not is_instance_valid(unit):
		return
	var pos := unit.global_position + Vector2(0, -30)
	if parried:
		_CombatFx.miss_or_parry(self, pos, "PARRY")
		_CombatFx.impact(self, pos, "parry")
	elif blocked > 0 and dealt <= 0:
		_CombatFx.damage_number(self, pos, 0, true)
		_CombatFx.impact(self, pos, "block")
	elif blocked > 0:
		_CombatFx.floating(self, pos + Vector2(0, -12), "−%d" % dealt, Color("ff6b5a"))
		_CombatFx.floating(self, pos + Vector2(10, 0), "B%d" % blocked, Color("7eb6ff"))
		_CombatFx.impact(self, pos, "block")
		if dealt > 0:
			_CombatFx.impact(self, pos + Vector2(8, -8), "hit")
	else:
		_CombatFx.damage_number(self, pos, dealt, false)
		if dealt > 0:
			_CombatFx.impact(self, pos, "hit")


func get_hero() -> BattleUnit:
	## First living player (compat). Prefer active player on their turn.
	if active_unit and active_unit.is_player and active_unit.alive:
		return active_unit
	for u in units:
		if u.is_player and u.alive:
			return u
	return null


func get_player_units() -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	for u in units:
		if u.is_player and u.alive:
			out.append(u)
	return out


func nearest_player(from: BattleUnit) -> BattleUnit:
	var best: BattleUnit = null
	var best_d := 999
	for u in get_player_units():
		var d := grid.manhattan(from.cell, u.cell)
		if d < best_d:
			best_d = d
			best = u
	return best


func get_ai_target(attacker: BattleUnit) -> BattleUnit:
	## Taunt overrides; else nearest living hero.
	if attacker.taunt_from != null and is_instance_valid(attacker.taunt_from) and attacker.taunt_from.alive:
		return attacker.taunt_from
	return nearest_player(attacker)


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
	_set_active_visuals(active_unit)
	_refresh_fog()
	_focus_camera_on(active_unit, true)
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
	_refresh_fog()
	emit_signal("log_message", "%s — ⚡%d | %s" % [active_unit.display_name, active_unit.energy, active_unit.stance])
	hand_changed.emit()
	timeline_changed.emit()


func _begin_enemy_turn() -> void:
	## Skip local AI while in online PVP (server owns turns).
	if MultiplayerSession.is_online():
		phase = Phase.ENEMY_TURN
		emit_signal("log_message", "Aguardando oponente / servidor...")
		return
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
	## Online PVP uses dedicated arena + authoritative server.
	if MultiplayerSession.is_online():
		MultiplayerSession.send_end_turn()
		emit_signal("log_message", "Fim do turno (enviado ao servidor).")
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
				if u.fog_hidden or not grid.is_cell_visible(u.cell):
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
	# Card SFX
	var ab := get_node_or_null("/root/AudioBus")
	if ab and ab.has_method("card"):
		ab.card()
	# Visual pose + slash VFX for attack cards
	if card.card_type == CardDef.CardType.ATTACK:
		if target:
			caster.face_toward(target.cell)
			_CombatFx.slash(self, caster.global_position, target.global_position)
		elif cell != caster.cell:
			caster.face_toward(cell)
			_CombatFx.slash(self, caster.global_position, grid.to_global(grid.cell_to_world(cell)))
		else:
			_CombatFx.slash(self, caster.global_position, caster.global_position + Vector2(40, 10))
		caster.play_attack_pose()
	var result := EffectResolver.resolve(card.effects, caster, target, cell, grid, self)
	for line in result.get("log", []):
		emit_signal("log_message", str(line))
	# Consume card
	caster.discard_card_from_hand(selected_card_index)
	selected_card = null
	selected_card_index = -1
	grid.clear_highlights()
	phase = Phase.PLAYER_TURN
	_refresh_fog()
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
	_CombatFx.floating(self, unit.global_position + Vector2(0, -20), "DOWN", Color("ff8a7a"))
	_CombatFx.impact(self, unit.global_position + Vector2(0, -16), "death")
	# death fade runs on unit; hide after short delay
	_hide_dead_later(unit)
	_check_end()


func _hide_dead_later(unit: BattleUnit) -> void:
	await get_tree().create_timer(0.45).timeout
	if is_instance_valid(unit):
		unit.visible = false


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
		## Linear (non-zone) mode advances the encounter index here.
		## Zone mode lets GameState.finish_combat() own that + map kills.
		if not GameState.return_to_zone:
			GameState.encounter_index += 1
	else:
		emit_signal("log_message", "✕ DERROTA — a run termina.")
		if not GameState.return_to_zone:
			GameState.run_active = false
	combat_ended.emit(won)


func boss_try_phase2() -> bool:
	if boss_phase2_done:
		return false
	boss_phase2_done = true
	# Open a pit near hero / center
	if grid.in_bounds(Vector2i(3, 5)):
		grid.tiles[5][3] = TacticalGrid.TileType.PIT
	if grid.in_bounds(Vector2i(4, 5)):
		grid.tiles[5][4] = TacticalGrid.TileType.PIT
	grid.queue_redraw()
	_spawn_unit(_enemy("goblin_r", "Reforço", 12, 10, Color("7cba5a"), "flanker"), false, Vector2i(12, 4))
	_refresh_fog()
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
	return [
		"investida", "corte_arco", "desafio", "lamina_final", "ofensiva", "quebra_guarda", "respiracao",
		"escudo_forte", "provocar", "tiro", "tiro_preciso", "armadilha", "marcação", "fortificar",
	]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		end_player_turn()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_targeting()

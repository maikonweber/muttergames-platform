class_name ZoneManager
extends Node2D
## Exploration: move party, patrols, POIs, launch combat.

signal log_message(text: String)
signal state_changed
signal show_contact(enemy: Dictionary)
signal show_activity(poi: Dictionary)
signal hide_modals

const _ZM = preload("res://scripts/zone/zone_math.gd")

@onready var map: ZoneMap = $Map
@onready var entities: Node2D = $Entities
@onready var camera: Camera2D = $Camera2D

var party_cell: Vector2i = Vector2i(1, 5)
var move_points: int = 4
var move_max: int = 4
var vision_range: int = 4
var selected_path: Array[Vector2i] = []


func _ready() -> void:
	if not GameState.run_active or GameState.zone.is_empty():
		GameState.start_new_run()
	map.cell_clicked.connect(_on_cell_clicked)
	_load_from_state()
	_apply_combat_result_if_any()
	_update_fog()
	_refresh_view()
	emit_signal("log_message", "— Região Caída — fog of war ativo (visão %d)." % vision_range)
	emit_signal("log_message", "Tiles pretos = inexplorados. Escuros = memória. Claros = visão atual.")
	emit_signal("log_message", "Clique tile adjacente para mover. Espaço = turno do mapa.")
	state_changed.emit()


func _load_from_state() -> void:
	var z: Dictionary = GameState.zone
	map.setup(int(z.get("width", 16)), int(z.get("height", 12)))
	party_cell = z.get("party_cell", Vector2i(1, 5)) as Vector2i
	if typeof(party_cell) != TYPE_VECTOR2I:
		party_cell = Vector2i(int(party_cell.x), int(party_cell.y))
	move_points = int(z.get("move_points", 4))
	move_max = int(z.get("move_max", 4))
	vision_range = int(z.get("vision_range", 4))
	if z.has("explored"):
		map.set_explored_from_state(z.get("explored", []))


func _save_to_state() -> void:
	GameState.zone["party_cell"] = party_cell
	GameState.zone["move_points"] = move_points
	GameState.zone["vision_range"] = vision_range
	GameState.zone["explored"] = map.explored_to_state()


func _effective_vision() -> int:
	var v := vision_range
	# Forest reduces vision by 1
	if map.get_tile(party_cell) == ZoneMap.TileType.FOREST:
		v = maxi(2, v - 1)
	return v


func _update_fog() -> void:
	map.recompute_vision(party_cell, _effective_vision())
	_save_to_state()


func _apply_combat_result_if_any() -> void:
	if GameState.combat_result.is_empty():
		return
	var won := bool(GameState.combat_result.get("won", false))
	if won:
		emit_signal("log_message", "Vitória! A patrulha foi eliminada.")
		if bool(GameState.zone.get("boss_unlocked", false)):
			emit_signal("log_message", "O portão do Capitão está aberto.")
	else:
		emit_signal("log_message", "Derrota... a run terminou. Reinicie (F5) ou clique Nova Run.")
	GameState.combat_result.clear()
	GameState.return_to_zone = false


func _refresh_view() -> void:
	_update_fog()
	for c in entities.get_children():
		c.queue_free()
	_spawn_markers()
	_center_camera()
	_highlight_moves()
	state_changed.emit()


func _spawn_markers() -> void:
	# Party always visible
	_add_marker(party_cell, Color("4aa3ff"), "PARTY", 1.15)
	# Enemies — only in current vision
	for e in GameState.zone.get("enemies", []):
		if not bool(e.get("alive", true)):
			continue
		var cell: Vector2i = _as_cell(e.get("cell", Vector2i.ZERO))
		if not map.is_cell_visible(cell):
			continue
		var col := Color("e85d4c")
		match str(e.get("kind", "")):
			"orc":
				col = Color("c45c26")
			"archer":
				col = Color("c9a227")
			"captain":
				col = Color("b33a3a")
			_:
				col = Color("7cba5a")
		var label := str(e.get("kind", "?"))
		if str(e.get("id", "")) == "boss" and not bool(GameState.zone.get("boss_unlocked", false)):
			label = "???"
			col = col.darkened(0.4)
		_add_marker(cell, col, label, 1.0)
	# POIs — visible now, or explored memory (ghost label)
	for p in GameState.zone.get("pois", []):
		if bool(p.get("used", false)):
			continue
		var cell2: Vector2i = _as_cell(p.get("cell", Vector2i.ZERO))
		if not map.is_cell_visible(cell2) and not map.is_cell_explored(cell2):
			continue
		var pcol := Color("e0a8ff")
		match str(p.get("kind", "")):
			"altar":
				pcol = Color("ffe08a")
			"camp":
				pcol = Color("ff8a5a")
			_:
				pcol = Color("c9a0ff")
		var plabel := str(p.get("kind", "poi"))
		if not map.is_cell_visible(cell2):
			# memory: dim marker, still known
			pcol = pcol.darkened(0.45)
			plabel = "?"
		_add_marker(cell2, pcol, plabel, 0.85)


func _add_marker(cell: Vector2i, color: Color, label: String, scale: float) -> void:
	var n := Node2D.new()
	n.position = map.cell_to_world(cell)
	n.z_index = cell.x + cell.y + 10
	var poly := Polygon2D.new()
	poly.color = color
	var s := 10.0 * scale
	poly.polygon = PackedVector2Array([
		Vector2(0, -s), Vector2(s * 0.9, 0), Vector2(0, s * 0.55), Vector2(-s * 0.9, 0)
	])
	n.add_child(poly)
	var lab := Label.new()
	lab.text = label
	lab.position = Vector2(-24, -22)
	lab.add_theme_font_size_override("font_size", 10)
	lab.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	lab.add_theme_constant_override("outline_size", 3)
	lab.custom_minimum_size = Vector2(48, 12)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_child(lab)
	entities.add_child(n)


func _center_camera() -> void:
	if camera == null:
		return
	var target := map.position + map.cell_to_world(party_cell)
	var tw := create_tween()
	tw.tween_property(camera, "position", target, 0.2)


func _highlight_moves() -> void:
	var cells: Array[Vector2i] = []
	if move_points > 0 and GameState.run_active:
		for n in map.neighbors4(party_cell):
			if map.is_walkable(n) and not _enemy_at(n) and not _blocked_boss_gate(n):
				if map.move_cost(n) <= move_points:
					cells.append(n)
	map.set_highlights(cells, Color(0.3, 0.7, 1.0))


func _enemy_at(cell: Vector2i) -> Dictionary:
	for e in GameState.zone.get("enemies", []):
		if not bool(e.get("alive", true)):
			continue
		if _as_cell(e.get("cell")) == cell:
			return e
	return {}


func _poi_at(cell: Vector2i) -> Dictionary:
	for p in GameState.zone.get("pois", []):
		if bool(p.get("used", false)):
			continue
		if _as_cell(p.get("cell")) == cell:
			return p
	return {}


func _blocked_boss_gate(cell: Vector2i) -> bool:
	if map.get_tile(cell) == ZoneMap.TileType.BOSS_GATE:
		return not bool(GameState.zone.get("boss_unlocked", false))
	if map.get_tile(cell) == ZoneMap.TileType.EXIT:
		# exit always walkable as goal
		return false
	var e := _enemy_at(cell)
	if not e.is_empty() and str(e.get("id")) == "boss" and not bool(GameState.zone.get("boss_unlocked", false)):
		return true
	return false


func _as_cell(v) -> Vector2i:
	if v is Vector2i:
		return v
	if v is Vector2:
		return Vector2i(int(v.x), int(v.y))
	if v is Array and v.size() >= 2:
		return Vector2i(int(v[0]), int(v[1]))
	if v is Dictionary:
		return Vector2i(int(v.get("x", 0)), int(v.get("y", 0)))
	return Vector2i.ZERO


func _on_cell_clicked(cell: Vector2i) -> void:
	if not GameState.run_active:
		emit_signal("log_message", "Run encerrada. Use Nova Run.")
		return
	hide_modals.emit()
	if not map.is_cell_visible(cell) and not map.is_cell_explored(cell):
		emit_signal("log_message", "Névoa... explore para revelar.")
		return
	# Contact if click enemy adjacent or on enemy (must see them)
	var enemy := _enemy_at(cell)
	if not enemy.is_empty():
		if not map.is_cell_visible(cell):
			emit_signal("log_message", "Não há nada visível ali.")
			return
		if map.manhattan(party_cell, cell) <= 1:
			if str(enemy.get("id")) == "boss" and not bool(GameState.zone.get("boss_unlocked", false)):
				emit_signal("log_message", "O portão está selado. Derrote mais patrulhas.")
				return
			show_contact.emit(enemy)
			return
		else:
			emit_signal("log_message", "Aproxime-se da patrulha (adjacente).")
			return
	var poi := _poi_at(cell)
	if not poi.is_empty() and cell == party_cell:
		show_activity.emit(poi)
		return
	if not poi.is_empty() and map.manhattan(party_cell, cell) == 1:
		if _try_move_to(cell):
			if party_cell == cell:
				show_activity.emit(poi)
		return
	# Move only into currently visible adjacent tiles
	if map.manhattan(party_cell, cell) == 1:
		if not map.is_cell_visible(cell):
			emit_signal("log_message", "Fora da visão atual.")
			return
		_try_move_to(cell)
	else:
		emit_signal("log_message", "Só pode mover 1 tile por clique (ortogonal).")


func _try_move_to(cell: Vector2i) -> bool:
	if move_points <= 0:
		emit_signal("log_message", "Sem pontos de movimento. Espaço = passar turno.")
		return false
	if not map.is_walkable(cell):
		emit_signal("log_message", "Terreno bloqueado.")
		return false
	if _blocked_boss_gate(cell):
		emit_signal("log_message", "Ainda não pode passar.")
		return false
	if not _enemy_at(cell).is_empty():
		return false
	var cost := map.move_cost(cell)
	if cost > move_points:
		emit_signal("log_message", "PM insuficientes (floresta custa 2).")
		return false
	move_points -= cost
	party_cell = cell
	_save_to_state()
	emit_signal("log_message", "Grupo move para %s (PM %d/%d)" % [str(cell), move_points, move_max])
	# Exit?
	if map.get_tile(cell) == ZoneMap.TileType.EXIT:
		emit_signal("log_message", "★★ Você alcançou a saída da região! ★★")
		GameState.zone["exit_reached"] = true
	# Adjacent contact auto-prompt
	for n in map.neighbors4(party_cell):
		var e := _enemy_at(n)
		if not e.is_empty():
			if str(e.get("id")) == "boss" and not bool(GameState.zone.get("boss_unlocked", false)):
				continue
			_refresh_view()
			show_contact.emit(e)
			return true
	# POI on tile
	var p := _poi_at(party_cell)
	if not p.is_empty():
		_refresh_view()
		show_activity.emit(p)
		return true
	if move_points <= 0:
		_end_map_turn()
	else:
		_refresh_view()
	return true


func end_map_turn() -> void:
	if not GameState.run_active:
		return
	emit_signal("log_message", "Passa o turno do mapa...")
	_end_map_turn()


func _end_map_turn() -> void:
	_patrol_step()
	move_points = move_max
	_save_to_state()
	_update_fog()
	# Enemy walked into vision / contact
	for e in GameState.zone.get("enemies", []):
		if not bool(e.get("alive", true)):
			continue
		var ec := _as_cell(e.get("cell"))
		if not map.is_cell_visible(ec):
			continue
		if ec == party_cell or map.manhattan(ec, party_cell) == 0:
			_refresh_view()
			show_contact.emit(e)
			return
		if map.manhattan(ec, party_cell) == 1:
			_refresh_view()
			emit_signal("log_message", "Uma patrulha surge na névoa!")
			show_contact.emit(e)
			return
	_refresh_view()
	emit_signal("log_message", "Patrulhas se moveram. PM restaurados.")


func _patrol_step() -> void:
	for e in GameState.zone.get("enemies", []):
		if not bool(e.get("alive", true)):
			continue
		var patrol: Array = e.get("patrol", [])
		if patrol.is_empty():
			continue
		var cur := _as_cell(e.get("cell"))
		# find index
		var idx := 0
		for i in patrol.size():
			if _as_cell(patrol[i]) == cur:
				idx = i
				break
		var next_i := (idx + 1) % patrol.size()
		var next_c := _as_cell(patrol[next_i])
		if map.is_walkable(next_c) and _enemy_at(next_c).is_empty():
			e["cell"] = next_c


func start_fight(enemy: Dictionary, surprise: bool) -> void:
	hide_modals.emit()
	var setup := {
		"encounter_id": str(enemy.get("encounter", "encounter_01")),
		"enemy_map_id": str(enemy.get("id", "")),
		"surprise": surprise,
		"from_zone": true,
	}
	emit_signal("log_message", "Engajando %s..." % str(enemy.get("kind", "inimigo")))
	_save_to_state()
	GameState.begin_combat_from_zone(setup)


func try_flee(enemy: Dictionary) -> void:
	hide_modals.emit()
	# Always succeed for MVP; cost 1 map turn + slight damage flavor
	emit_signal("log_message", "Vocês recuam da patrulha...")
	move_points = 0
	_end_map_turn()


func resolve_activity(poi: Dictionary, choice: String) -> void:
	hide_modals.emit()
	var kind := str(poi.get("kind", ""))
	var pid := str(poi.get("id", ""))
	match kind:
		"ruin":
			if choice == "explore":
				var roll := randi() % 100
				if roll < 55:
					var pool: Array[String] = ["investida", "tiro", "escudo_forte", "desafio"]
					var card: String = pool[randi() % pool.size()]
					GameState.add_card_reward(card, randi() % maxi(1, GameState.party.size()))
					emit_signal("log_message", "Ruína: encontraram a carta %s!" % card)
				elif roll < 80:
					emit_signal("log_message", "Ruína: armadilha! O grupo se fere (sabor — sem HP de zona ainda).")
				else:
					emit_signal("log_message", "Ruína: nada além de poeira.")
		"altar":
			if choice == "pray":
				emit_signal("log_message", "Altar: uma bênção. Próximo combate: surpresa a seu favor se emboscar.")
				GameState.zone["altar_buff"] = true
			elif choice == "blood":
				emit_signal("log_message", "Altar: oferenda sombria. +1 kill contado como favor...")
				GameState.zone["kills"] = int(GameState.zone.get("kills", 0)) + 1
				if int(GameState.zone["kills"]) >= 2:
					GameState.zone["boss_unlocked"] = true
		"camp":
			if choice == "assault":
				# Spawn a tougher fight using encounter_02
				var fake := {"id": "camp_" + pid, "kind": "camp", "encounter": "encounter_02", "alive": true}
				# Mark POI used and fight
				_mark_poi_used(pid)
				start_fight(fake, true)
				return
			elif choice == "loot":
				emit_signal("log_message", "Acampamento abandonado: carta aleatória.")
				var loot: Array[String] = ["giro", "pressao", "marcação"]
				GameState.add_card_reward(loot[randi() % loot.size()], 0)
	_mark_poi_used(pid)
	_save_to_state()
	_refresh_view()


func _mark_poi_used(pid: String) -> void:
	for p in GameState.zone.get("pois", []):
		if str(p.get("id")) == pid:
			p["used"] = true


func new_run() -> void:
	GameState.start_new_run()
	_load_from_state()
	_refresh_view()
	emit_signal("log_message", "Nova run na Região Caída.")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		end_map_turn()

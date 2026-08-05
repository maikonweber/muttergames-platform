extends Control
## Authoritative PVP arena UI driven by MultiplayerSession / Fallen Game Server.

@onready var title: Label = $Root/Top/Title
@onready var status: Label = $Root/Top/Status
@onready var log_box: RichTextLabel = $Root/Side/Log
@onready var turn_label: Label = $Root/Board/TurnLabel
@onready var deadline_label: Label = $Root/Board/DeadlineLabel
@onready var avatar_self: ColorRect = $Root/Board/Duel/SelfPanel/Avatar
@onready var avatar_opp: ColorRect = $Root/Board/Duel/OppPanel/Avatar
@onready var hp_self: Label = $Root/Board/Duel/SelfPanel/HpSelf
@onready var hp_bar_self: ProgressBar = $Root/Board/Duel/SelfPanel/HpBarSelf
@onready var energy_label: Label = $Root/Board/Duel/SelfPanel/Energy
@onready var energy_bar_self: ProgressBar = $Root/Board/Duel/SelfPanel/EnergyBarSelf
@onready var status_self: Label = $Root/Board/Duel/SelfPanel/StatusSelf
@onready var hp_opp: Label = $Root/Board/Duel/OppPanel/HpOpp
@onready var hp_bar_opp: ProgressBar = $Root/Board/Duel/OppPanel/HpBarOpp
@onready var energy_label_opp: Label = $Root/Board/Duel/OppPanel/EnergyLabelOpp
@onready var energy_bar_opp: ProgressBar = $Root/Board/Duel/OppPanel/EnergyBarOpp
@onready var status_opp: Label = $Root/Board/Duel/OppPanel/StatusOpp
@onready var fx_layer: Control = $Root/FxLayer
@onready var hand_bar: HBoxContainer = $Root/HandBar
@onready var end_btn: Button = $Root/Bottom/EndTurnBtn
@onready var surrender_btn: Button = $Root/Bottom/SurrenderBtn
@onready var leave_btn: Button = $Root/Bottom/LeaveBtn
@onready var ping_btn: Button = $Root/Bottom/PingBtn

var _deadline_at: String = ""
var _my_unit_id: String = ""


func _ready() -> void:
	end_btn.pressed.connect(_on_end)
	surrender_btn.pressed.connect(_on_surrender)
	leave_btn.pressed.connect(_on_leave)
	ping_btn.pressed.connect(func(): MultiplayerSession.ping_udp())
	MultiplayerSession.status_changed.connect(_on_status)
	MultiplayerSession.snapshot_updated.connect(_on_snapshot)
	MultiplayerSession.events_received.connect(_on_events)
	MultiplayerSession.turn_started.connect(_on_turn)
	MultiplayerSession.match_ended.connect(_on_match_ended)
	MultiplayerSession.error_received.connect(func(c, m): _log("[Erro %s] %s" % [c, m]))
	MultiplayerSession.reconnecting_changed.connect(_on_reconnecting_changed)
	title.text = "PVP — Sala %s" % MultiplayerSession.room_code
	_my_unit_id = MultiplayerSession.unit_id
	_on_status("Arena PVP (servidor autoritativo)")
	if MultiplayerSession.last_snapshot.size() > 0:
		_on_snapshot(MultiplayerSession.last_snapshot)
	_refresh_buttons()


func _process(_delta: float) -> void:
	if _deadline_at == "":
		deadline_label.text = ""
		return
	var remaining := _seconds_until(_deadline_at)
	if remaining <= 0.0:
		deadline_label.text = ""
	else:
		deadline_label.text = "⏱ %ds" % int(ceil(remaining))


func _seconds_until(iso: String) -> float:
	var clean := iso.replace("T", " ")
	var dot := clean.find(".")
	if dot != -1:
		clean = clean.substr(0, dot)
	clean = clean.replace("Z", "")
	var target := Time.get_unix_time_from_datetime_string(clean)
	var now := Time.get_unix_time_from_system()
	return float(target - now)


func _on_status(text: String) -> void:
	status.text = text
	_log(text)


func _log(text: String) -> void:
	log_box.append_text(str(text) + "\n")


func _on_snapshot(state: Dictionary) -> void:
	var players: Array = state.get("players", [])
	var me: Dictionary = {}
	var opp: Dictionary = {}
	for p in players:
		if typeof(p) != TYPE_DICTIONARY:
			continue
		if str(p.get("client_id", "")) == MultiplayerSession.client_id:
			me = p
		else:
			opp = p

	var my_hp := int(me.get("hp", 0))
	var my_max_hp := int(me.get("max_hp", 30))
	var my_energy := int(me.get("energy", 0))
	var my_max_energy := int(me.get("max_energy", 3))
	hp_self.text = "Você (%s): %d/%d HP" % [str(me.get("display_name", "?")), my_hp, my_max_hp]
	energy_label.text = "Energia: %d/%d" % [my_energy, my_max_energy]
	status_self.text = _status_line(me)
	hp_bar_self.max_value = my_max_hp
	hp_bar_self.value = my_hp
	energy_bar_self.max_value = my_max_energy
	energy_bar_self.value = my_energy

	var opp_hp := int(opp.get("hp", 0))
	var opp_max_hp := int(opp.get("max_hp", 30))
	var opp_energy := int(opp.get("energy", 0))
	var opp_max_energy := int(opp.get("max_energy", 3))
	hp_opp.text = "Oponente (%s): %d/%d HP" % [str(opp.get("display_name", "?")), opp_hp, opp_max_hp]
	energy_label_opp.text = "Energia: %d/%d" % [opp_energy, opp_max_energy]
	status_opp.text = _status_line(opp)
	hp_bar_opp.max_value = opp_max_hp
	hp_bar_opp.value = opp_hp
	energy_bar_opp.max_value = opp_max_energy
	energy_bar_opp.value = opp_energy

	turn_label.text = "Turno %d | Status %s" % [int(state.get("turn", 0)), str(state.get("status", ""))]
	_deadline_at = str(state.get("deadline_at", ""))
	_rebuild_hand()
	_refresh_buttons()


func _status_line(p: Dictionary) -> String:
	var parts: Array[String] = []
	var stance := str(p.get("stance", "balance"))
	if stance != "balance":
		parts.append("Postura: %s" % ("Guarda 🛡" if stance == "guard" else "Ofensiva ⚔"))
	var block := int(p.get("block", 0))
	if block > 0:
		parts.append("Block %d" % block)
	var vuln := int(p.get("vulnerable_stacks", 0))
	if vuln > 0:
		parts.append("Vulnerável x%d" % vuln)
	if bool(p.get("no_attack_this_turn", false)):
		parts.append("Sem ataque")
	return " | ".join(parts)


func _rebuild_hand() -> void:
	for c in hand_bar.get_children():
		c.queue_free()
	var can_play := MultiplayerSession.is_my_turn()
	var me := MultiplayerSession.get_my_player_state()
	var energy := int(me.get("energy", 0))
	for card_id in MultiplayerSession.my_hand:
		var def := CardLibrary.get_card(str(card_id))
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(140, 44)
		btn.text = "%s (%d⚡)" % [def.display_name, def.cost]
		btn.tooltip_text = def.description
		btn.disabled = not can_play or def.cost > energy
		btn.pressed.connect(_on_play_card.bind(str(card_id)))
		hand_bar.add_child(btn)


func _on_events(events: Array, _server_seq: int) -> void:
	for e in events:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var op := str(e.get("op", ""))
		match op:
			"card_played":
				var def := CardLibrary.get_card(str(e.get("card_uid", "")))
				_log("%s jogou %s" % [str(e.get("client_id", "")).substr(0, 6), def.display_name])
			"damage":
				var amount := int(e.get("amount", 0))
				var blocked := int(e.get("blocked", 0))
				var target_id := str(e.get("target_id", ""))
				var suffix := " (%d bloqueado)" % blocked if blocked > 0 else ""
				_log("Dano %d%s → %s (HP %d)" % [amount, suffix, target_id, int(e.get("hp_after", 0))])
				_play_hit_fx(target_id, amount)
			"block_gained":
				_log("%s ganha %d Block (total %d)" % [str(e.get("unit_id", "")), int(e.get("amount", 0)), int(e.get("block_after", 0))])
				_spawn_popup(str(e.get("unit_id", "")), "+%d Block" % int(e.get("amount", 0)), Color("7eb6ff"))
			"block_stripped":
				_log("%s perde todo o Block" % str(e.get("unit_id", "")))
			"stance_changed":
				_log("%s muda para postura %s" % [str(e.get("unit_id", "")), str(e.get("stance", ""))])
			"vulnerable_applied":
				_log("%s está Vulnerável (x%d)" % [str(e.get("unit_id", "")), int(e.get("stacks", 0))])
				_spawn_popup(str(e.get("unit_id", "")), "Vulnerável!", Color("c98cff"))
			"reaction_triggered":
				_log("%s reagiu com %s — ataque negado!" % [str(e.get("unit_id", "")), str(e.get("kind", ""))])
				_spawn_popup(str(e.get("unit_id", "")), "PARRY!", Color("ffe08a"))
			"card_blocked":
				var reason := str(e.get("reason", ""))
				var why := "sem energia para atacar" if reason == "no_attack" else "requer postura Ofensiva"
				_log("Carta %s não teve efeito (%s)" % [str(e.get("card_uid", "")), why])
			"hand_drawn":
				pass
			"player_left":
				var grace_ms := int(e.get("grace_ms", 0))
				if grace_ms > 0:
					_log("Oponente caiu — %ds para reconectar antes da vitória por W.O." % int(grace_ms / 1000.0))
				else:
					_log("Oponente saiu da sala")
			"player_reconnected":
				_log("Oponente reconectou — partida continua")
			"turn_ended":
				_log("Turno encerrado")
			"match_ended":
				_log("Partida terminou (%s)" % str(e.get("reason", "")))
			_:
				_log(op)
	if MultiplayerSession.last_snapshot.size() > 0:
		_on_snapshot(MultiplayerSession.last_snapshot)
	_refresh_buttons()


func _avatar_for_unit(unit_id: String) -> ColorRect:
	return avatar_self if unit_id == _my_unit_id else avatar_opp


func _play_hit_fx(target_unit_id: String, amount: int) -> void:
	var avatar := _avatar_for_unit(target_unit_id)
	if amount > 0:
		_spawn_popup(target_unit_id, "-%d" % amount, Color("ff6b5a"))
		var tw := create_tween()
		tw.tween_property(avatar, "modulate", Color(1.6, 0.5, 0.5), 0.06)
		tw.tween_property(avatar, "modulate", Color.WHITE, 0.18)
		var origin := avatar.position
		var tw2 := create_tween()
		tw2.tween_property(avatar, "position", origin + Vector2(6, 0), 0.05)
		tw2.tween_property(avatar, "position", origin - Vector2(6, 0), 0.05)
		tw2.tween_property(avatar, "position", origin, 0.05)
	else:
		_spawn_popup(target_unit_id, "Bloqueado!", Color("cfd6dd"))


func _spawn_popup(unit_id: String, text: String, color: Color) -> void:
	var avatar := _avatar_for_unit(unit_id)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 3)
	fx_layer.add_child(label)
	var start_pos: Vector2 = avatar.global_position + Vector2(avatar.size.x * 0.5 - 20, -10)
	label.global_position = start_pos
	var tw := create_tween()
	tw.tween_property(label, "global_position", start_pos + Vector2(0, -46), 0.7)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.15)
	tw.tween_callback(label.queue_free)


func _on_turn(_client_id: String, turn: int, _deadline: String) -> void:
	turn_label.text = "Turno %d — %s" % [turn, "SUA VEZ" if MultiplayerSession.is_my_turn() else "aguarde"]
	_deadline_at = _deadline
	_rebuild_hand()
	_refresh_buttons()


func _on_match_ended(winner: String, reason: String) -> void:
	var won := winner == MultiplayerSession.client_id
	_log("Resultado: %s (%s)" % ["VITÓRIA" if won else "DERROTA", reason])
	_deadline_at = ""
	_refresh_buttons()


func _on_reconnecting_changed(active: bool, seconds_left: float) -> void:
	if active:
		_log("Conexão perdida — tentando reconectar (%ds restantes)..." % int(seconds_left))
	else:
		_log("Reconexão concluída ou encerrada")
	_rebuild_hand()
	_refresh_buttons()


func _refresh_buttons() -> void:
	var can := MultiplayerSession.is_my_turn()
	end_btn.disabled = not can
	surrender_btn.disabled = not MultiplayerSession.is_online()


func _on_play_card(card_id: String) -> void:
	MultiplayerSession.send_play_card(card_id)


func _on_end() -> void:
	MultiplayerSession.send_end_turn()


func _on_surrender() -> void:
	MultiplayerSession.send_surrender()


func _on_leave() -> void:
	MultiplayerSession.leave()
	GameState.pvp_active = false
	get_tree().change_scene_to_file(GameState.ZONE_SCENE)

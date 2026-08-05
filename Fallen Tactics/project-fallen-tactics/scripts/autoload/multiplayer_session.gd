extends Node
## PVP session state machine on top of NetClient (Fallen Game Server protocol).

signal session_ready(welcome: Dictionary)
signal snapshot_updated(state: Dictionary)
signal events_received(events: Array, server_seq: int)
signal match_started(seed: int)
signal turn_started(client_id: String, turn: int, deadline_at: String)
signal match_ended(winner_client_id: String, reason: String)
signal error_received(code: String, message: String)
signal status_changed(text: String)

var online: bool = false
var client_id: String = ""
var session_id: String = ""
var room_code: String = ""
var seat: int = -1
var seed: int = 0
var unit_id: String = ""
var last_snapshot: Dictionary = {}
var auth_token: String = ""
var display_name: String = "Tactician"
var cmd_seq: int = 0
var pending_room_code: String = "" ## empty = create
var my_turn: bool = false
var my_hand: Array = []

## Reconnect (grace period) state.
signal reconnecting_changed(active: bool, seconds_left: float)
var resume_token: String = ""
var reconnect_grace_ms: int = 60000
var _reconnecting: bool = false
var _reconnect_deadline_msec: int = 0
var _reconnect_token: int = 0
const RECONNECT_RETRY_SEC := 1.5


func _ready() -> void:
	NetClient.connected.connect(_on_ws_connected)
	NetClient.disconnected.connect(_on_ws_disconnected)
	NetClient.message_received.connect(_on_message)
	NetClient.connection_failed.connect(func(r): error_received.emit("CONNECT", r))


func is_online() -> bool:
	return online and session_id != ""


func is_my_turn() -> bool:
	return my_turn and is_online()


func host_pvp(name: String = "") -> void:
	if name != "":
		display_name = name
	pending_room_code = ""
	status_changed.emit("Conectando ao servidor PVP...")
	NetClient.connect_ws()


func join_pvp(code: String, name: String = "") -> void:
	if name != "":
		display_name = name
	pending_room_code = code.strip_edges().to_upper()
	status_changed.emit("Entrando na sala %s..." % pending_room_code)
	NetClient.connect_ws()


func leave() -> void:
	_reconnecting = false
	_reconnect_token += 1
	online = false
	client_id = ""
	session_id = ""
	room_code = ""
	resume_token = ""
	seat = -1
	my_turn = false
	last_snapshot = {}
	NetClient.disconnect_ws()
	status_changed.emit("Desconectado do PVP")


func send_play_card(card_uid: String, target_cell: Vector2i = Vector2i(-1, -1)) -> void:
	if not is_online():
		return
	cmd_seq += 1
	var cmd := {
		"op": "play_card",
		"unit_id": unit_id,
		"card_uid": card_uid,
	}
	if target_cell.x >= 0:
		cmd["target"] = {"cell": [target_cell.x, target_cell.y]}
	NetClient.send_dict({
		"v": 1,
		"type": "command",
		"session_id": session_id,
		"client_id": client_id,
		"seq": cmd_seq,
		"cmd": cmd,
	})


func send_end_turn() -> void:
	if not is_online():
		return
	cmd_seq += 1
	NetClient.send_dict({
		"v": 1,
		"type": "command",
		"session_id": session_id,
		"client_id": client_id,
		"seq": cmd_seq,
		"cmd": {"op": "end_turn", "unit_id": unit_id},
	})


func send_surrender() -> void:
	if not is_online():
		return
	cmd_seq += 1
	NetClient.send_dict({
		"v": 1,
		"type": "command",
		"session_id": session_id,
		"client_id": client_id,
		"seq": cmd_seq,
		"cmd": {"op": "surrender"},
	})


func request_resync() -> void:
	if not is_online():
		return
	NetClient.send_dict({
		"v": 1,
		"type": "resync_request",
		"session_id": session_id,
	})


func ping_udp() -> void:
	NetClient.send_udp_ping(session_id, client_id)


func _on_ws_connected() -> void:
	if _reconnecting and client_id != "" and resume_token != "":
		status_changed.emit("Reconectando — retomando sessão...")
		NetClient.send_dict({
			"v": 1,
			"type": "hello",
			"protocol_version": 1,
			"client_id": client_id,
			"resume_token": resume_token,
		})
		return
	status_changed.emit("WS conectado — enviando hello")
	var hello := {
		"v": 1,
		"type": "hello",
		"protocol_version": 1,
		"display_name": display_name,
	}
	if auth_token != "":
		hello["token"] = auth_token
	if pending_room_code != "":
		hello["room_code"] = pending_room_code
	NetClient.send_dict(hello)


func _on_ws_disconnected() -> void:
	online = false
	my_turn = false
	if session_id != "" and resume_token != "":
		_start_reconnect_flow()
	else:
		status_changed.emit("WS desconectado")


func _start_reconnect_flow() -> void:
	if _reconnecting:
		return
	_reconnecting = true
	_reconnect_token += 1
	_reconnect_deadline_msec = Time.get_ticks_msec() + reconnect_grace_ms
	status_changed.emit("Conexão perdida — tentando reconectar (%ds)..." % int(reconnect_grace_ms / 1000.0))
	reconnecting_changed.emit(true, reconnect_grace_ms / 1000.0)
	_attempt_reconnect(_reconnect_token)


func _attempt_reconnect(token: int) -> void:
	if token != _reconnect_token or not _reconnecting:
		return
	if Time.get_ticks_msec() >= _reconnect_deadline_msec:
		_give_up_reconnect()
		return
	NetClient.connect_ws()
	await get_tree().create_timer(RECONNECT_RETRY_SEC).timeout
	if token != _reconnect_token or not _reconnecting:
		return
	if online:
		return # resumed successfully in the meantime
	_attempt_reconnect(token)


func _give_up_reconnect() -> void:
	_reconnecting = false
	reconnecting_changed.emit(false, 0.0)
	status_changed.emit("Não foi possível reconectar a tempo — partida perdida por desconexão")
	my_turn = false


func _on_message(msg: Dictionary) -> void:
	var t := str(msg.get("type", ""))
	match t:
		"welcome":
			var was_reconnecting := _reconnecting
			online = true
			_reconnecting = false
			client_id = str(msg.get("client_id", ""))
			session_id = str(msg.get("session_id", ""))
			room_code = str(msg.get("room_code", ""))
			seat = int(msg.get("seat", -1))
			seed = int(msg.get("seed", 0))
			resume_token = str(msg.get("resume_token", resume_token))
			reconnect_grace_ms = int(msg.get("reconnect_grace_ms", reconnect_grace_ms))
			unit_id = "hero_alpha" if seat == 0 else "hero_bravo"
			cmd_seq = 0
			GameState.pvp_active = true
			GameState.pvp_room_code = room_code
			if was_reconnecting:
				reconnecting_changed.emit(false, 0.0)
				status_changed.emit("Reconectado — assento %d" % seat)
			else:
				status_changed.emit("Sala %s — assento %d" % [room_code, seat])
			session_ready.emit(msg)
			ping_udp()
		"snapshot":
			last_snapshot = msg.get("state", {}) as Dictionary
			_refresh_turn_from_snapshot(last_snapshot)
			snapshot_updated.emit(last_snapshot)
		"event":
			var events: Array = msg.get("events", [])
			events_received.emit(events, int(msg.get("server_seq", 0)))
			_handle_events(events)
		"error":
			var code := str(msg.get("code", "ERROR"))
			error_received.emit(code, str(msg.get("message", "")))
			status_changed.emit("Erro: %s" % str(msg.get("message", "")))
			var permanent_resume_failures := ["RESUME_TOKEN_INVALID", "RESUME_FAILED", "UNKNOWN_CLIENT", "NO_SESSION", "MATCH_ALREADY_FINISHED"]
			if _reconnecting and code in permanent_resume_failures:
				_reconnect_token += 1
				_give_up_reconnect()
		"pong":
			pass
		"goodbye":
			status_changed.emit("Servidor encerrou: %s" % str(msg.get("reason", "")))
			leave()
		_:
			pass


func _handle_events(events: Array) -> void:
	for e in events:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var op := str(e.get("op", ""))
		match op:
			"match_started":
				match_started.emit(int(e.get("seed", seed)))
				status_changed.emit("Partida iniciada")
				_go_to_arena()
			"turn_started":
				var cid := str(e.get("client_id", ""))
				my_turn = cid == client_id
				turn_started.emit(cid, int(e.get("turn", 0)), str(e.get("deadline_at", "")))
				status_changed.emit("Sua vez" if my_turn else "Vez do oponente")
			"match_ended":
				var winner := str(e.get("winner_client_id", ""))
				match_ended.emit(winner, str(e.get("reason", "")))
				my_turn = false
				status_changed.emit("Fim: %s" % str(e.get("reason", "")))
			"player_joined":
				status_changed.emit("%s entrou (seat %s)" % [str(e.get("display_name", "")), str(e.get("seat", ""))])
			"player_left":
				if str(e.get("client_id", "")) != client_id:
					var grace_ms := int(e.get("grace_ms", 0))
					if grace_ms > 0:
						status_changed.emit("Oponente desconectado — aguardando reconexão (%ds)" % int(grace_ms / 1000.0))
					else:
						status_changed.emit("Oponente saiu")
			"player_reconnected":
				if str(e.get("client_id", "")) != client_id:
					status_changed.emit("Oponente reconectou")
			_:
				pass


func _refresh_turn_from_snapshot(state: Dictionary) -> void:
	var active := str(state.get("active_client_id", ""))
	my_turn = active == client_id and str(state.get("status", "")) == "active"
	var me := get_my_player_state()
	if me.size() > 0 and me.get("hand") != null:
		my_hand = me.get("hand", [])


func get_my_player_state() -> Dictionary:
	for p in last_snapshot.get("players", []):
		if typeof(p) == TYPE_DICTIONARY and str(p.get("client_id", "")) == client_id:
			return p
	return {}


func get_opponent_player_state() -> Dictionary:
	for p in last_snapshot.get("players", []):
		if typeof(p) == TYPE_DICTIONARY and str(p.get("client_id", "")) != client_id:
			return p
	return {}


func _go_to_arena() -> void:
	if get_tree().current_scene and get_tree().current_scene.scene_file_path.ends_with("pvp_arena.tscn"):
		return
	get_tree().change_scene_to_file("res://scenes/pvp/pvp_arena.tscn")

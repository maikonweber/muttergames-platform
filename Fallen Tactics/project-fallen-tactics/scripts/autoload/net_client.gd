extends Node
## Low-level WebSocket + optional UDP probe for Fallen Game Server.

signal connected
signal disconnected
signal message_received(msg: Dictionary)
signal connection_failed(reason: String)
signal udp_pong(payload: Dictionary)

var ws_url: String = "ws://127.0.0.1:4010/v1/session"
var http_base: String = "http://127.0.0.1:4010"
var udp_host: String = "127.0.0.1"
var udp_port: int = 9001

var _socket: WebSocketPeer = WebSocketPeer.new()
var _udp: PacketPeerUDP = PacketPeerUDP.new()
var _was_open: bool = false
var _udp_bound: bool = false


func _ready() -> void:
	_load_config()


func _process(_delta: float) -> void:
	_poll_ws()
	_poll_udp()


func _load_config() -> void:
	## Optional override file next to executable / project user://.
	var cfg := ConfigFile.new()
	if cfg.load("user://fallen_net.cfg") == OK:
		ws_url = str(cfg.get_value("net", "ws_url", ws_url))
		http_base = str(cfg.get_value("net", "http_base", http_base))
		udp_host = str(cfg.get_value("net", "udp_host", udp_host))
		udp_port = int(cfg.get_value("net", "udp_port", udp_port))
	elif cfg.load("res://fallen_net.cfg") == OK:
		ws_url = str(cfg.get_value("net", "ws_url", ws_url))
		http_base = str(cfg.get_value("net", "http_base", http_base))
		udp_host = str(cfg.get_value("net", "udp_host", udp_host))
		udp_port = int(cfg.get_value("net", "udp_port", udp_port))


func is_ws_open() -> bool:
	return _socket.get_ready_state() == WebSocketPeer.STATE_OPEN


func connect_ws(url: String = "") -> void:
	if url != "":
		ws_url = url
	_was_open = false
	var err := _socket.connect_to_url(ws_url)
	if err != OK:
		connection_failed.emit("connect_to_url failed: %s" % err)


func disconnect_ws() -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_socket.close()
	_was_open = false


func send_dict(msg: Dictionary) -> void:
	if not is_ws_open():
		push_warning("NetClient: WS not open")
		return
	var payload := JSON.stringify(msg)
	_socket.send_text(payload)


func create_room_http() -> void:
	## Fire-and-forget helper; MultiplayerSession may use WS hello instead.
	var req := HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(func(_r, code, _h, body):
		if code >= 200 and code < 300:
			var data = JSON.parse_string(body.get_string_from_utf8())
			if typeof(data) == TYPE_DICTIONARY:
				message_received.emit({"type": "http_room_created", "data": data})
		req.queue_free()
	)
	req.request("%s/v1/rooms" % http_base, ["Content-Type: application/json"], HTTPClient.METHOD_POST, "{}")


func send_udp_ping(session_id: String = "", client_id: String = "") -> void:
	if not _udp_bound:
		var err := _udp.bind(0)
		if err != OK:
			push_warning("NetClient: UDP bind failed")
			return
		_udp_bound = true
	_udp.set_dest_address(udp_host, udp_port)
	var msg := {
		"magic": "FTPV",
		"v": 1,
		"type": "ping",
		"seq": Time.get_ticks_msec(),
		"session_id": session_id,
		"client_id": client_id,
		"payload": {"t": Time.get_ticks_msec()},
	}
	_udp.put_packet(JSON.stringify(msg).to_utf8_buffer())


func _poll_ws() -> void:
	_socket.poll()
	var state := _socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not _was_open:
			_was_open = true
			connected.emit()
		while _socket.get_available_packet_count() > 0:
			var packet := _socket.get_packet()
			var text := packet.get_string_from_utf8()
			var data = JSON.parse_string(text)
			if typeof(data) == TYPE_DICTIONARY:
				message_received.emit(data)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		if _was_open:
			_was_open = false
			disconnected.emit()
		var code := _socket.get_close_code()
		if code != -1 and code != 1000:
			connection_failed.emit("WS closed code=%s" % code)


func _poll_udp() -> void:
	if not _udp_bound:
		return
	while _udp.get_available_packet_count() > 0:
		var packet := _udp.get_packet()
		var data = JSON.parse_string(packet.get_string_from_utf8())
		if typeof(data) == TYPE_DICTIONARY and str(data.get("type", "")) == "pong":
			udp_pong.emit(data)

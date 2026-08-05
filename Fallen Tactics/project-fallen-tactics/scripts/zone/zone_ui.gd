extends CanvasLayer
## Zone HUD + contact/activity modals + PVP lobby entry.

@onready var zone: ZoneManager = get_parent()
@onready var log_label: RichTextLabel = $Root/Side/Log
@onready var status_label: Label = $Root/Top/StatusLabel
@onready var title_label: Label = $Root/Top/TitleLabel
@onready var help_label: Label = $Root/Bottom/HelpLabel
@onready var pass_btn: Button = $Root/Bottom/PassBtn
@onready var new_run_btn: Button = $Root/Bottom/NewRunBtn
@onready var pvp_btn: Button = $Root/Bottom/PvpBtn
@onready var modal: PanelContainer = $Root/Modal
@onready var modal_box: VBoxContainer = $Root/Modal/Margin/VBox


func _ready() -> void:
	zone.log_message.connect(_on_log)
	zone.state_changed.connect(_refresh_status)
	zone.show_contact.connect(_on_contact)
	zone.show_activity.connect(_on_activity)
	zone.hide_modals.connect(_hide_modal)
	pass_btn.pressed.connect(func(): zone.end_map_turn())
	new_run_btn.pressed.connect(func(): zone.new_run())
	pvp_btn.pressed.connect(_open_pvp_lobby)
	MultiplayerSession.status_changed.connect(_on_log)
	MultiplayerSession.error_received.connect(func(c, m): _on_log("[PVP %s] %s" % [c, m]))
	MultiplayerSession.session_ready.connect(func(w):
		_on_log("=== CÓDIGO DA SALA: %s (compartilhe) ===" % str(w.get("room_code", "")))
	)
	modal.visible = false
	_on_log("Project Fallen Tactics — Zona de exploração")
	_on_log("PVP: use o botão PVP Online (servidor ws://127.0.0.1:4010)")
	_refresh_status()


func _on_log(text: String) -> void:
	log_label.append_text(str(text) + "\n")


func _refresh_status() -> void:
	var kills := int(GameState.zone.get("kills", 0))
	var boss := "ABERTO" if bool(GameState.zone.get("boss_unlocked", false)) else "SELADO"
	var vis := zone.vision_range
	if zone.map and zone.map.get_tile(zone.party_cell) == ZoneMap.TileType.FOREST:
		vis = maxi(2, vis - 1)
	status_label.text = "PM %d/%d  |  Visão %d  |  Célula %s  |  Baixas %d  |  Portão %s" % [
		zone.move_points,
		zone.move_max,
		vis,
		str(zone.party_cell),
		kills,
		boss,
	]
	if not GameState.run_active:
		title_label.text = "RUN ENCERRADA"
	elif bool(GameState.zone.get("exit_reached", false)):
		title_label.text = "REGIÃO CONCLUÍDA"
	else:
		title_label.text = "Região Caída — Exploração"


func _hide_modal() -> void:
	modal.visible = false
	for c in modal_box.get_children():
		c.queue_free()


func _open_pvp_lobby() -> void:
	_hide_modal()
	modal.visible = true
	var title := Label.new()
	title.text = "PVP Online — Fallen Game Server"
	modal_box.add_child(title)
	var hint := Label.new()
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.text = "Crie uma sala e compartilhe o código de 6 caracteres, ou entre em uma sala existente."
	modal_box.add_child(hint)
	var name_edit := LineEdit.new()
	name_edit.placeholder_text = "Seu nome"
	name_edit.text = GameState.pvp_display_name
	modal_box.add_child(name_edit)
	var code_edit := LineEdit.new()
	code_edit.placeholder_text = "Código da sala (entrar)"
	code_edit.max_length = 6
	modal_box.add_child(code_edit)
	var create_btn := Button.new()
	create_btn.text = "Criar sala PVP"
	create_btn.pressed.connect(func():
		GameState.pvp_display_name = name_edit.text.strip_edges()
		if GameState.pvp_display_name == "":
			GameState.pvp_display_name = "Tactician"
		_hide_modal()
		_on_log("Criando sala PVP...")
		MultiplayerSession.host_pvp(GameState.pvp_display_name)
	)
	modal_box.add_child(create_btn)
	var join_btn := Button.new()
	join_btn.text = "Entrar na sala"
	join_btn.pressed.connect(func():
		GameState.pvp_display_name = name_edit.text.strip_edges()
		var code := code_edit.text.strip_edges().to_upper()
		if code.length() != 6:
			_on_log("Informe um código de 6 caracteres.")
			return
		_hide_modal()
		_on_log("Entrando na sala %s..." % code)
		MultiplayerSession.join_pvp(code, GameState.pvp_display_name)
	)
	modal_box.add_child(join_btn)
	var cancel := Button.new()
	cancel.text = "Cancelar"
	cancel.pressed.connect(_hide_modal)
	modal_box.add_child(cancel)


func _on_contact(enemy: Dictionary) -> void:
	_hide_modal()
	modal.visible = true
	var kind := str(enemy.get("kind", "inimigo"))
	var title := Label.new()
	title.text = "Contato: %s" % kind
	modal_box.add_child(title)
	var desc := Label.new()
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.text = "Uma patrulha bloqueia o caminho. Emboscar dá vantagem (surpresa)."
	modal_box.add_child(desc)
	var fight := Button.new()
	fight.text = "Lutar (surpresa)"
	fight.pressed.connect(func(): zone.start_fight(enemy, true))
	modal_box.add_child(fight)
	var fight2 := Button.new()
	fight2.text = "Lutar (frontal)"
	fight2.pressed.connect(func(): zone.start_fight(enemy, false))
	modal_box.add_child(fight2)
	var flee := Button.new()
	flee.text = "Fugir (passa turno do mapa)"
	flee.pressed.connect(func(): zone.try_flee(enemy))
	modal_box.add_child(flee)


func _on_activity(poi: Dictionary) -> void:
	_hide_modal()
	modal.visible = true
	var kind := str(poi.get("kind", "poi"))
	var title := Label.new()
	title.text = "Atividade: %s" % kind
	modal_box.add_child(title)
	match kind:
		"ruin":
			var b := Button.new()
			b.text = "Explorar ruína"
			b.pressed.connect(func(): zone.resolve_activity(poi, "explore"))
			modal_box.add_child(b)
		"altar":
			var b1 := Button.new()
			b1.text = "Orar (bênção de emboscada)"
			b1.pressed.connect(func(): zone.resolve_activity(poi, "pray"))
			modal_box.add_child(b1)
			var b2 := Button.new()
			b2.text = "Oferenda sombria (ajuda a abrir portão)"
			b2.pressed.connect(func(): zone.resolve_activity(poi, "blood"))
			modal_box.add_child(b2)
		"camp":
			var b1 := Button.new()
			b1.text = "Assaltar acampamento (combate 3v3)"
			b1.pressed.connect(func(): zone.resolve_activity(poi, "assault"))
			modal_box.add_child(b1)
			var b2 := Button.new()
			b2.text = "Saquear restos (carta)"
			b2.pressed.connect(func(): zone.resolve_activity(poi, "loot"))
			modal_box.add_child(b2)
	var cancel := Button.new()
	cancel.text = "Deixar para depois"
	cancel.pressed.connect(_hide_modal)
	modal_box.add_child(cancel)

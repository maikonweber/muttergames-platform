extends Control

@onready var resources_label: Label = %Resources
@onready var asteroid_label: Label = %Asteroids
@onready var orbits_box: VBoxContainer = %Orbits
@onready var status_label: Label = %Status
@onready var event_panel: PanelContainer = %EventPanel
@onready var event_text: Label = %EventText
@onready var choices_box: HBoxContainer = %Choices
@onready var content: VBoxContainer = %Content
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var tutorial_label: Label = %Tutorial
@onready var header: HBoxContainer = %Header
@onready var title_label: Label = %Title
@onready var save_button: Button = %Save
@onready var settings_button: Button = %Settings

var _dragging := false
var _drag_offset := Vector2i.ZERO
var _auto_expanded_for_event := false

const ANCHOR_LABELS := {
	"bottom_right": "Inferior direito (padrão)",
	"bottom_left": "Inferior esquerdo",
	"top_right": "Superior direito",
	"top_left": "Superior esquerdo",
	"none": "Nenhuma (posição manual)",
}

func _ready() -> void:
	GameState.state_changed.connect(refresh)
	GameState.notification_sent.connect(show_status)
	GameState.event_started.connect(show_event)
	# set_*_no_signal evita disparar os handlers (e efeitos colaterais como som/reposicionar
	# a janela) só por sincronizar os controles com o estado carregado do save.
	%Notifications.set_pressed_no_signal(GameState.settings.notifications_enabled)
	%AlwaysOnTop.set_pressed_no_signal(GameState.settings.always_on_top)
	%CloseMinimizes.set_pressed_no_signal(GameState.settings.close_minimizes)
	%LargeText.set_pressed_no_signal(GameState.settings.accessibility_large_text)
	%UpdateRate.set_value_no_signal(GameState.settings.update_rate)
	%Opacity.set_value_no_signal(GameState.settings.window_opacity)
	%TrayEnabled.set_pressed_no_signal(GameState.settings.tray_enabled)
	%ClickThrough.set_pressed_no_signal(GameState.settings.click_through)
	%SfxEnabled.set_pressed_no_signal(GameState.settings.sfx_enabled)
	%Volume.set_value_no_signal(GameState.settings.master_volume)
	%NativeNotifications.set_pressed_no_signal(GameState.settings.native_notifications)
	_populate_monitor_options()
	_populate_anchor_options()
	header.mouse_default_cursor_shape = Control.CURSOR_MOVE
	header.gui_input.connect(_on_header_gui_input)
	_apply_compact_visuals()
	refresh()

## Arrasta a janela pelo cabeçalho — necessário porque a barra idle (compacta) fica sem
## bordas/título do SO. Ao soltar, a âncora vira "manual" para não voltar a saltar de volta
## ao canto configurado (ver GameSettings.reposition).
func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = DisplayServer.mouse_get_position() - get_window().position
		elif _dragging:
			_dragging = false
			if GameState.settings.anchor != "none":
				GameState.settings.anchor = "none"
				%Anchor.selected = GameSettings.ANCHORS.find("none")
				GameState.save_game()
	elif event is InputEventMouseMotion and _dragging:
		get_window().position = DisplayServer.mouse_get_position() - _drag_offset

## Mostra apenas o essencial (recursos + alternar/pausar) na barra idle compacta; a janela
## expandida mostra título, salvar, configurações e todo o restante do conteúdo.
func _apply_compact_visuals() -> void:
	var compact := GameState.compact_mode
	title_label.visible = not compact
	save_button.visible = not compact
	settings_button.visible = not compact
	for index in range(2, content.get_child_count()):
		content.get_child(index).visible = not compact
	%Compact.text = "Expandir" if compact else "Modo compacto"

func _populate_monitor_options() -> void:
	var option: OptionButton = %Monitor
	option.clear()
	option.add_item("Automático (monitor atual)")
	option.set_item_metadata(0, -1)
	for i in DisplayServer.get_screen_count():
		option.add_item("Monitor %d" % (i + 1))
		option.set_item_metadata(i + 1, i)
	for i in option.item_count:
		if int(option.get_item_metadata(i)) == GameState.settings.monitor_index:
			option.selected = i
			return
	option.selected = 0

func _populate_anchor_options() -> void:
	var option: OptionButton = %Anchor
	option.clear()
	for anchor in GameSettings.ANCHORS:
		option.add_item(str(ANCHOR_LABELS.get(anchor, anchor)))
		option.set_item_metadata(option.item_count - 1, anchor)
	option.selected = GameSettings.ANCHORS.find(GameState.settings.anchor)

func refresh() -> void:
	var lines: Array[String] = []
	for resource in ["Materia", "Energia", "Agua", "Biomassa", "Conhecimento", "Essencia"]:
		lines.append("%s: %d" % [resource, GameState.inventory.amounts[resource]])
	resources_label.text = "   ".join(lines)
	asteroid_label.text = "Asteroides: %d / 2 necessarios" % GameState.asteroids
	tutorial_label.text = GameState.tutorial.current_text()
	tutorial_label.visible = not GameState.tutorial.dismissed
	var scale := 1.18 if GameState.settings.accessibility_large_text else 1.0
	content.scale = Vector2(scale, scale)
	modulate.a = GameState.settings.window_opacity
	for child in orbits_box.get_children(): child.queue_free()
	for orbit in GameState.ORBITS:
		var planet := GameState.planet_at_orbit(orbit)
		var row := HBoxContainer.new()
		var label := Label.new(); label.custom_minimum_size.x = 510
		if planet == null:
			label.text = "Orbita %d — vazia" % (orbit + 1)
			var forge := Button.new(); forge.text = "Forjar planeta"; forge.disabled = GameState.asteroids < 2
			forge.pressed.connect(func(): GameState.forge_planet(orbit))
			row.add_child(label); row.add_child(forge)
		else:
			label.text = "Orbita %d — %s %s | %s | atmosfera %d%% | agua %d%%" % [orbit + 1, planet.rarity, planet.type, planet.stage_name(), planet.atmosphere, planet.water]
			var action := Button.new()
			if not planet.is_habitable():
				action.text = "Terraformar"; action.pressed.connect(func(): GameState.terraform(planet))
			elif not planet.life:
				action.text = "Iniciar vida"; action.pressed.connect(func(): GameState.start_life(planet))
			elif not planet.civilization:
				action.text = "Evoluir civilizacao"; action.pressed.connect(func(): GameState.advance_civilization(planet))
			else: action.text = "Civilizacao ativa"; action.disabled = true
			row.add_child(label); row.add_child(action)
		orbits_box.add_child(row)

func show_status(message: String) -> void:
	status_label.text = message

func show_event(event: CosmicEvent) -> void:
	# A barra idle é pequena demais para mostrar um evento com opções; expande
	# temporariamente e volta ao modo compacto assim que o jogador escolher.
	if GameState.compact_mode:
		_auto_expanded_for_event = true
		GameState.set_compact_mode(false)
		_apply_compact_visuals()
	event_panel.visible = true
	event_text.text = "%s\n%s" % [event.title, event.description]
	for child in choices_box.get_children(): child.queue_free()
	for choice in event.choices:
		var button := Button.new(); button.text = choice.label
		button.pressed.connect(func():
			GameState.resolve_event(choice)
			event_panel.visible = false
			if _auto_expanded_for_event:
				_auto_expanded_for_event = false
				GameState.set_compact_mode(true)
				_apply_compact_visuals()
		)
		choices_box.add_child(button)

func _on_create_asteroid_pressed() -> void: GameState.create_asteroid()
func _on_collect_water_pressed() -> void:
	if not GameState.collect_water():
		show_status("É necessária Energia para capturar água."); AudioService.play("error")
func _on_research_pressed() -> void:
	if not GameState.research():
		show_status("Pesquisa exige Energia e Biomassa."); AudioService.play("error")
func _on_pause_pressed() -> void:
	GameState.paused = not GameState.paused
	%Pause.text = "Retomar" if GameState.paused else "Pausar"
func _on_save_pressed() -> void: show_status("Partida salva." if GameState.save_game() else "Falha ao salvar.")
func _on_prestige_pressed() -> void:
	if not GameState.prestige():
		show_status("Prestigio exige os tres planetas orbitais."); AudioService.play("error")
func _on_compact_pressed() -> void:
	GameState.set_compact_mode(not GameState.compact_mode)
	_apply_compact_visuals()

func _on_settings_pressed() -> void:
	settings_panel.visible = not settings_panel.visible

func _on_notifications_toggled(enabled: bool) -> void:
	GameState.settings.notifications_enabled = enabled; GameState.apply_settings()
func _on_always_on_top_toggled(enabled: bool) -> void:
	GameState.settings.always_on_top = enabled; GameState.apply_settings()
func _on_close_minimizes_toggled(enabled: bool) -> void:
	GameState.settings.close_minimizes = enabled; GameState.apply_settings()
func _on_large_text_toggled(enabled: bool) -> void:
	GameState.settings.accessibility_large_text = enabled; GameState.apply_settings()
func _on_update_rate_changed(value: float) -> void:
	GameState.settings.update_rate = value; GameState.apply_settings()
func _on_opacity_changed(value: float) -> void:
	GameState.settings.window_opacity = value; GameState.apply_settings()
func _on_dismiss_tutorial_pressed() -> void:
	GameState.tutorial.dismissed = true; GameState.state_changed.emit()

func _on_tray_enabled_toggled(enabled: bool) -> void:
	GameState.settings.tray_enabled = enabled; GameState.apply_settings()
func _on_click_through_toggled(enabled: bool) -> void:
	GameState.settings.click_through = enabled; GameState.apply_settings()
func _on_monitor_selected(index: int) -> void:
	GameState.settings.monitor_index = int(%Monitor.get_item_metadata(index))
	GameState.apply_settings()
func _on_anchor_selected(index: int) -> void:
	GameState.settings.anchor = str(%Anchor.get_item_metadata(index))
	GameState.apply_settings()
func _on_sfx_enabled_toggled(enabled: bool) -> void:
	GameState.settings.sfx_enabled = enabled
	if enabled: AudioService.play("chime")
func _on_volume_changed(value: float) -> void:
	GameState.settings.master_volume = value
func _on_native_notifications_toggled(enabled: bool) -> void:
	GameState.settings.native_notifications = enabled

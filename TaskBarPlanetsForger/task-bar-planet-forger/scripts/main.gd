extends Control

@onready var resource_cards: HBoxContainer = %ResourceCards
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
@onready var margin: MarginContainer = %Margin
@onready var idle_bar: MarginContainer = %IdleBar
@onready var idle_status: Label = %IdleStatus
@onready var idle_resources: Label = %IdleResources
@onready var inspector_panel: PanelContainer = %PlanetInspector
@onready var inspector_title: Label = %InspectorTitle
@onready var inspector_details: Label = %InspectorDetails
@onready var atmosphere_bar: ProgressBar = %AtmosphereBar
@onready var water_bar: ProgressBar = %WaterBar
@onready var orbital_map: OrbitalMap = %OrbitalMap
@onready var create_asteroid_button: Button = $"Margin/Content/Actions/CreateAsteroid"
@onready var collect_water_button: Button = $"Margin/Content/Actions/CollectWater"
@onready var research_button: Button = $"Margin/Content/Actions/Research"
@onready var prestige_button: Button = $"Margin/Content/Actions/Prestige"
@onready var prestige_confirmation: ConfirmationDialog = %PrestigeConfirmation

var _dragging := false
var _drag_offset := Vector2i.ZERO
var _auto_expanded_for_event := false
var _selected_planet_id := ""
var _orbit_view_signature := ""

const COLOR_VOID := Color("09111b")
const COLOR_PANEL := Color("101e2b")
const COLOR_PANEL_RAISED := Color("15293a")
const COLOR_BORDER := Color("2c6076")
const COLOR_CYAN := Color("57d9e8")
const COLOR_GOLD := Color("f6be46")
const COLOR_TEXT := Color("d8edf2")

func _box(color: Color, border: Color = COLOR_BORDER, radius: int = 7) -> StyleBoxFlat:

	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 7
	box.content_margin_bottom = 7
	return box

func _apply_ui_theme() -> void:
	# A cena usa controles nativos, mas a paleta e os cartões seguem o mockup UI salvo
	# em assets/ui. Mantemos a árvore existente para não quebrar os fluxos jogáveis.
	$Background.color = COLOR_VOID
	title_label.add_theme_color_override("font_color", COLOR_GOLD)
	title_label.add_theme_font_size_override("font_size", 26)
	(resource_cards.get_parent() as PanelContainer).add_theme_stylebox_override("panel", _box(Color("0d1a26"), COLOR_BORDER, 8))
	status_label.add_theme_color_override("font_color", Color("7ee8ad"))
	tutorial_label.add_theme_stylebox_override("normal", _box(Color("1d2630"), COLOR_GOLD, 7))
	event_panel.add_theme_stylebox_override("panel", _box(Color("251318"), Color("d64d40"), 8))
	settings_panel.add_theme_stylebox_override("panel", _box(COLOR_PANEL, COLOR_BORDER, 8))
	inspector_panel.add_theme_stylebox_override("panel", _box(Color("102434"), COLOR_CYAN, 8))
	inspector_title.add_theme_color_override("font_color", COLOR_CYAN)
	atmosphere_bar.add_theme_stylebox_override("background", _box(Color("09131e"), COLOR_BORDER, 4))
	atmosphere_bar.add_theme_stylebox_override("fill", _box(Color("4f95b1"), COLOR_CYAN, 4))
	water_bar.add_theme_stylebox_override("background", _box(Color("09131e"), COLOR_BORDER, 4))
	water_bar.add_theme_stylebox_override("fill", _box(Color("246fa0"), COLOR_CYAN, 4))
	_style_all_buttons(self)

func _style_button(button: Button) -> void:
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", COLOR_GOLD)
	button.add_theme_stylebox_override("normal", _box(COLOR_PANEL_RAISED, COLOR_BORDER, 6))
	button.add_theme_stylebox_override("hover", _box(Color("1b3a4e"), COLOR_CYAN, 6))
	button.add_theme_stylebox_override("pressed", _box(Color("0b1823"), COLOR_GOLD, 6))

func _style_all_buttons(node: Node) -> void:
	if node is Button:
		_style_button(node)
	for child in node.get_children():
		_style_all_buttons(child)

const ANCHOR_LABELS := {
	"bottom_right": "Inferior direito (padrão)",
	"bottom_left": "Inferior esquerdo",
	"top_right": "Superior direito",
	"top_left": "Superior esquerdo",
	"none": "Nenhuma (posição manual)",
}

func _ready() -> void:
	_apply_ui_theme()
	orbital_map.planet_selected.connect(_select_planet)
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
	idle_bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	idle_bar.gui_input.connect(_on_header_gui_input)
	header.mouse_default_cursor_shape = Control.CURSOR_MOVE
	header.gui_input.connect(_on_header_gui_input)
	_apply_compact_visuals()
	refresh()

## Arrasta a janela pelo cabeçalho / IdleBar — necessário porque a barra idle fica sem
## bordas/título do SO. Ao soltar, a âncora vira "manual" para não saltar de volta.
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

## Compacto: mostra só a IdleBar (layout nativo 480×104). Expandido: painel completo.
func _apply_compact_visuals() -> void:
	var compact := GameState.compact_mode
	idle_bar.visible = compact
	margin.visible = not compact
	%Compact.text = "Modo compacto"
	_sync_pause_buttons()

func _sync_pause_buttons() -> void:
	var label := "Retomar" if GameState.paused else "Pausar"
	%Pause.text = label
	%IdlePause.text = label

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
	var amounts: Dictionary = GameState.inventory.amounts
	_render_resource_cards(amounts, GameState.production_rates())
	_refresh_action_states()
	idle_resources.text = "Mat %d  ·  Ene %d  ·  Água %d  ·  Bio %d" % [
		amounts["Materia"], amounts["Energia"], amounts["Agua"], amounts["Biomassa"]
	]
	idle_status.text = _idle_status_text()
	idle_resources.text += "  |  MC %d" % GameState.mutter_coins
	asteroid_label.text = "Asteroides: %d / 2 necessarios" % GameState.asteroids
	tutorial_label.text = GameState.tutorial.current_text()
	tutorial_label.visible = not GameState.tutorial.dismissed
	var scale := 1.18 if GameState.settings.accessibility_large_text else 1.0
	content.scale = Vector2(scale, scale)
	modulate.a = GameState.settings.window_opacity
	_sync_pause_buttons()
	var orbit_signature := _current_orbit_view_signature()
	if orbit_signature == _orbit_view_signature:
		_refresh_orbit_action_states()
		_refresh_inspector()
		return
	_orbit_view_signature = orbit_signature
	for child in orbits_box.get_children(): child.queue_free()
	for orbit in GameState.ORBITS:
		var planet := GameState.planet_at_orbit(orbit)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var label := Label.new(); label.custom_minimum_size.x = 510
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_stylebox_override("normal", _box(Color("0d1a26"), COLOR_BORDER, 7))
		if planet == null:
			label.text = "Orbita %d — vazia" % (orbit + 1)
			var forge := Button.new()
			_register_orbit_action(forge, "Forjar planeta", {"Materia": 25.0, "Energia": 15.0}, "2 asteroides" if GameState.asteroids < 2 else "")
			_style_button(forge)
			forge.pressed.connect(func(): GameState.forge_planet(orbit))
			row.add_child(label); row.add_child(forge)
		else:
			label.text = "Orbita %d — %s %s | %s | atmosfera %d%% | agua %d%%" % [orbit + 1, planet.rarity, planet.type, planet.stage_name(), planet.atmosphere, planet.water]
			var select := Button.new(); select.text = "Ver"; _style_button(select)
			select.pressed.connect(func(): _select_planet(planet.id))
			var action := Button.new()
			if not planet.is_habitable():
				_register_orbit_action(action, "Terraformar", {"Agua": 12.0, "Energia": 20.0})
				action.pressed.connect(func(): GameState.terraform(planet))
			elif not planet.life:
				_register_orbit_action(action, "Iniciar vida", {"Agua": 10.0, "Energia": 15.0})
				action.pressed.connect(func(): GameState.start_life(planet))
			elif not planet.civilization:
				_register_orbit_action(action, "Evoluir civilizacao", {"Biomassa": 35.0, "Conhecimento": 20.0})
				action.pressed.connect(func(): GameState.advance_civilization(planet))
			else: _register_orbit_action(action, "Civilizacao ativa", {}, "marco concluido")
			_style_button(action)
			row.add_child(label); row.add_child(select); row.add_child(action)
		orbits_box.add_child(row)
	_refresh_inspector()
	orbital_map.set_system(GameState.planets, _selected_planet_id)

func _current_orbit_view_signature() -> String:
	var parts := [str(GameState.asteroids)]
	for orbit in GameState.ORBITS:
		var planet := GameState.planet_at_orbit(orbit)
		if planet == null:
			parts.append("empty")
		else:
			parts.append("%s:%s:%.0f:%.0f" % [planet.id, planet.stage_name(), planet.atmosphere, planet.water])
	return "|".join(parts)

func _register_orbit_action(button: Button, title: String, cost: Dictionary, requirement := "") -> void:
	button.set_meta("orbit_action", true)
	button.set_meta("orbit_title", title)
	button.set_meta("orbit_cost", cost)
	button.set_meta("orbit_requirement", requirement)
	_apply_action_state(button, title, cost, requirement)

func _refresh_orbit_action_states() -> void:
	for row in orbits_box.get_children():
		for child in row.get_children():
			if child is Button and child.has_meta("orbit_action"):
				var cost: Dictionary = child.get_meta("orbit_cost", {})
				_apply_action_state(child, str(child.get_meta("orbit_title")), cost, str(child.get_meta("orbit_requirement")))

func _select_planet(planet_id: String) -> void:
	_selected_planet_id = planet_id
	_refresh_inspector()
	orbital_map.set_system(GameState.planets, _selected_planet_id)

func _refresh_inspector() -> void:
	var selected: Planet = null
	for planet in GameState.planets:
		if planet.id == _selected_planet_id:
			selected = planet
			break
	if selected == null and not GameState.planets.is_empty():
		selected = GameState.planets[0]
		_selected_planet_id = selected.id
	inspector_panel.visible = selected != null
	if selected == null:
		return
	inspector_title.text = "ORBITA %d  ·  %s %s" % [selected.orbit + 1, selected.rarity.to_upper(), selected.type.to_upper()]
	inspector_details.text = "%s\nTemperatura: %.0f C  ·  Habitabilidade: %s\nAtmosfera: %.0f%%  ·  Agua: %.0f%%" % [selected.stage_name(), selected.temperature, "SIM" if selected.is_habitable() else "EM FORMACAO", selected.atmosphere, selected.water]
	atmosphere_bar.value = selected.atmosphere
	atmosphere_bar.tooltip_text = "Atmosfera: %.0f%%" % selected.atmosphere
	water_bar.value = selected.water
	water_bar.tooltip_text = "Agua: %.0f%%" % selected.water

func _render_resource_cards(amounts: Dictionary, rates: Dictionary) -> void:
	for child in resource_cards.get_children():
		resource_cards.remove_child(child)
		child.queue_free()
	var config := [
		["ENERGIA", "⚡", "Energia", COLOR_GOLD],
		["MATÉRIA", "◆", "Materia", Color("d7b787")],
		["ÁGUA", "◈", "Agua", COLOR_CYAN],
		["BIOMASSA", "✦", "Biomassa", Color("9ad469")],
		["CONHECIMENTO", "▤", "Conhecimento", Color("ca9bf4")],
	]
	for item in config:
		var accent: Color = item[3]
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(128, 74)
		card.add_theme_stylebox_override("panel", _box(Color("132535"), accent.darkened(0.35), 6))
		var card_content := VBoxContainer.new()
		card_content.add_theme_constant_override("separation", 2)
		var title := Label.new()
		title.text = "%s  %s" % [item[1], item[0]]
		title.add_theme_color_override("font_color", accent)
		title.add_theme_font_size_override("font_size", 11)
		var amount := Label.new()
		amount.text = _format_resource(int(amounts[item[2]]))
		amount.add_theme_color_override("font_color", COLOR_TEXT)
		amount.add_theme_font_size_override("font_size", 19)
		var rate := Label.new()
		var amount_value := float(amounts[item[2]])
		var capacity := float(GameState.inventory.capacities[item[2]])
		var rate_value := float(rates.get(item[2], 0.0))
		rate.text = "%s/s  ·  %s/%s cap." % [_format_rate(rate_value), _format_resource(int(amount_value)), _format_resource(int(capacity))]
		rate.add_theme_color_override("font_color", Color("8ba6b3"))
		rate.add_theme_font_size_override("font_size", 10)
		card_content.add_child(title)
		card_content.add_child(amount)
		card_content.add_child(rate)
		card.add_child(card_content)
		resource_cards.add_child(card)

func _format_resource(value: int) -> String:
	if value >= 1000:
		return "%.1fK" % (float(value) / 1000.0)
	return str(value)

func _format_rate(value: float) -> String:
	return "%+.2f" % value

func _refresh_action_states() -> void:
	_apply_action_state(create_asteroid_button, "Criar asteroide", {"Materia": 15.0})
	_apply_action_state(collect_water_button, "Capturar agua", {"Energia": 8.0})
	_apply_action_state(research_button, "Pesquisar", {"Energia": 12.0, "Biomassa": 8.0})
	_apply_action_state(prestige_button, "Supernova", {}, "3 orbitas preenchidas" if GameState.planets.size() < GameState.ORBITS else "")

func _apply_action_state(button: Button, title: String, cost: Dictionary, requirement := "") -> void:
	var missing: Dictionary = GameState.inventory.missing_resources(cost)
	var details: Array[String] = []
	for resource in cost:
		details.append("%s %d" % [resource, int(cost[resource])])
	button.text = title if details.is_empty() else "%s · %s" % [title, " / ".join(details)]
	if not requirement.is_empty():
		missing[requirement] = 0.0
	button.disabled = not missing.is_empty()
	var tooltip := "Custo: %s" % (" / ".join(details) if not details.is_empty() else "sem recursos")
	if missing.is_empty():
		button.tooltip_text = "%s\nPronto para executar." % tooltip
		return
	var missing_text: Array[String] = []
	for item in missing:
		missing_text.append(item if float(missing[item]) <= 0.0 else "%s +%d" % [item, ceili(float(missing[item]))])
	button.tooltip_text = "%s\nFalta: %s" % [tooltip, " / ".join(missing_text)]

func _idle_status_text() -> String:
	if GameState.paused:
		return "Pausado"
	var filled := GameState.planets.size()
	if filled <= 0:
		return "Forjando… %d ast." % GameState.asteroids
	var life := 0
	var civ := 0
	for planet in GameState.planets:
		if planet.life: life += 1
		if planet.civilization: civ += 1
	if civ > 0:
		return "%d órbitas · %d civ." % [filled, civ]
	if life > 0:
		return "%d órbitas · vida em %d" % [filled, life]
	return "%d / %d órbitas" % [filled, GameState.ORBITS]

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
	_sync_pause_buttons()
	GameState.state_changed.emit()
func _on_save_pressed() -> void: show_status("Partida salva." if GameState.save_game() else "Falha ao salvar.")
func _on_prestige_pressed() -> void:
	if GameState.planets.size() < GameState.ORBITS:
		show_status("Prestigio exige os tres planetas orbitais."); AudioService.play("error")
		return
	prestige_confirmation.dialog_text = "A supernova reinicia os planetas e asteroides deste sistema.\n\nRecompensa prevista: +%d Essencia permanente." % maxi(1, int(sqrt(GameState.planets.size() * 4.0)))
	prestige_confirmation.popup_centered()

func _on_prestige_confirmed() -> void:
	if not GameState.prestige():
		show_status("Nao foi possivel executar o prestigio."); AudioService.play("error")
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

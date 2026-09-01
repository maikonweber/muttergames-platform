class_name MakeupHud
extends Control

signal model_selected(model_id: String)
signal background_cycled
signal look_requested
signal clear_requested
signal undo_requested
signal redo_requested
signal complete_requested
signal extra_pack_confirmed

var session: MakeupSession
var tools: ToolController
var history: HistoryService
var canvas: MakeupCanvas

var _top: PanelContainer
var _bottom: PanelContainer
var _model_row: HBoxContainer
var _color_row: HBoxContainer
var _intensity: HSlider
var _size: HSlider
var _status: Label
var _objective_label: Label
var _coins_label: Label
var _before_btn: Button
var _undo_btn: Button
var _redo_btn: Button
var _complete_btn: Button
var _pack_btn: Button
var _tool_box: GridContainer
var _pack_sheet: Control
var _tools_toggle: Button
var _tray: VBoxContainer
var _tools_open := true

const HANDLE_H := 64.0
const DOCK_H := 252.0
const TRAY_H := 286.0
const LIPSTICK_ICON := "res://assets/ui/cosmetic_tools/tool_lipstick_card_v1.png"

const PINK := Color(0.95, 0.42, 0.62)
const CREAM := Color(1.0, 0.96, 0.93)
const INK := Color(0.42, 0.18, 0.30)
const GOLD := Color(0.92, 0.72, 0.32)
const PANEL := Color(1.0, 0.90, 0.93, 0.96)

const TOOL_LABELS := {
	"lipstick": "Batom",
	"eyeshadow": "Sombra",
	"foundation": "Base",
	"blush": "Blush",
	"eyeliner": "Lápis",
	"mascara": "Cílios",
	"accessory": "Enfeites",
	"eraser": "Apagar",
}

const TOOL_ICONS := {
	"lipstick": "res://assets/ui/cosmetic_tools/tool_lipstick_card_v1.png",
	"eyeshadow": "res://assets/ui/cosmetic_tools/tool_eyeshadow_palette_card_v1.png",
	"foundation": "res://assets/ui/cosmetic_tools/tool_sponge_card_v1.png",
	"blush": "res://assets/ui/cosmetic_tools/tool_brush_card_v1.png",
	"eyeliner": "res://assets/ui/cosmetic_tools/tool_eyeliner_card_v1.png",
	"mascara": "res://assets/ui/cosmetic_tools/tool_mascara_card_v1.png",
	"accessory": "res://assets/accessories/items/accessory_heart_tiara_v1.png",
	"eraser": "res://assets/ui/action_controls/action_erase_card_v1.png",
}

const HINTS := {
	"lipstick": "Escolha uma cor e pinte o rostinho",
	"eyeshadow": "Escolha uma cor e pinte onde quiser no olho",
	"foundation": "Toque no rostinho para a base",
	"blush": "Toque nas bochechas ou onde quiser corar",
	"eyeliner": "Pinte o traço do olho onde quiser",
	"mascara": "Escolha o estilo, a cor e o tamanho",
	"accessory": "Toque num enfeite para pôr ou tirar",
	"eraser": "Toque onde quiser apagar",
}


func setup(
		p_session: MakeupSession,
		p_tools: ToolController,
		p_history: HistoryService,
		p_canvas: MakeupCanvas
	) -> void:
	session = p_session
	tools = p_tools
	history = p_history
	canvas = p_canvas
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	_apply_safe_area()
	if tools:
		tools.changed.connect(_refresh)
	if session:
		session.accessories_changed.connect(_refresh)
	if history:
		history.changed.connect(_refresh_history)
	InventoryService.pack_changed.connect(func(_owned: bool) -> void:
		_fill_models()
		_refresh()
	)
	GameState.before_after_changed.connect(func(_a: bool) -> void: _refresh())
	GameState.play_mode_changed.connect(func(_mode: String) -> void: _refresh())
	InventoryService.coins_changed.connect(func(_total: int) -> void: _refresh_coins())
	resized.connect(_apply_safe_area)
	_refresh()
	set_tools_open(true)


func _build() -> void:
	_top = _panel(true)
	_bottom = _panel(false)
	var top_box := VBoxContainer.new()
	top_box.add_theme_constant_override("separation", 6)
	_top.add_child(top_box)
	var title := Label.new()
	title.text = "Lira Studio"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", INK)
	title.add_theme_font_size_override("font_size", 24)
	top_box.add_child(title)
	_coins_label = Label.new()
	_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coins_label.add_theme_color_override("font_color", Color(0.72, 0.48, 0.12))
	_coins_label.add_theme_font_size_override("font_size", 15)
	top_box.add_child(_coins_label)
	_objective_label = Label.new()
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective_label.add_theme_color_override("font_color", INK)
	_objective_label.add_theme_font_size_override("font_size", 14)
	top_box.add_child(_objective_label)
	_model_row = HBoxContainer.new()
	_model_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_model_row.add_theme_constant_override("separation", 10)
	top_box.add_child(_model_row)
	_fill_models()

	var bottom_box := VBoxContainer.new()
	bottom_box.add_theme_constant_override("separation", 8)
	_bottom.add_child(bottom_box)

	_tools_toggle = _paint_handle()
	_tools_toggle.pressed.connect(func() -> void: set_tools_open(not _tools_open))
	bottom_box.add_child(_tools_toggle)

	_tray = VBoxContainer.new()
	_tray.add_theme_constant_override("separation", 8)
	bottom_box.add_child(_tray)

	_color_row = HBoxContainer.new()
	_color_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_color_row.add_theme_constant_override("separation", 8)
	_tray.add_child(_color_row)

	_intensity = _slider_row(_tray, "Mais cor")
	_size = _slider_row(_tray, "Mais grosso")
	_intensity.min_value = 0.05
	_intensity.max_value = 1.0
	_intensity.step = 0.05
	_intensity.value_changed.connect(func(v: float) -> void: tools.set_intensity(v))
	_size.min_value = 8
	_size.max_value = 120
	_size.step = 1
	_size.value_changed.connect(func(v: float) -> void: tools.set_brush_radius(int(v)))

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	_tray.add_child(actions)
	_undo_btn = _icon_action(actions, "res://assets/ui/action_controls/action_undo_card_v1.png", "Desfazer", func() -> void: undo_requested.emit())
	_redo_btn = _icon_action(actions, "res://assets/ui/action_controls/action_redo_card_v1.png", "Refazer", func() -> void: redo_requested.emit())
	_before_btn = _icon_action(actions, "res://assets/ui/action_controls/action_compare_card_v1.png", "Antes e depois", func() -> void: GameState.toggle_before_after())
	actions.add_child(_pill_button("Limpar", func() -> void: clear_requested.emit()))
	actions.add_child(_pill_button("Surpresa", func() -> void: look_requested.emit()))
	actions.add_child(_pill_button("Fundo", func() -> void: background_cycled.emit()))
	_pack_btn = _pill_button("Pacote %s" % ExtraPack.PRICE_LABEL, _offer_extra_pack)
	actions.add_child(_pack_btn)
	_complete_btn = _icon_action(actions, "res://assets/ui/action_controls/action_confirm_card_v1.png", "Pronto!", func() -> void: complete_requested.emit())

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", INK)
	_status.add_theme_font_size_override("font_size", 16)
	_tray.add_child(_status)

	_tool_box = GridContainer.new()
	_tool_box.columns = 4
	_tool_box.add_theme_constant_override("h_separation", 10)
	_tool_box.add_theme_constant_override("v_separation", 10)
	bottom_box.add_child(_tool_box)
	_fill_tools()


func _panel(is_top: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE if is_top else Control.PRESET_BOTTOM_WIDE)
	if is_top:
		panel.offset_left = 0
		panel.offset_right = 0
		panel.offset_top = 0
	else:
		panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
		panel.anchor_top = 1.0
		panel.anchor_bottom = 1.0
		panel.offset_top = -(HANDLE_H + DOCK_H + TRAY_H)
		panel.offset_bottom = 0
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.set_content_margin_all(12)
	style.border_color = GOLD
	style.set_border_width_all(3)
	if is_top:
		style.corner_radius_bottom_left = 28
		style.corner_radius_bottom_right = 28
		style.border_width_top = 0
	else:
		style.corner_radius_top_left = 28
		style.corner_radius_top_right = 28
		style.border_width_bottom = 0
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	return panel


func set_tools_open(open: bool) -> void:
	_tools_open = open
	if _bottom:
		_bottom.visible = true
	if _tray:
		_tray.visible = open
	if _tools_toggle:
		_tools_toggle.text = "Ver o rostinho" if open else "Pintar!"
	_style_paint_handle(open)
	_apply_safe_area()


func _paint_handle() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, HANDLE_H)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.icon = load(LIPSTICK_ICON) as Texture2D
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 56)
	button.add_theme_constant_override("h_separation", 14)
	button.text = "Pintar!"
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = PINK
	style.set_corner_radius_all(22)
	style.set_border_width_all(4)
	style.border_color = GOLD
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	return button


func _style_paint_handle(open: bool) -> void:
	if _tools_toggle == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.86, 0.32, 0.54) if open else PINK
	style.set_corner_radius_all(22)
	style.set_border_width_all(4)
	style.border_color = GOLD
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	_tools_toggle.add_theme_stylebox_override("normal", style)
	_tools_toggle.add_theme_stylebox_override("hover", style)
	_tools_toggle.add_theme_stylebox_override("pressed", style)
	_tools_toggle.add_theme_color_override("font_color", Color.WHITE)


func _fill_models() -> void:
	for child in _model_row.get_children():
		child.queue_free()
	for model_id in ContentLibrary.model_ids():
		var model := ContentLibrary.get_model(model_id)
		var button := Button.new()
		button.custom_minimum_size = Vector2(68, 68)
		button.pressed.connect(_on_model_pressed.bind(model_id))
		_round_card(button, false)
		var thumb := TextureRect.new()
		thumb.set_anchors_preset(Control.PRESET_FULL_RECT)
		thumb.offset_left = 5
		thumb.offset_top = 5
		thumb.offset_right = -5
		thumb.offset_bottom = -5
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb.texture = model.thumb if model else null
		button.add_child(thumb)
		if model and not InventoryService.can_use_model(model):
			_lock_overlay(button)
		_model_row.add_child(button)


func _fill_tools() -> void:
	for child in _tool_box.get_children():
		child.queue_free()
	for tool_id in ToolController.TOOLS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 118)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void:
			tools.select_tool(tool_id)
			if not _tools_open:
				set_tools_open(true)
		)
		button.set_meta("tool_id", tool_id)
		button.tooltip_text = TOOL_LABELS.get(tool_id, tool_id)
		_round_card(button, false)
		var col := VBoxContainer.new()
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.set_anchors_preset(Control.PRESET_FULL_RECT)
		col.offset_left = 6
		col.offset_top = 6
		col.offset_right = -6
		col.offset_bottom = -6
		col.add_theme_constant_override("separation", 2)
		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = Vector2(0, 78)
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = load(String(TOOL_ICONS.get(tool_id, ""))) as Texture2D
		col.add_child(icon)
		var lab := Label.new()
		lab.text = TOOL_LABELS.get(tool_id, tool_id)
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.add_theme_color_override("font_color", INK)
		lab.add_theme_font_size_override("font_size", 18)
		col.add_child(lab)
		button.add_child(col)
		_tool_box.add_child(button)


func _fill_colors() -> void:
	for child in _color_row.get_children():
		child.queue_free()
	if tools == null:
		return
	if tools.erase or tools.category == "eraser":
		var hint := Label.new()
		hint.text = "Toque no que quiser apagar"
		hint.add_theme_color_override("font_color", INK)
		hint.add_theme_font_size_override("font_size", 16)
		_color_row.add_child(hint)
		return
	if tools.is_accessory_tool():
		var grid := GridContainer.new()
		grid.columns = 6
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		_color_row.add_child(grid)
		for item in ContentLibrary.get_accessories():
			var button := Button.new()
			button.custom_minimum_size = Vector2(64, 64)
			button.tooltip_text = item.display_name
			button.pressed.connect(func() -> void:
				if not InventoryService.can_use_accessory(item):
					_offer_extra_pack()
					return
				if history:
					history.push_snapshot(session.snapshot())
				session.toggle_accessory(item)
			)
			var equipped := String(session.equipped.get(item.anchor, "")) == item.id if session else false
			_round_card(button, equipped)
			if item.texture:
				var thumb := TextureRect.new()
				thumb.set_anchors_preset(Control.PRESET_FULL_RECT)
				thumb.offset_left = 6
				thumb.offset_top = 6
				thumb.offset_right = -6
				thumb.offset_bottom = -6
				thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
				thumb.texture = item.texture
				button.add_child(thumb)
			if not InventoryService.can_use_accessory(item):
				_lock_overlay(button)
			grid.add_child(button)
		return
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 8)
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_color_row.add_child(wrap)
	var style_grid := GridContainer.new()
	style_grid.columns = 8
	style_grid.add_theme_constant_override("h_separation", 6)
	style_grid.add_theme_constant_override("v_separation", 6)
	wrap.add_child(style_grid)
	for item in ContentLibrary.get_cosmetics(tools.paint_category()):
		style_grid.add_child(_cosmetic_button(item))
	var tints := ContentLibrary.tint_swatches(tools.paint_category())
	if tints.is_empty():
		return
	var tint_row := HBoxContainer.new()
	tint_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tint_row.add_theme_constant_override("separation", 6)
	wrap.add_child(tint_row)
	for swatch in tints:
		tint_row.add_child(_tint_button(swatch))


func _cosmetic_button(item: CosmeticData) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(56, 56)
	button.tooltip_text = item.display_name
	button.pressed.connect(func() -> void:
		if not InventoryService.can_use_cosmetic(item):
			_offer_extra_pack()
			return
		tools.select_cosmetic(item)
	)
	var selected := item.id == tools.cosmetic_id
	_round_card(button, selected)
	if item.thumbnail and item.category in ["mascara", "accessory"]:
		var thumb := TextureRect.new()
		thumb.set_anchors_preset(Control.PRESET_FULL_RECT)
		thumb.offset_left = 4
		thumb.offset_top = 4
		thumb.offset_right = -4
		thumb.offset_bottom = -4
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb.texture = item.thumbnail
		button.add_child(thumb)
	else:
		var style := StyleBoxFlat.new()
		style.bg_color = item.color
		style.set_corner_radius_all(28)
		style.set_border_width_all(3 if selected else 2)
		style.border_color = GOLD if selected else Color(1, 1, 1, 0.7)
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
	if not InventoryService.can_use_cosmetic(item):
		_lock_overlay(button)
	return button


func _tint_button(swatch: Dictionary) -> Button:
	var color: Color = swatch["color"]
	var button := Button.new()
	button.custom_minimum_size = Vector2(40, 40)
	button.tooltip_text = String(swatch.get("display_name", ""))
	button.pressed.connect(func() -> void:
		if not InventoryService.can_use_tint(swatch):
			_offer_extra_pack()
			return
		tools.select_tint(color)
	)
	var selected := tools.color_override.is_equal_approx(color)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(20)
	style.set_border_width_all(3 if selected else 2)
	style.border_color = GOLD if selected else Color(1, 1, 1, 0.75)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	if not InventoryService.can_use_tint(swatch):
		_lock_overlay(button)
	return button


func _sync_sliders() -> void:
	var show := tools != null and not tools.is_accessory_tool()
	if _intensity:
		_intensity.get_parent().visible = show
		_intensity.set_block_signals(true)
		_intensity.value = tools.intensity if tools else 0.55
		_intensity.set_block_signals(false)
	if _size:
		_size.get_parent().visible = show
		_size.set_block_signals(true)
		_size.value = float(tools.brush_radius) if tools else 14.0
		_size.set_block_signals(false)


func _slider_row(parent: Control, caption: String) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.text = caption
	label.custom_minimum_size = Vector2(110, 0)
	label.add_theme_color_override("font_color", INK)
	var slider := HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 40)
	row.add_child(label)
	row.add_child(slider)
	parent.add_child(row)
	return slider


func _icon_action(parent: Control, path: String, tip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(72, 72)
	button.tooltip_text = tip
	button.pressed.connect(callback)
	_round_card(button, false)
	var icon := TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 6
	icon.offset_top = 6
	icon.offset_right = -6
	icon.offset_bottom = -6
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = load(path) as Texture2D
	button.add_child(icon)
	parent.add_child(button)
	return button


func _pill_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(100, 56)
	button.pressed.connect(callback)
	_round_card(button, false)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_font_size_override("font_size", 16)
	return button


func _round_card(button: Button, active: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.78, 0.86) if active else Color(1.0, 0.97, 0.95)
	style.set_corner_radius_all(18)
	style.set_border_width_all(3 if active else 2)
	style.border_color = GOLD if active else Color(0.95, 0.72, 0.80)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", INK)


func _lock_overlay(button: Button) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.28, 0.10, 0.18, 0.48)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(dim)
	var tag := Label.new()
	tag.text = ExtraPack.PRICE_LABEL
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tag.set_anchors_preset(Control.PRESET_FULL_RECT)
	tag.add_theme_color_override("font_color", Color.WHITE)
	tag.add_theme_font_size_override("font_size", 11)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(tag)


func _offer_extra_pack() -> void:
	if InventoryService.owns_extra_pack():
		return
	if _pack_sheet and is_instance_valid(_pack_sheet):
		return
	_pack_sheet = ColorRect.new()
	_pack_sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pack_sheet.color = Color(0.25, 0.08, 0.16, 0.55)
	_pack_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_pack_sheet)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -280
	card.offset_right = 280
	card.offset_top = -220
	card.offset_bottom = 220
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.96, 0.95, 0.98)
	style.border_color = GOLD
	style.set_border_width_all(4)
	style.set_corner_radius_all(24)
	style.set_content_margin_all(20)
	card.add_theme_stylebox_override("panel", style)
	_pack_sheet.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	var title := Label.new()
	title.text = ExtraPack.TITLE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", INK)
	box.add_child(title)
	var body := Label.new()
	body.text = ExtraPack.BLURB
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 16)
	body.add_theme_color_override("font_color", INK)
	box.add_child(body)
	var price := Label.new()
	price.text = ExtraPack.PRICE_LABEL
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price.add_theme_font_size_override("font_size", 22)
	price.add_theme_color_override("font_color", Color(0.72, 0.48, 0.12))
	box.add_child(price)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	box.add_child(actions)
	actions.add_child(_pill_button("Agora não", _close_pack_sheet))
	actions.add_child(_pill_button("Continuar", func() -> void:
		_close_pack_sheet()
		extra_pack_confirmed.emit()
	))


func _close_pack_sheet() -> void:
	if _pack_sheet and is_instance_valid(_pack_sheet):
		_pack_sheet.queue_free()
	_pack_sheet = null


func _on_model_pressed(model_id: String) -> void:
	var model := ContentLibrary.get_model(model_id)
	if model and not InventoryService.can_use_model(model):
		_offer_extra_pack()
		return
	GameState.select_model(model_id)
	model_selected.emit(model_id)


func _refresh() -> void:
	if tools == null:
		return
	for child in _tool_box.get_children():
		if child is Button:
			var tool_id := String(child.get_meta("tool_id", ""))
			_round_card(child, tool_id == tools.category)
	_fill_colors()
	_sync_sliders()
	_round_card(_before_btn, GameState.before_after)
	var cosmetic := tools.current_cosmetic()
	var hint := String(HINTS.get(tools.category, "Toque no rostinho"))
	if cosmetic and not tools.is_accessory_tool() and tools.category != "eraser":
		_status.text = "%s · %s" % [hint, cosmetic.display_name]
	elif tools.is_accessory_tool():
		var worn: PackedStringArray = []
		if session:
			for slot in session.equipped.keys():
				var item := ContentLibrary.get_accessory(String(session.equipped[slot]))
				if item:
					worn.append(item.display_name)
		_status.text = hint if worn.is_empty() else "Enfeites · %s" % ", ".join(worn)
	else:
		_status.text = hint
	_refresh_history()
	_refresh_coins()
	_highlight_models()
	if _pack_btn:
		_pack_btn.visible = not InventoryService.owns_extra_pack()
	if _complete_btn:
		_complete_btn.visible = not GameState.is_free_play()


func set_challenge(challenge: ChallengeData) -> void:
	if _objective_label == null:
		return
	if GameState.is_free_play():
		_objective_label.text = "Modo brincar — pinte à vontade"
		if _complete_btn:
			_complete_btn.visible = false
		return
	if challenge == null:
		_objective_label.text = ""
		return
	_objective_label.text = "%s — pinte os lábios e as pálpebras" % challenge.display_name
	if _complete_btn:
		_complete_btn.visible = true


func _refresh_coins() -> void:
	if _coins_label:
		_coins_label.text = "Moedas: %d" % InventoryService.coins


func _refresh_history() -> void:
	if _undo_btn:
		_undo_btn.disabled = history == null or not history.can_undo()
	if _redo_btn:
		_redo_btn.disabled = history == null or not history.can_redo()


func _highlight_models() -> void:
	var ids := ContentLibrary.model_ids()
	var i := 0
	for child in _model_row.get_children():
		if i >= ids.size():
			break
		child.modulate = Color.WHITE if ids[i] == GameState.selected_model_id else Color(1, 1, 1, 0.62)
		i += 1


func _apply_safe_area() -> void:
	var margins := _safe_margins()
	if _top:
		_top.offset_left = margins.x
		_top.offset_right = -margins.z
		_top.offset_top = margins.y
	if _bottom:
		_bottom.offset_left = margins.x
		_bottom.offset_right = -margins.z
		_bottom.offset_bottom = -margins.w
		var tray := TRAY_H if _tools_open else 0.0
		_bottom.offset_top = -(HANDLE_H + DOCK_H + tray) - margins.w


func _safe_margins() -> Vector4:
	var view := get_viewport_rect().size
	var win := Vector2(DisplayServer.window_get_size())
	var pad := 10.0
	if win.x <= 1.0 or win.y <= 1.0:
		return Vector4(pad, pad, pad, pad)
	var safe := DisplayServer.get_display_safe_area()
	var sx := view.x / win.x
	var sy := view.y / win.y
	return Vector4(
		maxf(pad, safe.position.x * sx),
		maxf(pad, safe.position.y * sy),
		maxf(pad, (win.x - safe.end.x) * sx),
		maxf(pad, (win.y - safe.end.y) * sy)
	)

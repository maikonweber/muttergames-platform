class_name MakeupHud
extends Control

signal model_selected(model_id: String)
signal background_cycled
signal look_requested
signal clear_requested
signal undo_requested
signal redo_requested
signal complete_requested

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
var _tool_box: GridContainer

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
	"lipstick": "Escolha uma cor e toque nos lábios",
	"eyeshadow": "Escolha uma cor e toque nas pálpebras",
	"foundation": "Toque no rostinho para a base",
	"blush": "Toque nas bochechas",
	"eyeliner": "Toque perto do olho para o lápis",
	"mascara": "Escolha um estilo de cílios",
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
	GameState.before_after_changed.connect(func(_a: bool) -> void: _refresh())
	GameState.play_mode_changed.connect(func(_mode: String) -> void: _refresh())
	InventoryService.coins_changed.connect(func(_total: int) -> void: _refresh_coins())
	resized.connect(_apply_safe_area)
	_refresh()


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

	_tool_box = GridContainer.new()
	_tool_box.columns = 4
	_tool_box.add_theme_constant_override("h_separation", 8)
	_tool_box.add_theme_constant_override("v_separation", 8)
	bottom_box.add_child(_tool_box)
	_fill_tools()

	_color_row = HBoxContainer.new()
	_color_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_color_row.add_theme_constant_override("separation", 8)
	bottom_box.add_child(_color_row)

	_intensity = _slider_row(bottom_box, "Intensidade")
	_size = _slider_row(bottom_box, "Tamanho")
	_intensity.get_parent().visible = false
	_size.get_parent().visible = false
	_intensity.min_value = 0.05
	_intensity.max_value = 1.0
	_intensity.step = 0.05
	_intensity.value_changed.connect(func(v: float) -> void: tools.set_intensity(v))
	_size.min_value = 6
	_size.max_value = 80
	_size.step = 1
	_size.value_changed.connect(func(v: float) -> void: tools.set_brush_radius(int(v)))

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	bottom_box.add_child(actions)
	_undo_btn = _icon_action(actions, "res://assets/ui/action_controls/action_undo_card_v1.png", "Desfazer", func() -> void: undo_requested.emit())
	_redo_btn = _icon_action(actions, "res://assets/ui/action_controls/action_redo_card_v1.png", "Refazer", func() -> void: redo_requested.emit())
	_before_btn = _icon_action(actions, "res://assets/ui/action_controls/action_compare_card_v1.png", "Antes e depois", func() -> void: GameState.toggle_before_after())
	actions.add_child(_pill_button("Limpar", func() -> void: clear_requested.emit()))
	actions.add_child(_pill_button("Surpresa", func() -> void: look_requested.emit()))
	actions.add_child(_pill_button("Fundo", func() -> void: background_cycled.emit()))
	_complete_btn = _icon_action(actions, "res://assets/ui/action_controls/action_confirm_card_v1.png", "Pronto!", func() -> void: complete_requested.emit())

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", INK)
	_status.add_theme_font_size_override("font_size", 15)
	bottom_box.add_child(_status)


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
		panel.offset_top = -430
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
		_model_row.add_child(button)


func _fill_tools() -> void:
	for child in _tool_box.get_children():
		child.queue_free()
	for tool_id in ToolController.TOOLS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 108)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void: tools.select_tool(tool_id))
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
		icon.custom_minimum_size = Vector2(0, 70)
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = load(String(TOOL_ICONS.get(tool_id, ""))) as Texture2D
		col.add_child(icon)
		var lab := Label.new()
		lab.text = TOOL_LABELS.get(tool_id, tool_id)
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.add_theme_color_override("font_color", INK)
		lab.add_theme_font_size_override("font_size", 14)
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
			grid.add_child(button)
		return
	for item in ContentLibrary.get_cosmetics(tools.paint_category()):
		var button := Button.new()
		button.custom_minimum_size = Vector2(72, 72)
		button.tooltip_text = item.display_name
		button.pressed.connect(func() -> void: tools.select_cosmetic(item))
		var selected := item.id == tools.cosmetic_id
		_round_card(button, selected)
		if item.thumbnail:
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
			style.set_corner_radius_all(32)
			style.set_border_width_all(3 if selected else 2)
			style.border_color = GOLD if selected else Color(1, 1, 1, 0.7)
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_stylebox_override("hover", style)
			button.add_theme_stylebox_override("pressed", style)
		_color_row.add_child(button)


func _slider_row(parent: Control, caption: String) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.text = caption
	label.custom_minimum_size = Vector2(110, 0)
	label.add_theme_color_override("font_color", INK)
	var slider := HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 28)
	row.add_child(label)
	row.add_child(slider)
	parent.add_child(row)
	return slider


func _icon_action(parent: Control, path: String, tip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(64, 64)
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
	button.custom_minimum_size = Vector2(88, 48)
	button.pressed.connect(callback)
	_round_card(button, false)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_font_size_override("font_size", 14)
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


func _on_model_pressed(model_id: String) -> void:
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
		_bottom.offset_top = -440.0 - margins.w


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

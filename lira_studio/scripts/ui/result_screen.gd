class_name ResultScreen
extends Control

signal play_again
signal before_after_toggled

var _card: PanelContainer
var _title: Label
var _stars: Label
var _note: Label
var _objectives: VBoxContainer
var _coins: Label
var _before_btn: Button

const INK := Color(0.42, 0.18, 0.30)
const GOLD := Color(0.92, 0.72, 0.32)
const CREAM := Color(1.0, 0.96, 0.93)
const PANEL := Color(1.0, 0.92, 0.94, 0.97)


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()


func show_result(challenge: ChallengeData, result: Dictionary) -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	var name := challenge.display_name if challenge else "Festa"
	_title.text = "Olha que lindo!"
	var stars := int(result.get("stars", 0))
	_stars.text = _star_text(stars)
	var note := String(result.get("note", ""))
	_note.text = note if not note.is_empty() else "Você pintou o look da %s." % name.to_lower()
	_coins.text = "+%d moedas  ·  total %d" % [int(result.get("coins", 0)), InventoryService.coins]
	_fill_objectives(result.get("objectives", []))
	_before_btn.text = "Ver antes" if not GameState.before_after else "Ver depois"


func hide_result() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.set_before_after(false)


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.55, 0.22, 0.36, 0.28)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	_card = PanelContainer.new()
	_card.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_card.anchor_top = 0.48
	_card.offset_left = 16
	_card.offset_right = -16
	_card.offset_bottom = -16
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = GOLD
	style.set_border_width_all(4)
	style.set_corner_radius_all(28)
	style.set_content_margin_all(18)
	_card.add_theme_stylebox_override("panel", style)
	add_child(_card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	_card.add_child(box)

	_title = _label(26, INK, true)
	box.add_child(_title)
	_stars = _label(28, GOLD, true)
	box.add_child(_stars)
	_note = _label(15, INK, true)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_note)
	_objectives = VBoxContainer.new()
	_objectives.add_theme_constant_override("separation", 6)
	box.add_child(_objectives)
	_coins = _label(16, Color(0.72, 0.48, 0.12), true)
	box.add_child(_coins)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 12)
	box.add_child(actions)
	_before_btn = _picture_button(
		"res://assets/ui/action_controls/action_compare_card_v1.png",
		"Ver antes",
		func() -> void:
			GameState.toggle_before_after()
			_before_btn.text = "Ver depois" if GameState.before_after else "Ver antes"
			before_after_toggled.emit()
	)
	actions.add_child(_before_btn)
	actions.add_child(_picture_button(
		"res://assets/ui/action_controls/action_confirm_card_v1.png",
		"De novo!",
		func() -> void: play_again.emit()
	))


func _fill_objectives(rows: Array) -> void:
	for child in _objectives.get_children():
		child.queue_free()
	for row in rows:
		var line := Label.new()
		var met := bool(row.get("met", false))
		var mark := "★" if met else "☆"
		line.text = "%s  %s" % [mark, String(row.get("label", ""))]
		line.add_theme_color_override("font_color", Color(0.28, 0.55, 0.32) if met else INK)
		line.add_theme_font_size_override("font_size", 15)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_objectives.add_child(line)


func _star_text(stars: int) -> String:
	match clampi(stars, 0, 3):
		3:
			return "★★★  Mandou super bem!"
		2:
			return "★★☆  Quase lá — que lindo!"
		1:
			return "★☆☆  Bom começo!"
		_:
			return "Pinte os lábios e as pálpebras"


func _label(size_px: int, color: Color, center: bool) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size_px)
	label.add_theme_color_override("font_color", color)
	if center:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _picture_button(icon_path: String, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 56)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	var style := StyleBoxFlat.new()
	style.bg_color = CREAM
	style.border_color = Color(0.95, 0.72, 0.80)
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 12
	style.content_margin_right = 12
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_font_size_override("font_size", 16)
	button.icon = load(icon_path) as Texture2D
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 40)
	return button

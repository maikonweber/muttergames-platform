extends Control

@onready var background: TextureRect = $Background
@onready var canvas: MakeupCanvas = $MakeupCanvas
@onready var hud: MakeupHud = $HUD
@onready var result_screen: ResultScreen = $ResultScreen

var session: MakeupSession
var history: HistoryService
var tools: ToolController
var challenges: ChallengeService
var _brief: Control
var _last_lash_id: String = ""


func _ready() -> void:
	session = MakeupSession.new()
	history = HistoryService.new()
	tools = ToolController.new()
	challenges = ChallengeService.new()
	canvas.setup(session, tools, history)
	hud.setup(session, tools, history, canvas)
	hud.model_selected.connect(_on_model_selected)
	hud.background_cycled.connect(_on_background_cycled)
	hud.look_requested.connect(_on_look)
	hud.clear_requested.connect(_on_clear)
	hud.undo_requested.connect(_on_undo)
	hud.redo_requested.connect(_on_redo)
	hud.complete_requested.connect(_on_complete)
	hud.extra_pack_confirmed.connect(_on_extra_pack_confirmed)
	result_screen.play_again.connect(_on_play_again)
	tools.changed.connect(_on_tool_changed)
	StoreService.purchase_finished.connect(_on_purchase_finished)
	_load_model(GameState.selected_model_id)
	_apply_background()
	_show_brief()


func _unhandled_input(event: InputEvent) -> void:
	if result_screen.visible:
		return
	if event.is_action_pressed("undo_action"):
		_on_undo()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("redo_action"):
		_on_redo()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("before_after"):
		GameState.toggle_before_after()
		get_viewport().set_input_as_handled()


func _start_challenge() -> void:
	GameState.set_play_mode("challenge")
	var challenge := challenges.start("challenge_gala_01")
	GameState.select_model(challenge.model_id)
	GameState.background_index = challenge.background_index
	_apply_background()
	_load_model(challenge.model_id)
	hud.set_challenge(challenge)


func _start_free_play() -> void:
	GameState.set_play_mode("free")
	GameState.background_index = 0
	_apply_background()
	_load_model(GameState.selected_model_id)
	hud.set_challenge(null)


func _load_model(model_id: String) -> void:
	var model := ContentLibrary.get_model(model_id)
	if model and not InventoryService.can_use_model(model):
		model_id = "model_01"
		GameState.select_model(model_id)
		model = ContentLibrary.get_model(model_id)
	session.load_model(model)
	history.clear()
	GameState.set_before_after(false)


func _on_extra_pack_confirmed() -> void:
	StoreService.purchase_extra_pack()


func _on_purchase_finished(ok: bool, _sku: String, message: String) -> void:
	if ok:
		hud._refresh()
	if hud._status:
		hud._status.text = message


func _apply_background() -> void:
	background.texture = ContentLibrary.get_background(GameState.background_index)


func _on_model_selected(model_id: String) -> void:
	_load_model(model_id)


func _on_background_cycled() -> void:
	GameState.cycle_background()
	_apply_background()


func _on_look() -> void:
	history.push_snapshot(session.snapshot())
	session.apply_pilot_look()
	GameState.set_before_after(false)


func _on_clear() -> void:
	var category := tools.paint_category()
	if category.is_empty():
		return
	history.push_snapshot(session.snapshot())
	session.clear_layer(category)


func _on_undo() -> void:
	history.undo(session)


func _on_redo() -> void:
	history.redo(session)


func _on_tool_changed() -> void:
	if tools.is_sprite_tool():
		var lashes := tools.current_cosmetic()
		if lashes == null:
			return
		if not InventoryService.can_use_cosmetic(lashes):
			return
		if _last_lash_id != lashes.id:
			history.push_snapshot(session.snapshot())
			_last_lash_id = lashes.id
		session.apply_lashes(lashes, tools.brush_radius, tools.current_color(), tools.intensity)
		return
	_last_lash_id = ""
	if not tools.is_fill_tool():
		return
	var cosmetic := tools.current_cosmetic()
	if cosmetic == null:
		return
	history.push_snapshot(session.snapshot())
	session.apply_mask_fill(cosmetic.category, cosmetic.color, tools.intensity, cosmetic.dilate_px)


func _on_complete() -> void:
	if GameState.is_free_play():
		return
	var result := challenges.finish(session)
	InventoryService.record_challenge(String(result.get("challenge_id", "")), int(result.get("stars", 0)), int(result.get("coins", 0)))
	hud.visible = false
	canvas.set_celebration_expression(true)
	result_screen.show_result(challenges.challenge, result)


func _on_play_again() -> void:
	result_screen.hide_result()
	hud.visible = true
	canvas.set_celebration_expression(false)
	if GameState.is_free_play():
		_start_free_play()
	else:
		_start_challenge()


func _show_brief() -> void:
	if _brief:
		_brief.queue_free()
	_brief = ColorRect.new()
	_brief.set_anchors_preset(Control.PRESET_FULL_RECT)
	_brief.color = Color(0.55, 0.22, 0.36, 0.42)
	_brief.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_brief)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -310
	card.offset_right = 310
	card.offset_top = -300
	card.offset_bottom = 300
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.94, 0.95, 0.98)
	style.border_color = Color(0.92, 0.72, 0.32)
	style.set_border_width_all(4)
	style.set_corner_radius_all(28)
	style.set_content_margin_all(22)
	card.add_theme_stylebox_override("panel", style)
	_brief.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	card.add_child(box)
	var title := Label.new()
	title.text = "Vamos maquiar?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.42, 0.18, 0.30))
	box.add_child(title)
	var body := Label.new()
	body.text = "Toque num cartão. Na festa, pinte lábios e pálpebras. No brincar, pinte o que quiser."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 16)
	body.add_theme_color_override("font_color", Color(0.42, 0.18, 0.30))
	box.add_child(body)
	var choices := HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation", 18)
	box.add_child(choices)
	choices.add_child(_brief_mode_card(
		"res://assets/ui/challenge_emblems/challenge_gala_card_v1.png",
		"Festa",
		func() -> void:
			_close_brief()
			_start_challenge()
	))
	choices.add_child(_brief_mode_card(
		"res://assets/ui/challenge_emblems/challenge_daily_card_v1.png",
		"Brincar",
		func() -> void:
			_close_brief()
			_start_free_play()
	))


func _brief_mode_card(icon_path: String, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(220, 260)
	button.pressed.connect(callback)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.95)
	style.border_color = Color(0.95, 0.72, 0.80)
	style.set_border_width_all(3)
	style.set_corner_radius_all(22)
	style.set_content_margin_all(10)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 10
	col.offset_top = 10
	col.offset_right = -10
	col.offset_bottom = -10
	col.add_theme_constant_override("separation", 8)
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(icon_path) as Texture2D
	col.add_child(icon)
	var lab := Label.new()
	lab.text = caption
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.add_theme_color_override("font_color", Color(0.42, 0.18, 0.30))
	lab.add_theme_font_size_override("font_size", 22)
	col.add_child(lab)
	button.add_child(col)
	return button


func _close_brief() -> void:
	if _brief:
		_brief.queue_free()
		_brief = null

extends CanvasLayer

var _title: Control
var _pause: Control
var _win: Control
var _play: Control
var _score: Label
var _prompt: Label
var _toast: Label
var _dialog: Panel
var _dialog_name: Label
var _dialog_line: Label
var _toast_timer: float = 0.0


func _ready() -> void:
	layer = 10
	_build()
	GameState.started.connect(_on_started)
	GameState.paused_changed.connect(_on_paused)
	GameState.collected.connect(_on_collected)
	GameState.dialogue_shown.connect(_on_dialogue)
	GameState.dialogue_closed.connect(_on_dialogue_closed)
	GameState.won.connect(_on_won)
	GameState.nearby_prompt_changed.connect(_on_prompt)
	_refresh_score()


func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast.visible = false


func _build() -> void:
	var font_color := Color(0.96, 0.91, 0.78)
	_title = _full_overlay(Color(0.08, 0.1, 0.16, 0.72))
	_title.add_child(_title_card())
	add_child(_title)

	_play = Control.new()
	_play.set_anchors_preset(Control.PRESET_FULL_RECT)
	_play.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play.visible = false
	add_child(_play)

	_score = _label(Vector2(28, 22), "Praça Eternity", 22)
	_score.add_theme_color_override("font_color", font_color)
	_play.add_child(_score)

	_prompt = _label(Vector2(0, 640), "", 20)
	_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.offset_left = -320
	_prompt.offset_right = 320
	_prompt.offset_top = -78
	_prompt.offset_bottom = -44
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_color_override("font_color", Color(1, 0.92, 0.7))
	_play.add_child(_prompt)

	var hint := _label(Vector2(28, 672), "WASD anda  ·  mouse olha  ·  espaço pula  ·  E conversa  ·  Esc pausa", 14)
	hint.add_theme_color_override("font_color", Color(0.92, 0.86, 0.72, 0.8))
	_play.add_child(hint)

	_toast = _label(Vector2(0, 88), "", 26)
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.offset_left = -280
	_toast.offset_right = 280
	_toast.offset_top = 88
	_toast.offset_bottom = 128
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.visible = false
	_play.add_child(_toast)

	_dialog = Panel.new()
	_dialog.visible = false
	_dialog.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dialog.offset_left = -340
	_dialog.offset_right = 340
	_dialog.offset_top = -210
	_dialog.offset_bottom = -96
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.26, 0.92)
	style.border_color = Color(0.83, 0.64, 0.2)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	_dialog.add_theme_stylebox_override("panel", style)
	_dialog_name = _label(Vector2(16, 10), "", 18)
	_dialog_name.add_theme_color_override("font_color", Color(0.95, 0.78, 0.28))
	_dialog.add_child(_dialog_name)
	_dialog_line = _label(Vector2(16, 40), "", 20)
	_dialog_line.offset_right = 640
	_dialog_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialog.add_child(_dialog_line)
	_play.add_child(_dialog)

	_pause = _full_overlay(Color(0.04, 0.05, 0.08, 0.55))
	_pause.visible = false
	var pause_title := _label(Vector2(0, 0), "pausou um pouquinho", 36)
	pause_title.set_anchors_preset(Control.PRESET_CENTER)
	pause_title.offset_left = -280
	pause_title.offset_right = 280
	pause_title.offset_top = -30
	pause_title.offset_bottom = 20
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause.add_child(pause_title)
	var pause_hint := _label(Vector2(0, 0), "Esc continua", 18)
	pause_hint.set_anchors_preset(Control.PRESET_CENTER)
	pause_hint.offset_left = -160
	pause_hint.offset_right = 160
	pause_hint.offset_top = 24
	pause_hint.offset_bottom = 52
	pause_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause.add_child(pause_hint)
	add_child(_pause)

	_win = _full_overlay(Color(0.12, 0.08, 0.04, 0.62))
	_win.visible = false
	var win_title := _label(Vector2(0, 0), "Paulinho juntou a galera!", 40)
	win_title.set_anchors_preset(Control.PRESET_CENTER)
	win_title.offset_left = -420
	win_title.offset_right = 420
	win_title.offset_top = -40
	win_title.offset_bottom = 16
	win_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	_win.add_child(win_title)
	var win_sub := _label(Vector2(0, 0), "Limão, gelo, tampinha e um brinde na Praça Eternity.", 20)
	win_sub.set_anchors_preset(Control.PRESET_CENTER)
	win_sub.offset_left = -420
	win_sub.offset_right = 420
	win_sub.offset_top = 20
	win_sub.offset_bottom = 56
	win_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_win.add_child(win_sub)
	add_child(_win)


func _title_card() -> Control:
	var box := Panel.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -320
	box.offset_right = 320
	box.offset_top = -170
	box.offset_bottom = 170
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.28, 0.94)
	style.border_color = Color(0.83, 0.64, 0.2)
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	box.add_theme_stylebox_override("panel", style)

	var stripe := ColorRect.new()
	stripe.color = Color(0.72, 0.18, 0.18)
	stripe.position = Vector2(0, 0)
	stripe.size = Vector2(640, 14)
	box.add_child(stripe)

	var title := _label(Vector2(20, 36), "PAULINHO", 52)
	title.size = Vector2(600, 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.98, 0.93, 0.78))
	box.add_child(title)

	var sub := _label(Vector2(20, 100), "seu amiguinho", 30)
	sub.size = Vector2(600, 40)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.95, 0.72, 0.32))
	box.add_child(sub)

	var blurb := _label(Vector2(40, 156), "A garrafa mais gente boa da Praça Eternity.\nJunta limões, gelo e tampinhas e fala com a galera.", 18)
	blurb.size = Vector2(560, 70)
	blurb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(blurb)

	var go := _label(Vector2(20, 250), "Enter — começar o passeio", 20)
	go.size = Vector2(600, 32)
	go.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go.add_theme_color_override("font_color", Color(0.9, 0.84, 0.66))
	box.add_child(go)
	return box


func _full_overlay(color: Color) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = color
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	return root


func _label(pos: Vector2, text: String, size_px: int) -> Label:
	var lab := Label.new()
	lab.position = pos
	lab.text = text
	lab.add_theme_font_size_override("font_size", size_px)
	lab.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	lab.add_theme_color_override("font_outline_color", Color(0.08, 0.07, 0.06, 0.8))
	lab.add_theme_constant_override("outline_size", 6)
	return lab


func _refresh_score() -> void:
	_score.text = "Limões %d/%d   Gelo %d/%d   Tampinhas %d/%d" % [
		GameState.counts["limao"], GameState.totals["limao"],
		GameState.counts["gelo"], GameState.totals["gelo"],
		GameState.counts["tampinha"], GameState.totals["tampinha"]
	]


func _on_started() -> void:
	_title.visible = false
	_play.visible = true
	_refresh_score()


func _on_paused(is_paused: bool) -> void:
	_pause.visible = is_paused


func _on_collected(kind: String, _count: int, _total: int) -> void:
	_refresh_score()
	_toast.text = "Paulinho achou %s!" % GameState.kind_label(kind)
	_toast.visible = true
	_toast_timer = 1.6


func _on_dialogue(speaker: String, line: String) -> void:
	_dialog.visible = true
	_dialog_name.text = speaker
	_dialog_line.text = line


func _on_dialogue_closed() -> void:
	_dialog.visible = false


func _on_won() -> void:
	_win.visible = true
	_dialog.visible = false
	_prompt.text = ""


func _on_prompt(text: String) -> void:
	_prompt.text = text

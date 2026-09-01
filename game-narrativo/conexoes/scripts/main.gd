extends Control

const EPISODE_PATH := "res://data/episodes/ep01/nodes.json"
const BACKGROUNDS := {
	"loc_terminal": "res://assets/backgrounds/bg_terminal_dusk.png",
	"loc_patio": "res://assets/backgrounds/bg_patio_day.png",
	"loc_secretaria": "res://assets/backgrounds/bg_secretaria_day.png",
	"loc_dorm_bia": "res://assets/backgrounds/bg_dorm_bia.png",
	"loc_festa": "res://assets/backgrounds/bg_festa_night.png",
	"loc_corredor_old": "res://assets/backgrounds/bg_corredor_old.png",
	"loc_quarto": "res://assets/backgrounds/bg_quarto_night.png",
}
const DISPLAY_NAMES := {
	"narrator": "",
	"theo": "Theo",
	"bia": "Bia",
	"helena": "Helena Vidal",
	"caio": "Caio",
	"gael": "Gael",
	"noah": "Noah",
	"luna": "Luna",
}
const FESTA_CAST := ["theo", "gael", "noah", "luna"]
const ALLY_CAST := ["theo", "gael", "noah", "luna", "bia"]

var nodes := {}
var start_node := "EP01_SC01_N001"
var current_node: Dictionary = {}
var flags := {}
var affinity := {}
var trust := {}
var courage := 0
var player_name := "Lia"
var last_location := ""
var background: TextureRect
var portrait: TextureRect
var dimmer: ColorRect
var dialogue: PanelContainer
var speaker_label: Label
var text_label: RichTextLabel
var choices_box: VBoxContainer
var next_button: Button
var cg_layer: Control

func _ready() -> void:
	build_view()
	load_episode()
	show_node(start_node)

func build_view() -> void:
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	dimmer = ColorRect.new()
	dimmer.color = Color(0.025, 0.015, 0.08, 0.22)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dimmer)

	# Janela de busto à direita, acima da caixa. Os sprites são corpo inteiro;
	# o recorte fica em apply_portrait_texture().
	portrait = TextureRect.new()
	portrait.anchor_left = 1.0
	portrait.anchor_top = 0.0
	portrait.anchor_right = 1.0
	portrait.anchor_bottom = 1.0
	portrait.offset_left = -470
	portrait.offset_top = 8
	portrait.offset_right = -6
	portrait.offset_bottom = -230
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.z_index = 1
	add_child(portrait)

	dialogue = PanelContainer.new()
	dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialogue.offset_left = 38
	dialogue.offset_top = -252
	dialogue.offset_right = -38
	dialogue.offset_bottom = -28
	dialogue.z_index = 2
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("161127e8")
	panel_style.border_color = Color("b067cf")
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 14
	panel_style.corner_radius_top_right = 14
	panel_style.corner_radius_bottom_left = 14
	panel_style.corner_radius_bottom_right = 14
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 16
	panel_style.content_margin_bottom = 14
	dialogue.add_theme_stylebox_override("panel", panel_style)
	add_child(dialogue)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	dialogue.add_child(content)
	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 22)
	speaker_label.add_theme_color_override("font_color", Color("f0b8ff"))
	content.add_child(speaker_label)
	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.fit_content = true
	text_label.custom_minimum_size = Vector2(0, 96)
	text_label.scroll_active = false
	text_label.add_theme_font_size_override("normal_font_size", 21)
	text_label.add_theme_color_override("default_color", Color("f7f2ff"))
	content.add_child(text_label)
	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 6)
	content.add_child(choices_box)
	next_button = Button.new()
	next_button.text = "Continuar"
	next_button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	next_button.pressed.connect(advance)
	content.add_child(next_button)

	cg_layer = Control.new()
	cg_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cg_layer.visible = false
	cg_layer.z_index = 10
	add_child(cg_layer)

func load_episode() -> void:
	var file := FileAccess.open(EPISODE_PATH, FileAccess.READ)
	if file == null:
		push_error("Não foi possível abrir %s" % EPISODE_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("nodes.json inválido")
		return
	for node in parsed.get("nodes", []):
		nodes[node.id] = node
	var declared: String = parsed.get("start", "")
	if nodes.has(declared):
		start_node = declared

func show_node(node_id: String) -> void:
	if not nodes.has(node_id):
		show_end()
		return
	current_node = nodes[node_id]
	var guard := 0
	while not conditions_met(current_node.get("conditions", [])):
		guard += 1
		var skipped_next = current_node.get("skip", current_node.get("next", ""))
		if skipped_next == null or skipped_next == "" or not nodes.has(skipped_next) or guard > 24:
			show_end()
			return
		current_node = nodes[skipped_next]
	apply_effects(current_node.get("effects", []))
	var location: String = current_node.get("location", "")
	var speaker := resolve_speaker(current_node.get("speaker", "narrator"))
	set_background(location)
	set_portrait(speaker, current_node.get("expression", "idle"), location, current_node.get("tags", []))
	speaker_label.text = DISPLAY_NAMES.get(speaker, "")
	text_label.text = current_node.get("text", "").replace("{name}", player_name)
	clear_choices()
	var choices: Array = current_node.get("choices", [])
	if choices.is_empty():
		next_button.visible = current_node.get("next") != null
	else:
		next_button.visible = false
		for choice in choices:
			if conditions_met(choice.get("conditions", [])):
				add_choice(choice)

func set_background(location: String) -> void:
	var path: String = BACKGROUNDS.get(location, "")
	background.texture = load(path) if path != "" else null

func set_portrait(speaker: String, expression: String, location: String, tags: Array) -> void:
	var scene_changed := location != "" and location != last_location
	if location != "":
		last_location = location
	var force_clear := tags.has("clear_portrait") or scene_changed and (speaker == "narrator" or speaker == "")
	if speaker == "narrator" or speaker == "":
		if force_clear:
			portrait.texture = null
			portrait.modulate = Color.WHITE
		else:
			portrait.modulate = Color(0.58, 0.54, 0.68, 1.0)
		return
	portrait.modulate = Color.WHITE
	var path := "res://assets/portraits/%s/%s_%s.png" % [speaker, speaker, expression]
	if not ResourceLoader.exists(path):
		path = "res://assets/portraits/%s/%s_idle.png" % [speaker, speaker]
	if ResourceLoader.exists(path):
		apply_portrait_texture(load(path))
	else:
		portrait.texture = null
		push_warning("Retrato ausente para %s (%s)" % [speaker, expression])

func apply_portrait_texture(tex: Texture2D) -> void:
	if tex == null:
		portrait.texture = null
		return
	var size := tex.get_size()
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(0, 0, size.x, size.y * 0.58)
	atlas.filter_clip = true
	portrait.texture = atlas

func resolve_speaker(speaker: String) -> String:
	if speaker == "festa":
		return flagged_member(FESTA_CAST, "ep01_festa_")
	if speaker == "ally":
		return flagged_member(ALLY_CAST, "ep01_ally_")
	return speaker

func resolve_who(who: String) -> String:
	if who == "festa" or who == "ally":
		return resolve_speaker(who)
	return who

func flagged_member(cast: Array, prefix: String) -> String:
	for who in cast:
		if flags.get("%s%s" % [prefix, who], false):
			return who
	return "narrator"

func add_choice(choice: Dictionary) -> void:
	var button := Button.new()
	button.text = choice.get("text", "Escolher")
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size = Vector2(0, 35)
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(func() -> void: choose(choice))
	choices_box.add_child(button)

func clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()

func choose(choice: Dictionary) -> void:
	apply_effects(choice.get("effects", []))
	show_node(choice.get("next", ""))

func advance() -> void:
	show_node(current_node.get("next", ""))

func conditions_met(conditions: Array) -> bool:
	for condition in conditions:
		if condition.get("type", "") == "flag" and flags.get(condition.get("flag", ""), false) != condition.get("value", true):
			return false
	return true

func apply_effects(effects: Array) -> void:
	for effect in effects:
		match effect.get("type", ""):
			"flag":
				flags[effect.get("flag", "")] = effect.get("value", true)
			"cg":
				show_cg(effect.get("id", ""))
			"wardrobe_tag":
				var tag: String = str(effect.get("tag", ""))
				if tag != "":
					flags["ep01_wardrobe_%s" % tag] = true
			"affinity":
				var who := resolve_who(str(effect.get("who", "")))
				affinity[who] = int(affinity.get(who, 0)) + int(effect.get("delta", 0))
			"trust":
				var who := resolve_who(str(effect.get("who", "")))
				trust[who] = int(trust.get(who, 0)) + int(effect.get("delta", 0))
			"courage":
				courage += int(effect.get("delta", 0))
			"evidence":
				flags[str(effect.get("id", ""))] = true
			"profile":
				var stat: String = str(effect.get("stat", ""))
				if stat != "":
					flags["profile_%s" % stat] = int(flags.get("profile_%s" % stat, 0)) + int(effect.get("delta", 0))

func show_cg(cg_id: String) -> void:
	var path := "res://assets/cg/%s.png" % cg_id
	if cg_id == "cg_ep01_festa_rota":
		for who in FESTA_CAST:
			if flags.get("ep01_festa_%s" % who, false):
				path = "res://assets/cg/cg_ep01_festa_rota_%s.png" % who
				break
	if not ResourceLoader.exists(path):
		return
	cg_layer.visible = true
	for child in cg_layer.get_children():
		child.queue_free()
	var image := TextureRect.new()
	image.texture = load(path)
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg_layer.add_child(image)
	var close := Button.new()
	close.text = "Continuar"
	close.anchor_left = 1.0
	close.anchor_top = 1.0
	close.anchor_right = 1.0
	close.anchor_bottom = 1.0
	close.offset_left = -170
	close.offset_top = -75
	close.offset_right = -40
	close.offset_bottom = -33
	close.pressed.connect(func() -> void: cg_layer.visible = false)
	cg_layer.add_child(close)

func show_end() -> void:
	portrait.texture = null
	speaker_label.text = "Episódio concluído"
	text_label.text = "Fim de O fio vermelho. As escolhas foram registradas nesta sessão."
	clear_choices()
	next_button.visible = false

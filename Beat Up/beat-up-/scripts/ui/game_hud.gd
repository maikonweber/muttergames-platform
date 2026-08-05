extends CanvasLayer
## HUD leve — placa de rádio (canto esquerdo) + ícone wanted (canto direito).
##
## Wanted ainda é só visual (sem lógica de heat — ver README Fase 1.1).
## Escuta sinais do `RadioManager` para atualizar o label.
## Instanciado em código por `main.gd` (ainda sem cena própria).

const AssetArt = preload("res://scripts/world/asset_art.gd")

var _radio_plate: TextureRect
var _radio_label: Label
var _wanted: TextureRect


func _ready() -> void:
	layer = 50
	_build()
	if RadioManager != null:
		RadioManager.station_changed.connect(_on_station)
		RadioManager.radio_toggled.connect(_on_radio_toggled)
		_refresh_radio()


## Monta controles por código (sem .tscn) para manter o HUD desacoplado.
func _build() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_radio_plate = TextureRect.new()
	_radio_plate.texture = AssetArt.make_texture(AssetArt.UI_RADIO, 280.0, 72.0)
	_radio_plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_radio_plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_radio_plate.custom_minimum_size = Vector2(240, 56)
	_radio_plate.position = Vector2(16, 16)
	_radio_plate.modulate = Color(1, 1, 1, 0.92)
	root.add_child(_radio_plate)

	_radio_label = Label.new()
	_radio_label.position = Vector2(28, 28)
	_radio_label.add_theme_font_size_override("font_size", 14)
	_radio_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.9))
	_radio_label.text = "Radio"
	root.add_child(_radio_label)

	# Placeholder visual — liga a um sistema de heat na Fase 1.
	_wanted = TextureRect.new()
	_wanted.texture = AssetArt.make_texture(AssetArt.UI_WANTED, 72.0, 72.0)
	_wanted.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wanted.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_wanted.custom_minimum_size = Vector2(64, 64)
	_wanted.anchor_left = 1.0
	_wanted.anchor_right = 1.0
	_wanted.offset_left = -80.0
	_wanted.offset_right = -16.0
	_wanted.offset_top = 16.0
	_wanted.offset_bottom = 80.0
	_wanted.modulate = Color(1, 1, 1, 0.85)
	root.add_child(_wanted)


func _on_station(_station: RadioStation) -> void:
	_refresh_radio()


func _on_radio_toggled(is_on: bool) -> void:
	_radio_plate.modulate.a = 0.95 if is_on else 0.45
	_refresh_radio()


func _refresh_radio() -> void:
	if RadioManager == null:
		return
	_radio_label.text = RadioManager.get_station_label()

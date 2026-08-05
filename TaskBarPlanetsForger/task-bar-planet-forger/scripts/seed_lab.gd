extends Control

@onready var preview: TextureRect = %Preview
@onready var seed_input: SpinBox = %SeedInput
@onready var type_picker: OptionButton = %TypePicker
@onready var atmosphere: HSlider = %Atmosphere
@onready var water: HSlider = %Water
@onready var life: CheckButton = %Life
@onready var civilization: CheckButton = %Civilization
@onready var stage_label: Label = %Stage
@onready var status: Label = %Status

var _planet := Planet.new()
var _random := RandomNumberGenerator.new()

func _ready() -> void:
	for planet_type in ["Rochoso", "Oceanico", "Vulcanico", "Desertico", "Congelado", "Gasoso", "Vivo", "Maquina"]:
		type_picker.add_item(planet_type)
	_random.randomize()
	_new_seed()

func _new_seed() -> void:
	_planet.visual_seed = _random.randi()
	seed_input.value = _planet.visual_seed
	_refresh_preview()

func _refresh_preview() -> void:
	_planet.visual_seed = int(seed_input.value)
	_planet.type = type_picker.get_item_text(type_picker.selected)
	_planet.atmosphere = atmosphere.value
	_planet.water = water.value
	_planet.life = life.button_pressed
	_planet.civilization = civilization.button_pressed
	preview.texture = ProceduralPlanetGenerator.render_planet(_planet, 256)
	stage_label.text = "Estágio: %s · Seed: %d" % [_planet.stage_name(), _planet.visual_seed]

func _on_randomize_pressed() -> void:
	_new_seed()

func _on_update_pressed() -> void:
	_refresh_preview()

func _on_evolve_pressed() -> void:
	_refresh_preview()
	if _planet.atmosphere < 50.0 or _planet.water < 40.0:
		atmosphere.value = maxf(atmosphere.value, 50.0)
		water.value = maxf(water.value, 40.0)
		status.text = "Evolução: planeta tornou-se habitável."
	elif not _planet.life:
		life.button_pressed = true
		status.text = "Evolução: vida inicial desbloqueada."
	elif not _planet.civilization:
		civilization.button_pressed = true
		status.text = "Evolução: civilização ativa."
	else:
		status.text = "Este planeta já atingiu o estágio máximo."
	_refresh_preview()

func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(str(_planet.visual_seed))
	status.text = "Seed copiada para a área de transferência."

func _on_export_pressed() -> void:
	_refresh_preview()
	var folder := "user://generated_planets"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var path := "%s/planet_%s_%d.png" % [folder, _planet.type.to_lower(), _planet.visual_seed]
	var result := ProceduralPlanetGenerator.render_image(_planet, 512).save_png(path)
	status.text = "Exportado: %s" % ProjectSettings.globalize_path(path) if result == OK else "Falha ao exportar o PNG."

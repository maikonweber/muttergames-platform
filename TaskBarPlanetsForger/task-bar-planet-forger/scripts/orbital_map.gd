class_name OrbitalMap
extends Control

signal planet_selected(planet_id: String)

const ORBIT_COLORS := [Color("245269"), Color("2b6a80"), Color("377f91")]
const PLANET_SIZE := 62.0

var _planets: Array[Planet] = []
var _selected_planet_id := ""
var _positions: Dictionary = {}
var _textures: Dictionary = {}
var _texture_keys: Dictionary = {}

func set_system(planets: Array[Planet], selected_planet_id: String) -> void:
	_planets = planets
	_selected_planet_id = selected_planet_id
	_positions.clear()
	for planet in _planets:
		var key := "%d:%s:%.0f:%.0f:%s:%s" % [planet.visual_seed, planet.type, planet.atmosphere, planet.water, planet.life, planet.civilization]
		if _texture_keys.get(planet.id, "") != key:
			_textures[planet.id] = ProceduralPlanetGenerator.render_planet(planet, 96)
			_texture_keys[planet.id] = key
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var base_radius := minf(size.x, size.y) * 0.13
	for orbit in range(GameState.ORBITS):
		var radius := base_radius + orbit * minf(size.x, size.y) * 0.105
		draw_arc(center, radius, 0.0, TAU, 72, ORBIT_COLORS[orbit], 1.5, true)
	draw_circle(center, base_radius * 0.42, Color("f6be46"))
	draw_circle(center - Vector2(base_radius * 0.11, base_radius * 0.11), base_radius * 0.12, Color("fff0a6"))
	for planet in _planets:
		var orbit_radius := base_radius + planet.orbit * minf(size.x, size.y) * 0.105
		var angle := fmod(float(abs(planet.visual_seed) % 360) * DEG_TO_RAD + planet.orbit * 0.7, TAU)
		var position := center + Vector2(cos(angle), sin(angle)) * orbit_radius
		_positions[planet.id] = position
		var texture: Texture2D = _textures.get(planet.id)
		if texture != null:
			var rect := Rect2(position - Vector2.ONE * (PLANET_SIZE * 0.5), Vector2.ONE * PLANET_SIZE)
			draw_texture_rect(texture, rect, false)
		if planet.id == _selected_planet_id:
			draw_arc(position, PLANET_SIZE * 0.62, 0.0, TAU, 36, Color("57d9e8"), 2.5, true)
			draw_circle(position + Vector2(0, PLANET_SIZE * 0.62), 3.0, Color("57d9e8"))

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	for planet in _planets:
		var position: Vector2 = _positions.get(planet.id, Vector2(-9999, -9999))
		if event.position.distance_to(position) <= PLANET_SIZE * 0.65:
			planet_selected.emit(planet.id)
			accept_event()
			return

class_name ProceduralPlanetGenerator
extends RefCounted

## Rasterizador determinístico: a mesma seed, os mesmos dados e a mesma versão
## sempre formam o mesmo sprite. Todas as etapas de evolução vêm dos dados do planeta.
static func render_planet(planet: Planet, size := 256) -> ImageTexture:
	return ImageTexture.create_from_image(render_image(planet, size))

static func render_image(planet: Planet, size := 256) -> Image:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var noise := FastNoiseLite.new()
	noise.seed = planet.visual_seed
	noise.frequency = 0.035
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	var base := _base_color(planet.type)
	var water_color := Color("2496D4")
	var life_color := Color("59C77A")
	var glow := _glow_color(planet.type)
	var water_amount := clampf(planet.water / 100.0, 0.0, 1.0)
	var atmosphere_amount := clampf(planet.atmosphere / 100.0, 0.0, 1.0)
	var center := (size - 1) * 0.5
	var radius := size * 0.39
	for y in range(size):
		for x in range(size):
			var px := (x - center) / radius
			var py := (y - center) / radius
			var distance_to_center := sqrt(px * px + py * py)
			if distance_to_center > 1.0:
				continue
			var sphere_light := clampf(0.24 + (1.0 - distance_to_center) * 0.62 + (-px - py) * 0.13, 0.08, 1.0)
			var terrain := noise.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			var color := base.lerp(base.darkened(0.34), 1.0 - terrain)
			if _can_have_water(planet.type) and terrain < water_amount * 0.68:
				color = water_color.lerp(Color("0B477B"), terrain * 0.55)
			if planet.life and terrain > 0.54 and terrain < 0.82:
				color = color.lerp(life_color, 0.48)
			if planet.civilization and terrain > 0.66 and int(x * 11 + y * 7 + planet.visual_seed) % 31 == 0:
				color = Color("FFE28A")
			if planet.type == "Vulcanico" and terrain > 0.73:
				color = Color("FF7548")
			var terminator := smoothstep(-0.7, 0.85, -px - py * 0.35)
			color = color.darkened((1.0 - terminator) * 0.56).lerp(glow, maxf(0.0, terrain - 0.82) * 0.11)
			image.set_pixel(x, y, color * sphere_light)
	# Halo atmosférico separado para não depender da cor da superfície.
	if atmosphere_amount > 0.0:
		for y in range(size):
			for x in range(size):
				var px := (x - center) / radius
				var py := (y - center) / radius
				var distance_to_center := sqrt(px * px + py * py)
				if distance_to_center >= 0.985 and distance_to_center <= 1.035:
					var alpha := (1.035 - distance_to_center) / 0.05 * atmosphere_amount * 0.55
					image.set_pixel(x, y, Color(glow, alpha))
	return image

static func _can_have_water(planet_type: String) -> bool:
	return planet_type in ["Rochoso", "Oceanico", "Vivo"]

static func _base_color(planet_type: String) -> Color:
	match planet_type:
		"Oceanico": return Color("2EAFD7")
		"Vulcanico": return Color("563445")
		"Desertico": return Color("D49958")
		"Congelado": return Color("91D6E8")
		"Gasoso": return Color("A17BDF")
		"Vivo": return Color("4EAD77")
		"Maquina": return Color("5E7190")
		_: return Color("9B7864")

static func _glow_color(planet_type: String) -> Color:
	match planet_type:
		"Vulcanico": return Color("FFB15A")
		"Congelado": return Color("C8F7FF")
		"Maquina": return Color("73E5FF")
		_: return Color("77DFFF")

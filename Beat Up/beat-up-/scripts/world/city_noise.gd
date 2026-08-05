extends RefCounted
class_name CityNoise
## Campos Perlin que dão “orgânica” à cidade (distritos, plazas, árvores, tráfego).
##
## Três ruídos independentes (seeds derivadas):
## - `land_noise`  → densidade urbana / anéis de centro
## - `green_noise` → verdura / parques
## - `detail_noise` → pátios internos em escala de célula
##
## Coords tipicamente = índice de bloco (bx, by), exceto `detail_*` / `courtyard_hole`.

enum District {
	DOWNTOWN,
	RESIDENTIAL,
	INDUSTRIAL,
	PARK,
}

var land_noise: FastNoiseLite
var green_noise: FastNoiseLite
var detail_noise: FastNoiseLite


func _init(p_seed: int = 0) -> void:
	land_noise = _make_noise(p_seed, 0.045, 4, 2.0)
	green_noise = _make_noise(p_seed + 101, 0.08, 3, 1.8)
	detail_noise = _make_noise(p_seed + 333, 0.16, 2, 1.5)


func _make_noise(p_seed: int, freq: float, octaves: int, lacunarity: float) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = p_seed
	n.noise_type = FastNoiseLite.TYPE_PERLIN
	n.frequency = freq
	n.fractal_type = FastNoiseLite.FRACTAL_FBM
	n.fractal_octaves = octaves
	n.fractal_lacunarity = lacunarity
	n.fractal_gain = 0.5
	return n


## Normaliza amostra Perlin [-1,1] → [0,1].
func sample01(noise: FastNoiseLite, x: float, y: float) -> float:
	return clampf((noise.get_noise_2d(x, y) + 1.0) * 0.5, 0.0, 1.0)


func land_value(bx: float, by: float) -> float:
	return sample01(land_noise, bx, by)


func green_value(bx: float, by: float) -> float:
	return sample01(green_noise, bx, by)


func detail_value(x: float, y: float) -> float:
	return sample01(detail_noise, x, y)


## Heurística de anéis: parque verde; land alto → downtown; land baixo → industrial.
func district_at(bx: float, by: float) -> District:
	var land := land_value(bx, by)
	var green := green_value(bx, by)
	if green > 0.68 and land < 0.55:
		return District.PARK
	if land > 0.72:
		return District.DOWNTOWN
	if land < 0.32:
		return District.INDUSTRIAL
	return District.RESIDENTIAL


## Chance de abrir plaza: sobe com verdura, cai com density urbana.
func plaza_chance(bx: float, by: float, base: float) -> float:
	var green := green_value(bx, by)
	var land := land_value(bx, by)
	return clampf(base + green * 0.35 - land * 0.15, 0.02, 0.85)


## Pequenos “furos” dentro do quarteirão (pátio / estacionamento dirigível).
func courtyard_hole(cell_x: float, cell_y: float) -> bool:
	return detail_value(cell_x, cell_y) > 0.78


## Peso de spawn de vegetação (0–1).
func tree_weight(bx: float, by: float) -> float:
	return clampf(green_value(bx, by) * 1.25, 0.05, 1.0)


## Densidade relativa de tráfego NPC por distrito.
func traffic_weight(bx: float, by: float) -> float:
	var d := district_at(bx, by)
	match d:
		District.DOWNTOWN:
			return 1.0
		District.RESIDENTIAL:
			return 0.55
		District.INDUSTRIAL:
			return 0.7
		District.PARK:
			return 0.25
	return 0.5

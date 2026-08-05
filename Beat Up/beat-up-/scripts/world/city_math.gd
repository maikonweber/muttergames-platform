extends RefCounted
class_name CityMath
## Helpers puros da grade urbana — unit-testáveis (`tests/unit/test_city_math.gd`).
##
## Modelo: quarteirões de `block_size` separados por faixas de rua `street_width`.
## `stride = block_size + street_width` = período que se repete na grade.
##
## Atlas coords (espelham TILE_* em CityGenerator).

## Atlas: superfície dirigível vs prédio.
const ATLAS_ROAD := Vector2i(0, 0)
const ATLAS_BUILDING := Vector2i(1, 0)
const ATLAS_CROSSWALK := Vector2i(2, 0)
const ATLAS_AVENUE := Vector2i(3, 0)
const ATLAS_PARK := Vector2i(4, 0)
const ATLAS_BUILDING_RES := Vector2i(5, 0)
const ATLAS_BUILDING_IND := Vector2i(6, 0)


## Lado do mapa em células: N blocos + (N+1) faixas de rua nas bordas.
static func map_size_cells(grid_blocks: int, block_size: int, street_width: int) -> Vector2i:
	var side := grid_blocks * block_size + (grid_blocks + 1) * street_width
	return Vector2i(side, side)


static func stride(block_size: int, street_width: int) -> int:
	return block_size + street_width


## True se essa coordenada (x ou y) cai dentro da faixa de rua do período.
static func is_street_axis(coord: int, stride_value: int, street_width: int) -> bool:
	if stride_value <= 0:
		return false
	return (coord % stride_value) < street_width


## Índice da rua/bloco ao longo de um eixo (0, 1, 2…).
static func street_index(coord: int, stride_value: int) -> int:
	if stride_value <= 0:
		return 0
	return int(coord / stride_value)


## Rua que também é avenida (a cada `avenue_every` índices).
static func is_avenue_axis(coord: int, stride_value: int, street_width: int, avenue_every: int) -> bool:
	if not is_street_axis(coord, stride_value, street_width):
		return false
	if avenue_every <= 0:
		return false
	return street_index(coord, stride_value) % avenue_every == 0


static func is_intersection(x: int, y: int, stride_value: int, street_width: int) -> bool:
	return is_street_axis(x, stride_value, street_width) and is_street_axis(y, stride_value, street_width)


static func is_road_cell(x: int, y: int, stride_value: int, street_width: int) -> bool:
	return is_street_axis(x, stride_value, street_width) or is_street_axis(y, stride_value, street_width)


static func is_avenue_cell(x: int, y: int, stride_value: int, street_width: int, avenue_every: int) -> bool:
	return is_avenue_axis(x, stride_value, street_width, avenue_every) \
			or is_avenue_axis(y, stride_value, street_width, avenue_every)


## Spawn no meio da primeira faixa de rua (canto superior-esquerdo lógico).
static func spawn_cell(street_width: int) -> Vector2i:
	return Vector2i(street_width / 2, street_width / 2)


static func clamp_point(point: Vector2, bounds: Rect2) -> Vector2:
	if bounds.size == Vector2.ZERO:
		return point
	return Vector2(
		clampf(point.x, bounds.position.x, bounds.end.x),
		clampf(point.y, bounds.position.y, bounds.end.y),
	)


## Rua, cruzamento, avenida e parque são dirigíveis; prédios não.
static func is_drivable_atlas(atlas: Vector2i) -> bool:
	return atlas == ATLAS_ROAD \
			or atlas == ATLAS_CROSSWALK \
			or atlas == ATLAS_AVENUE \
			or atlas == ATLAS_PARK


static func is_building_atlas(atlas: Vector2i) -> bool:
	return atlas == ATLAS_BUILDING \
			or atlas == ATLAS_BUILDING_RES \
			or atlas == ATLAS_BUILDING_IND


## Encolhe o AABB com padding (play area interna às bordas do tile).
static func tighten_bounds(min_v: Vector2, max_v: Vector2, pad: Vector2) -> Rect2:
	return Rect2(min_v + pad, (max_v - min_v) - pad * 2.0)

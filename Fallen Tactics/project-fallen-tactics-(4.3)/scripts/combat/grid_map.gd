class_name TacticalGrid
extends Node2D
## Tactical grid: tiles, occupancy, path helpers.
## (Named TacticalGrid to avoid clashing with Godot's native GridMap.)

signal tile_clicked(cell: Vector2i)

const TILE_SIZE := 64
const WIDTH := 8
const HEIGHT := 6

enum TileType { GRASS, STONE, WATER, WALL, PIT, ELEVATED }

var tiles: Array = [] # 2D array of TileType
var _highlights: Dictionary = {} # Vector2i -> Color
var _occupancy: Dictionary = {} # Vector2i -> Unit


func _ready() -> void:
	_build_default_arena()
	queue_redraw()


func _build_default_arena() -> void:
	tiles.clear()
	for y in HEIGHT:
		var row: Array = []
		for x in WIDTH:
			row.append(TileType.GRASS)
		tiles.append(row)
	# Elevated ridge (archer high ground)
	for x in range(5, 8):
		tiles[0][x] = TileType.ELEVATED
		tiles[1][x] = TileType.STONE
	# Water channel
	tiles[3][3] = TileType.WATER
	tiles[3][4] = TileType.WATER
	tiles[4][3] = TileType.WATER
	# Wall cover
	tiles[2][4] = TileType.WALL
	tiles[4][5] = TileType.WALL
	# Pit hazard near edge
	tiles[5][1] = TileType.PIT
	tiles[5][2] = TileType.PIT


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < WIDTH and cell.y < HEIGHT


func get_tile(cell: Vector2i) -> TileType:
	if not in_bounds(cell):
		return TileType.WALL
	return tiles[cell.y][cell.x] as TileType


func is_walkable(cell: Vector2i) -> bool:
	if not in_bounds(cell):
		return false
	var t := get_tile(cell)
	if t == TileType.WALL or t == TileType.PIT:
		return false
	if _occupancy.has(cell):
		return false
	return true


func movement_cost(cell: Vector2i) -> int:
	match get_tile(cell):
		TileType.WATER:
			return 2
		TileType.ELEVATED:
			return 2
		_:
			return 1


func is_elevated(cell: Vector2i) -> bool:
	return get_tile(cell) == TileType.ELEVATED


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE + TILE_SIZE * 0.5, cell.y * TILE_SIZE + TILE_SIZE * 0.5)


func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / TILE_SIZE)), int(floor(pos.y / TILE_SIZE)))


func set_unit_at(cell: Vector2i, unit: Node) -> void:
	# Remove old occupancy for this unit
	var to_erase: Array[Vector2i] = []
	for k in _occupancy.keys():
		if _occupancy[k] == unit:
			to_erase.append(k)
	for k in to_erase:
		_occupancy.erase(k)
	if unit != null:
		_occupancy[cell] = unit


func get_unit_at(cell: Vector2i) -> Node:
	return _occupancy.get(cell, null)


func clear_highlights() -> void:
	_highlights.clear()
	queue_redraw()


func set_highlights(cells: Array, color: Color) -> void:
	_highlights.clear()
	for c in cells:
		_highlights[c] = color
	queue_redraw()


func manhattan(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func cells_in_range(origin: Vector2i, rmin: int, rmax: int, walkable_only: bool = false) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in HEIGHT:
		for x in WIDTH:
			var c := Vector2i(x, y)
			var d := manhattan(origin, c)
			if d >= rmin and d <= rmax:
				if walkable_only and not is_walkable(c) and c != origin:
					continue
				out.append(c)
	return out


func reachable_cells(origin: Vector2i, max_cost: int) -> Array[Vector2i]:
	# Dijkstra-ish BFS with costs
	var best: Dictionary = {}
	var q: Array = [origin]
	best[origin] = 0
	var out: Array[Vector2i] = []
	while not q.is_empty():
		var cur: Vector2i = q.pop_front()
		var spent: int = best[cur]
		if cur != origin:
			out.append(cur)
		for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var nxt: Vector2i = cur + dir
			if not is_walkable(nxt) and nxt != origin:
				continue
			if not in_bounds(nxt):
				continue
			# Allow stepping onto empty walkable
			if get_unit_at(nxt) != null and nxt != origin:
				continue
			if get_tile(nxt) == TileType.WALL or get_tile(nxt) == TileType.PIT:
				continue
			var cost := spent + movement_cost(nxt)
			if cost > max_cost:
				continue
			if best.has(nxt) and best[nxt] <= cost:
				continue
			best[nxt] = cost
			q.append(nxt)
	return out


func _draw() -> void:
	for y in HEIGHT:
		for x in WIDTH:
			var cell := Vector2i(x, y)
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			var col := _tile_color(get_tile(cell))
			draw_rect(rect, col)
			draw_rect(rect, Color(0.05, 0.05, 0.08, 0.9), false, 1.0)
			if _highlights.has(cell):
				var h: Color = _highlights[cell]
				h.a = 0.45
				draw_rect(rect.grow(-2), h)


func _tile_color(t: TileType) -> Color:
	match t:
		TileType.GRASS:
			return Color("2d4a3e")
		TileType.STONE:
			return Color("4a4a52")
		TileType.WATER:
			return Color("1a4a6e")
		TileType.WALL:
			return Color("2a2430")
		TileType.PIT:
			return Color("0d0a10")
		TileType.ELEVATED:
			return Color("6b5a3a")
		_:
			return Color.GRAY


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local := to_local(get_global_mouse_position())
		var cell := world_to_cell(local)
		if in_bounds(cell):
			tile_clicked.emit(cell)

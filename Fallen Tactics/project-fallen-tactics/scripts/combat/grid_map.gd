class_name TacticalGrid
extends Node2D
## Tactical grid — logical cells + isometric 2:1 render/input.
## (Named TacticalGrid to avoid clashing with Godot's native GridMap.)

const _IsoMath = preload("res://scripts/combat/iso_math.gd")

signal tile_clicked(cell: Vector2i)

## Large single-scenario battlefield (combat-only mode + FOW).
const WIDTH := 16
const HEIGHT := 10
## Legacy alias (approx tile height); prefer IsoMath.
const TILE_SIZE := 64
const DEFAULT_VISION := 4

enum TileType { GRASS, STONE, WATER, WALL, PIT, ELEVATED }

var tiles: Array = [] # 2D array of TileType
var _highlights: Dictionary = {} # Vector2i -> Color
var _occupancy: Dictionary = {} # Vector2i -> Unit
## Fog of war (keys "x,y")
var explored: Dictionary = {}
var visible_now: Dictionary = {}
var vision_range: int = DEFAULT_VISION

var _tex_grass: Texture2D
var _tex_grass2: Texture2D
var _tex_stone: Texture2D
var _tex_water: Texture2D
var _tex_wall: Texture2D
var _tex_pit: Texture2D
var _tex_elevated: Texture2D
var _use_textures: bool = false


func _ready() -> void:
	_load_textures()
	_build_default_arena()
	queue_redraw()


func _load_textures() -> void:
	_tex_grass = _try_tex("res://assets/tiles/combat/grass_01.png")
	_tex_grass2 = _try_tex("res://assets/tiles/combat/grass_02.png")
	_tex_stone = _try_tex("res://assets/tiles/combat/stone_01.png")
	_tex_water = _try_tex("res://assets/tiles/combat/water_01.png")
	_tex_wall = _try_tex("res://assets/tiles/combat/wall_01.png")
	_tex_pit = _try_tex("res://assets/tiles/combat/pit_01.png")
	_tex_elevated = _try_tex("res://assets/tiles/combat/elevated_01.png")
	_use_textures = _tex_grass != null


func _try_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _build_default_arena() -> void:
	tiles.clear()
	explored.clear()
	visible_now.clear()
	for y in HEIGHT:
		var row: Array = []
		for x in WIDTH:
			row.append(TileType.GRASS)
		tiles.append(row)
	# Elevated ridge (east high ground for archers)
	for x in range(11, 16):
		tiles[0][x] = TileType.ELEVATED
		tiles[1][x] = TileType.STONE
	# Stone road through the middle
	for x in range(2, 14):
		tiles[4][x] = TileType.STONE
		if x % 3 == 0 and HEIGHT > 5:
			tiles[5][x] = TileType.STONE
	# Water channel
	for c in [Vector2i(6, 2), Vector2i(7, 2), Vector2i(7, 3), Vector2i(8, 3), Vector2i(3, 7), Vector2i(4, 7)]:
		if in_bounds(c):
			tiles[c.y][c.x] = TileType.WATER
	# Walls / cover
	for c in [Vector2i(5, 5), Vector2i(9, 6), Vector2i(12, 4), Vector2i(4, 1)]:
		if in_bounds(c):
			tiles[c.y][c.x] = TileType.WALL
	# Pits near south edge
	for c in [Vector2i(2, 9), Vector2i(3, 9), Vector2i(10, 8)]:
		if in_bounds(c):
			tiles[c.y][c.x] = TileType.PIT


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
	## Center of isometric diamond (local space of this node).
	return _IsoMath.cell_to_screen(cell, Vector2.ZERO)


func world_to_cell(pos: Vector2) -> Vector2i:
	return _IsoMath.screen_to_cell(pos, Vector2.ZERO)


func point_in_diamond(local_pos: Vector2, cell: Vector2i, scale: float = 1.0) -> bool:
	## Fine hit-test: is local_pos inside the isometric diamond of cell?
	var c := cell_to_world(cell)
	var dx := absf(local_pos.x - c.x) / (_IsoMath.TILE_W * 0.5 * scale)
	var dy := absf(local_pos.y - c.y) / (_IsoMath.TILE_H * 0.5 * scale)
	return (dx + dy) <= 1.0


func pick_cell_at(local_pos: Vector2) -> Vector2i:
	## Prefer diamond containment; among matches, pick highest depth (front-most).
	var candidates: Array[Vector2i] = []
	var approx := world_to_cell(local_pos)
	# Search neighborhood of approximate cell
	for oy in range(-2, 3):
		for ox in range(-2, 3):
			var c := Vector2i(approx.x + ox, approx.y + oy)
			if in_bounds(c) and point_in_diamond(local_pos, c, 1.02):
				candidates.append(c)
	if candidates.is_empty():
		if in_bounds(approx) and point_in_diamond(local_pos, approx, 1.08):
			return approx
		return Vector2i(-1, -1)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return (a.x + a.y) > (b.x + b.y)
	)
	return candidates[0]


func board_center_world() -> Vector2:
	return cell_to_world(Vector2i(WIDTH / 2, HEIGHT / 2))


func set_unit_at(cell: Vector2i, unit: Node) -> void:
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


func cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func is_cell_explored(cell: Vector2i) -> bool:
	return explored.has(cell_key(cell))


func is_cell_visible(cell: Vector2i) -> bool:
	return visible_now.has(cell_key(cell))


func recompute_vision_from_cells(origins: Array, base_range: int = -1) -> void:
	## Union of vision from all living heroes.
	if base_range < 0:
		base_range = vision_range
	visible_now.clear()
	if origins.is_empty():
		queue_redraw()
		return
	for origin in origins:
		var o: Vector2i = origin as Vector2i
		for y in HEIGHT:
			for x in WIDTH:
				var c := Vector2i(x, y)
				if manhattan(o, c) <= base_range:
					var k := cell_key(c)
					visible_now[k] = true
					explored[k] = true
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
			if not in_bounds(nxt):
				continue
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
	# Back-to-front painter's algorithm (iso depth = x + y)
	var cells: Array[Vector2i] = []
	for y in HEIGHT:
		for x in WIDTH:
			cells.append(Vector2i(x, y))
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var da := a.x + a.y
		var db := b.x + b.y
		if da == db:
			return a.x < b.x
		return da < db
	)
	for cell in cells:
		_draw_iso_tile(cell)


func _draw_iso_tile(cell: Vector2i) -> void:
	var center := cell_to_world(cell)
	var vis := is_cell_visible(cell)
	var exp := is_cell_explored(cell)
	if not exp:
		_draw_diamond_filled(center, Color("0a0812"))
		_draw_diamond_outline(center, Color(0.02, 0.02, 0.04, 0.95), 1.0)
		return
	var t := get_tile(cell)
	var top_left := _IsoMath.tile_top_left(cell, Vector2.ZERO)
	var tex := _texture_for(t, cell)
	if tex != null:
		draw_texture(tex, top_left)
		if not vis:
			_draw_diamond_filled(center, Color(0.05, 0.04, 0.12, 0.55))
	else:
		_draw_procedural_diamond(center, t, cell)
		if not vis:
			_draw_diamond_filled(center, Color(0.05, 0.04, 0.12, 0.5))
	if t == TileType.ELEVATED and _tex_elevated == null and vis:
		_draw_height_face(center, t)
	if t == TileType.WALL and _tex_wall == null and vis:
		_draw_height_face(center, t)
	if t == TileType.PIT and _tex_pit == null and vis:
		_draw_pit_overlay(center)
	if t == TileType.WATER and _tex_water == null and vis:
		_draw_water_overlay(center, cell)
	# Highlights only in vision
	if _highlights.has(cell) and vis:
		var h: Color = _highlights[cell]
		h.a = 0.4
		_draw_diamond_filled(center, h, 0.92)
		_draw_diamond_outline(center, Color(h.r, h.g, h.b, 0.85), 2.0)


func _texture_for(t: TileType, cell: Vector2i) -> Texture2D:
	if not _use_textures:
		return null
	match t:
		TileType.GRASS:
			if _tex_grass2 and ((cell.x + cell.y) % 2 == 0):
				return _tex_grass2
			return _tex_grass
		TileType.STONE:
			return _tex_stone if _tex_stone else _tex_grass
		TileType.ELEVATED:
			return _tex_elevated if _tex_elevated else (_tex_stone if _tex_stone else _tex_grass)
		TileType.WATER:
			return _tex_water
		TileType.WALL:
			return _tex_wall
		TileType.PIT:
			return _tex_pit
		_:
			return null


func _diamond_points(center: Vector2, scale: float = 1.0) -> PackedVector2Array:
	var hw := _IsoMath.TILE_W * 0.5 * scale
	var hh := _IsoMath.TILE_H * 0.5 * scale
	return PackedVector2Array([
		center + Vector2(0, -hh),
		center + Vector2(hw, 0),
		center + Vector2(0, hh),
		center + Vector2(-hw, 0),
	])


func _draw_diamond_filled(center: Vector2, color: Color, scale: float = 1.0) -> void:
	draw_colored_polygon(_diamond_points(center, scale), color)


func _draw_diamond_outline(center: Vector2, color: Color, width: float = 1.0, scale: float = 1.0) -> void:
	var pts := _diamond_points(center, scale)
	for i in pts.size():
		draw_line(pts[i], pts[(i + 1) % pts.size()], color, width)


func _draw_procedural_diamond(center: Vector2, t: TileType, cell: Vector2i) -> void:
	var col := _tile_color(t)
	if t == TileType.GRASS and ((cell.x + cell.y) % 2 == 0):
		col = col.lightened(0.05)
	_draw_diamond_filled(center, col)
	_draw_diamond_outline(center, Color(0.05, 0.05, 0.08, 0.9), 1.0)


func _draw_height_face(center: Vector2, t: TileType) -> void:
	var rise := 10.0 if t == TileType.ELEVATED else 16.0
	var hw := _IsoMath.TILE_W * 0.5
	var hh := _IsoMath.TILE_H * 0.5
	var base_l := center + Vector2(-hw * 0.5, hh * 0.5)
	var base_r := center + Vector2(hw * 0.5, hh * 0.5)
	var base_b := center + Vector2(0, hh)
	var top_l := base_l + Vector2(0, -rise)
	var top_r := base_r + Vector2(0, -rise)
	var top_b := base_b + Vector2(0, -rise)
	var face_col := Color(0.15, 0.12, 0.1, 0.55) if t == TileType.ELEVATED else Color(0.12, 0.1, 0.14, 0.75)
	draw_colored_polygon(PackedVector2Array([base_l, base_b, top_b, top_l]), face_col)
	draw_colored_polygon(PackedVector2Array([base_r, base_b, top_b, top_r]), face_col.darkened(0.15))


func _draw_pit_overlay(center: Vector2) -> void:
	_draw_diamond_filled(center, Color(0.04, 0.02, 0.05, 0.92), 0.75)
	_draw_diamond_outline(center, Color(0.7, 0.2, 0.15, 0.7), 2.0, 0.85)


func _draw_water_overlay(center: Vector2, cell: Vector2i) -> void:
	_draw_diamond_filled(center, Color(0.1, 0.3, 0.45, 0.55), 0.95)
	var yoff := 2.0 if (cell.x + cell.y) % 2 == 0 else -1.0
	draw_line(center + Vector2(-20, yoff), center + Vector2(20, yoff + 1), Color(0.5, 0.8, 1.0, 0.25), 2.0)


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
		var cell := pick_cell_at(local)
		if cell.x >= 0 and in_bounds(cell):
			tile_clicked.emit(cell)

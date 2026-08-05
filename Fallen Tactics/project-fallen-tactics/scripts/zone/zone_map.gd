class_name ZoneMap
extends Node2D
## Exploration grid (iso 2:1, smaller tiles).

signal cell_clicked(cell: Vector2i)

const _ZM = preload("res://scripts/zone/zone_math.gd")

enum TileType { GRASS, ROAD, FOREST, WATER, EXIT, BOSS_GATE }

var width: int = 16
var height: int = 12
var tiles: Array = []
var _highlights: Dictionary = {}
## Fog of war: keys "x,y" as String
var explored: Dictionary = {}
var visible_now: Dictionary = {}
const UNEXPLORED_COLOR := Color("0a0812")
const EXPLORED_DIM := 0.38


func _ready() -> void:
	if tiles.is_empty():
		setup(width, height)


func setup(w: int, h: int) -> void:
	width = w
	height = h
	tiles.clear()
	for y in height:
		var row: Array = []
		for x in width:
			row.append(TileType.GRASS)
		tiles.append(row)
	_build_layout()
	queue_redraw()


func cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func is_cell_explored(cell: Vector2i) -> bool:
	return explored.has(cell_key(cell))


func is_cell_visible(cell: Vector2i) -> bool:
	return visible_now.has(cell_key(cell))


func set_explored_from_state(explored_list: Array) -> void:
	explored.clear()
	for item in explored_list:
		if item is String:
			explored[item] = true
		elif item is Vector2i:
			explored[cell_key(item)] = true
		elif item is Array and item.size() >= 2:
			explored[cell_key(Vector2i(int(item[0]), int(item[1])))] = true


func explored_to_state() -> Array:
	var out: Array = []
	for k in explored.keys():
		out.append(str(k))
	return out


func recompute_vision(origin: Vector2i, vision_range: int) -> void:
	## Updates visible_now and merges into explored.
	visible_now.clear()
	if vision_range < 0:
		vision_range = 0
	for y in height:
		for x in width:
			var c := Vector2i(x, y)
			if manhattan(origin, c) <= vision_range:
				var k := cell_key(c)
				visible_now[k] = true
				explored[k] = true
	queue_redraw()


func _build_layout() -> void:
	# Road path to the east
	for x in range(0, width):
		if height > 5:
			tiles[5][x] = TileType.ROAD
		if height > 6 and x > 2:
			tiles[6][x] = TileType.ROAD
	# Forest patches
	for c in [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(4, 9), Vector2i(5, 9), Vector2i(10, 4)]:
		if in_bounds(c):
			tiles[c.y][c.x] = TileType.FOREST
	# Water
	for c in [Vector2i(7, 1), Vector2i(8, 1), Vector2i(8, 2), Vector2i(3, 10), Vector2i(4, 10)]:
		if in_bounds(c):
			tiles[c.y][c.x] = TileType.WATER
	# Exit / boss gate
	if in_bounds(Vector2i(width - 1, 5)):
		tiles[5][width - 1] = TileType.EXIT
	if in_bounds(Vector2i(width - 2, 5)):
		tiles[5][width - 2] = TileType.BOSS_GATE


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func get_tile(cell: Vector2i) -> TileType:
	if not in_bounds(cell) or tiles.is_empty() or cell.y >= tiles.size():
		return TileType.WATER
	var row: Array = tiles[cell.y]
	if cell.x >= row.size():
		return TileType.WATER
	return row[cell.x] as TileType


func is_walkable(cell: Vector2i) -> bool:
	if not in_bounds(cell):
		return false
	return get_tile(cell) != TileType.WATER


func move_cost(cell: Vector2i) -> int:
	match get_tile(cell):
		TileType.FOREST:
			return 2
		TileType.ROAD:
			return 1
		_:
			return 1


func cell_to_world(cell: Vector2i) -> Vector2:
	return _ZM.cell_to_screen(cell, Vector2.ZERO)


func world_to_cell(pos: Vector2) -> Vector2i:
	return _ZM.screen_to_cell(pos, Vector2.ZERO)


func pick_cell_at(local_pos: Vector2) -> Vector2i:
	var approx := world_to_cell(local_pos)
	var candidates: Array[Vector2i] = []
	for oy in range(-2, 3):
		for ox in range(-2, 3):
			var c := Vector2i(approx.x + ox, approx.y + oy)
			if in_bounds(c) and _ZM.point_in_diamond(local_pos, c, Vector2.ZERO, 1.05):
				candidates.append(c)
	if candidates.is_empty():
		return Vector2i(-1, -1)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return (a.x + a.y) > (b.x + b.y))
	return candidates[0]


func set_highlights(cells: Array, color: Color) -> void:
	_highlights.clear()
	for c in cells:
		# Only highlight visible cells
		if is_cell_visible(c):
			_highlights[c] = color
	queue_redraw()


func clear_highlights() -> void:
	_highlights.clear()
	queue_redraw()


func manhattan(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func neighbors4(cell: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var n: Vector2i = cell + d
		if in_bounds(n):
			out.append(n)
	return out


func _draw() -> void:
	if tiles.is_empty():
		return
	var cells: Array[Vector2i] = []
	for y in height:
		for x in width:
			cells.append(Vector2i(x, y))
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var da := a.x + a.y
		var db := b.x + b.y
		if da == db:
			return a.x < b.x
		return da < db
	)
	for cell in cells:
		_draw_tile(cell)


func _draw_tile(cell: Vector2i) -> void:
	var c := cell_to_world(cell)
	var vis := is_cell_visible(cell)
	var exp := is_cell_explored(cell)
	if not exp:
		# Never seen
		_draw_diamond(c, UNEXPLORED_COLOR)
		_draw_diamond_outline(c, Color(0.02, 0.02, 0.04, 0.95))
		return
	var t := get_tile(cell)
	var col := _tile_color(t)
	if t == TileType.GRASS and (cell.x + cell.y) % 2 == 0:
		col = col.lightened(0.05)
	if not vis:
		# Memory fog: dim + cool tint
		col = col.darkened(1.0 - EXPLORED_DIM)
		col = col.lerp(Color("1a1830"), 0.35)
		col.a = 1.0
	_draw_diamond(c, col)
	_draw_diamond_outline(c, Color(0.05, 0.05, 0.08, 0.85) if vis else Color(0.08, 0.08, 0.12, 0.7))
	if not vis:
		# Soft overlay shroud
		_draw_diamond(c, Color(0.05, 0.04, 0.1, 0.35), 0.98)
	if _highlights.has(cell) and vis:
		var h: Color = _highlights[cell]
		h.a = 0.4
		_draw_diamond(c, h, 0.9)


func _diamond_pts(center: Vector2, scale: float = 1.0) -> PackedVector2Array:
	var hw := _ZM.TILE_W * 0.5 * scale
	var hh := _ZM.TILE_H * 0.5 * scale
	return PackedVector2Array([
		center + Vector2(0, -hh),
		center + Vector2(hw, 0),
		center + Vector2(0, hh),
		center + Vector2(-hw, 0),
	])


func _draw_diamond(center: Vector2, color: Color, scale: float = 1.0) -> void:
	draw_colored_polygon(_diamond_pts(center, scale), color)


func _draw_diamond_outline(center: Vector2, color: Color) -> void:
	var pts := _diamond_pts(center)
	for i in pts.size():
		draw_line(pts[i], pts[(i + 1) % pts.size()], color, 1.0)


func _tile_color(t: TileType) -> Color:
	match t:
		TileType.GRASS:
			return Color("2d4a3e")
		TileType.ROAD:
			return Color("5a5348")
		TileType.FOREST:
			return Color("1a3a28")
		TileType.WATER:
			return Color("1a4a6e")
		TileType.EXIT:
			return Color("c9a227")
		TileType.BOSS_GATE:
			return Color("8b2a2a")
		_:
			return Color.GRAY


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local := to_local(get_global_mouse_position())
		var cell := pick_cell_at(local)
		if cell.x >= 0 and (is_cell_visible(cell) or is_cell_explored(cell)):
			# Allow click on explored/visible only (not pure black fog)
			cell_clicked.emit(cell)

class_name ZoneMath
extends RefCounted
## Smaller isometric tiles for exploration zone (still 2:1).

const TILE_W := 64
const TILE_H := 32


static func cell_to_screen(cell: Vector2i, origin: Vector2 = Vector2.ZERO) -> Vector2:
	var sx := (cell.x - cell.y) * (TILE_W / 2)
	var sy := (cell.x + cell.y) * (TILE_H / 2)
	return origin + Vector2(sx, sy)


static func screen_to_cell(screen: Vector2, origin: Vector2 = Vector2.ZERO) -> Vector2i:
	var p := screen - origin
	var x := (p.x / float(TILE_W / 2) + p.y / float(TILE_H / 2)) / 2.0
	var y := (p.y / float(TILE_H / 2) - p.x / float(TILE_W / 2)) / 2.0
	return Vector2i(int(floor(x + 0.5)), int(floor(y + 0.5)))


static func tile_top_left(cell: Vector2i, origin: Vector2 = Vector2.ZERO) -> Vector2:
	var c := cell_to_screen(cell, origin)
	return c - Vector2(TILE_W / 2, TILE_H / 2)


static func point_in_diamond(local_pos: Vector2, cell: Vector2i, origin: Vector2 = Vector2.ZERO, scale: float = 1.0) -> bool:
	var c := cell_to_screen(cell, origin)
	var dx := absf(local_pos.x - c.x) / (TILE_W * 0.5 * scale)
	var dy := absf(local_pos.y - c.y) / (TILE_H * 0.5 * scale)
	return (dx + dy) <= 1.0

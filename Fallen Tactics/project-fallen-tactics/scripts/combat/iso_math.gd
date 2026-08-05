class_name IsoMath
extends RefCounted
## Isometric 2:1 projection helpers (diamond tiles).

const TILE_W := 128
const TILE_H := 64


static func cell_to_screen(cell: Vector2i, origin: Vector2 = Vector2.ZERO) -> Vector2:
	## Center of the diamond for this cell.
	var sx := (cell.x - cell.y) * (TILE_W / 2)
	var sy := (cell.x + cell.y) * (TILE_H / 2)
	return origin + Vector2(sx, sy)


static func screen_to_cell(screen: Vector2, origin: Vector2 = Vector2.ZERO) -> Vector2i:
	var p := screen - origin
	var x := (p.x / float(TILE_W / 2) + p.y / float(TILE_H / 2)) / 2.0
	var y := (p.y / float(TILE_H / 2) - p.x / float(TILE_W / 2)) / 2.0
	return Vector2i(int(floor(x + 0.5)), int(floor(y + 0.5)))


static func tile_top_left(cell: Vector2i, origin: Vector2 = Vector2.ZERO) -> Vector2:
	## Top-left of the 128x64 diamond texture so its center sits on cell_to_screen.
	var c := cell_to_screen(cell, origin)
	return c - Vector2(TILE_W / 2, TILE_H / 2)


static func unit_draw_pos(cell: Vector2i, origin: Vector2 = Vector2.ZERO, foot_y_ratio: float = 0.72) -> Vector2:
	## Top-left for a 128x128 unit sprite with feet at foot_y_ratio of the texture.
	var c := cell_to_screen(cell, origin)
	return c - Vector2(64.0, 128.0 * foot_y_ratio)

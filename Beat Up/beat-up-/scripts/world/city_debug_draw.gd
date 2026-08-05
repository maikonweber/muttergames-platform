extends Node2D
## Overlay de desenho da cidade (filho `DebugDraw` do CityGenerator).
##
## - bounds: retângulo `play_bounds` (área jogável)
## - colliders: diamantes das células de prédio (mesma forma de WorldCollision)
## Toggle via DebugManager F6 / propriedades `show_*_overlay`.

const COLOR_BOUNDS := Color(0.2, 0.9, 1.0, 0.95)
const COLOR_COLLIDER_FILL := Color(1.0, 0.4, 0.0, 0.22)
const COLOR_COLLIDER_LINE := Color(1.0, 0.55, 0.1, 0.9)


func _draw() -> void:
	var city := get_parent() as CityGenerator
	if city == null:
		return

	if city.show_bounds_overlay:
		var bounds_global: Rect2 = city.get_play_bounds()
		if bounds_global.size != Vector2.ZERO:
			var local_pos: Vector2 = to_local(bounds_global.position)
			var local_end: Vector2 = to_local(bounds_global.end)
			draw_rect(Rect2(local_pos, local_end - local_pos), COLOR_BOUNDS, false, 2.0)

	if not city.show_collider_overlay:
		return

	var hw: float = float(city.tile_width) * 0.46
	var hh: float = float(city.tile_height) * 0.46
	for cell in city.get_building_cells():
		var center: Vector2 = city.tile_map.map_to_local(cell)
		var pts := PackedVector2Array([
			center + Vector2(0.0, -hh),
			center + Vector2(hw, 0.0),
			center + Vector2(0.0, hh),
			center + Vector2(-hw, 0.0),
		])
		draw_colored_polygon(pts, COLOR_COLLIDER_FILL)
		var outline: PackedVector2Array = pts.duplicate()
		outline.append(pts[0])
		draw_polyline(outline, COLOR_COLLIDER_LINE, 1.5)

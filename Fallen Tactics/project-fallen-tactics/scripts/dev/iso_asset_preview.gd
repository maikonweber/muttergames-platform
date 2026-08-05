extends Node2D
## Dev scene: preview isometric tiles + unit sprites (not full combat).

const _IsoMath = preload("res://scripts/combat/iso_math.gd")
const GRASS := preload("res://assets/tiles/combat/grass_01.png")
const GRASS2 := preload("res://assets/tiles/combat/grass_02.png")
const STONE := preload("res://assets/tiles/combat/stone_01.png")
const IDLE_SE := preload("res://assets/units/espadachim/espadachim_idle_se.png")
const IDLE_SW := preload("res://assets/units/espadachim/espadachim_idle_sw.png")
const ATK_SE := preload("res://assets/units/espadachim/espadachim_attack_slash_se.png")

var _origin := Vector2(420, 80)
var _pose := 0 # 0 idle_se, 1 idle_sw, 2 attack
var _unit_cell := Vector2i(2, 2)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	# background
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("1a1420"))
	# board 5x5
	for y in 5:
		for x in 5:
			var cell := Vector2i(x, y)
			var tex: Texture2D = STONE if (x + y) % 4 == 0 else (GRASS2 if (x + y) % 2 == 0 else GRASS)
			var pos := _IsoMath.tile_top_left(cell, _origin)
			draw_texture(tex, pos)
	# unit
	var utex: Texture2D = IDLE_SE
	match _pose:
		1:
			utex = IDLE_SW
		2:
			utex = ATK_SE
	draw_texture(utex, _IsoMath.unit_draw_pos(_unit_cell, _origin))
	# pivot cross
	var c := _IsoMath.cell_to_screen(_unit_cell, _origin)
	draw_line(c + Vector2(-8, 0), c + Vector2(8, 0), Color("ffe08a"), 1.0)
	draw_line(c + Vector2(0, -8), c + Vector2(0, 8), Color("ffe08a"), 1.0)
	# help
	var font := ThemeDB.fallback_font
	var msg := "Iso preview 2:1 — [1] idle_se  [2] idle_sw  [3] attack_slash_se  |  Arrows move unit  |  Esc quit"
	draw_string(font, Vector2(24, 28), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("e8e4ef"))
	draw_string(font, Vector2(24, 52), "Cell: %s" % str(_unit_cell), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("c9a227"))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_pose = 0
				queue_redraw()
			KEY_2:
				_pose = 1
				queue_redraw()
			KEY_3:
				_pose = 2
				queue_redraw()
			KEY_LEFT:
				_unit_cell.x = maxi(0, _unit_cell.x - 1)
				queue_redraw()
			KEY_RIGHT:
				_unit_cell.x = mini(4, _unit_cell.x + 1)
				queue_redraw()
			KEY_UP:
				_unit_cell.y = maxi(0, _unit_cell.y - 1)
				queue_redraw()
			KEY_DOWN:
				_unit_cell.y = mini(4, _unit_cell.y + 1)
				queue_redraw()
			KEY_ESCAPE:
				get_tree().quit()

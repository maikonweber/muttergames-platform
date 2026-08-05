class_name AIController
extends RefCounted
## Simple personality-based AI for VS enemies.

const _CombatFx = preload("res://scripts/combat/combat_fx.gd")


static func take_turn(unit: BattleUnit, combat: Node) -> Array[String]:
	var log: Array[String] = []
	var grid: TacticalGrid = combat.grid
	var hero: BattleUnit = null
	if combat.has_method("get_ai_target"):
		hero = combat.get_ai_target(unit)
	else:
		hero = combat.get_hero()
	if hero == null or not hero.alive or not unit.alive:
		return log

	match unit.ai_profile:
		"flanker":
			log.append_array(_flanker(unit, hero, grid, combat))
		"ranged":
			log.append_array(_ranged(unit, hero, grid, combat))
		"boss":
			log.append_array(_boss(unit, hero, grid, combat))
		_:
			log.append_array(_rusher(unit, hero, grid, combat))
	return log


static func _rusher(unit: BattleUnit, hero: BattleUnit, grid: TacticalGrid, combat: Node) -> Array[String]:
	var log: Array[String] = []
	var dist := grid.manhattan(unit.cell, hero.cell)
	if dist == 1:
		log.append_array(_melee_hit(unit, hero, 6, grid, combat))
	else:
		_step_toward(unit, hero.cell, grid, 2, log)
		if grid.manhattan(unit.cell, hero.cell) == 1:
			log.append_array(_melee_hit(unit, hero, 5, grid, combat))
	return log


static func _flanker(unit: BattleUnit, hero: BattleUnit, grid: TacticalGrid, combat: Node) -> Array[String]:
	var log: Array[String] = []
	# Prefer tile behind hero
	var back: Vector2i = hero.cell - hero.facing_vector()
	var goal := back if grid.is_walkable(back) else hero.cell
	if grid.manhattan(unit.cell, hero.cell) == 1:
		log.append_array(_melee_hit(unit, hero, 4, grid, combat))
	else:
		_step_toward(unit, goal, grid, 3, log)
		if grid.manhattan(unit.cell, hero.cell) == 1:
			log.append_array(_melee_hit(unit, hero, 4, grid, combat))
	return log


static func _ranged(unit: BattleUnit, hero: BattleUnit, grid: TacticalGrid, combat: Node) -> Array[String]:
	var log: Array[String] = []
	# Seek elevated if not on it
	if not grid.is_elevated(unit.cell):
		var elev := _find_tile(grid, TacticalGrid.TileType.ELEVATED, unit)
		if elev != Vector2i(-1, -1):
			_step_toward(unit, elev, grid, 2, log)
	var dist := grid.manhattan(unit.cell, hero.cell)
	if dist >= 2 and dist <= 4:
		var dmg := 4
		if grid.is_elevated(unit.cell):
			dmg += 2
		var step: Vector2i = hero.cell - unit.cell
		step = Vector2i(signi(step.x), signi(step.y))
		unit.face_toward(hero.cell)
		_CombatFx.slash(combat, unit.global_position, hero.global_position)
		var dealt := hero.take_damage(dmg, step, unit)
		log.append("%s dispara (%d)" % [unit.display_name, dealt])
	elif dist < 2:
		# Kite away
		var away: Vector2i = unit.cell + (unit.cell - hero.cell)
		_step_toward(unit, away, grid, 2, log)
	else:
		_step_toward(unit, hero.cell, grid, 2, log)
	return log


static func _boss(unit: BattleUnit, hero: BattleUnit, grid: TacticalGrid, combat: Node) -> Array[String]:
	var log: Array[String] = []
	var hp_ratio := float(unit.hp) / float(unit.max_hp)
	# Phase 2: spawn help once
	if hp_ratio <= 0.66 and combat.has_method("boss_try_phase2"):
		if combat.boss_try_phase2():
			log.append("O Capitão convoca reforços e o chão treme!")
			return log
	if hp_ratio <= 0.33 and combat.has_method("boss_try_phase3"):
		if combat.boss_try_phase3():
			log.append("O Capitão empurra com fúria! Timeline acelerada.")
	var dist := grid.manhattan(unit.cell, hero.cell)
	if dist == 1:
		log.append_array(_melee_hit(unit, hero, 7, grid, combat))
		# Push
		var push_dir: Vector2i = hero.cell - unit.cell
		push_dir = Vector2i(signi(push_dir.x), signi(push_dir.y))
		var dest: Vector2i = hero.cell + push_dir
		if grid.in_bounds(dest) and grid.get_unit_at(dest) == null:
			if grid.get_tile(dest) == TacticalGrid.TileType.PIT:
				hero.take_damage(8, push_dir, unit)
				log.append("%s é empurrado em direção ao penhasco!" % hero.display_name)
			elif grid.is_walkable(dest) or grid.get_tile(dest) == TacticalGrid.TileType.WATER:
				grid.set_unit_at(hero.cell, null)
				hero.place_on_grid(grid, dest)
				log.append("%s é empurrado!" % hero.display_name)
	else:
		_step_toward(unit, hero.cell, grid, 2, log)
		if grid.manhattan(unit.cell, hero.cell) == 1:
			log.append_array(_melee_hit(unit, hero, 6, grid, combat))
	return log


static func _melee_hit(unit: BattleUnit, hero: BattleUnit, base: int, grid: TacticalGrid, combat: Node = null) -> Array[String]:
	var log: Array[String] = []
	unit.face_toward(hero.cell)
	if combat:
		_CombatFx.slash(combat, unit.global_position, hero.global_position)
	var step: Vector2i = hero.cell - unit.cell
	var dealt := hero.take_damage(base, step, unit)
	log.append("%s ataca %s (%d)" % [unit.display_name, hero.display_name, dealt])
	return log


static func _step_toward(unit: BattleUnit, goal: Vector2i, grid: TacticalGrid, steps: int, log: Array[String]) -> void:
	for i in steps:
		if unit.cell == goal:
			break
		var best: Vector2i = unit.cell
		var best_d := grid.manhattan(unit.cell, goal)
		for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var nxt: Vector2i = unit.cell + dir
			if not grid.in_bounds(nxt):
				continue
			if grid.get_unit_at(nxt) != null:
				continue
			if grid.get_tile(nxt) == TacticalGrid.TileType.WALL or grid.get_tile(nxt) == TacticalGrid.TileType.PIT:
				continue
			var d := grid.manhattan(nxt, goal)
			if d < best_d:
				best_d = d
				best = nxt
		if best == unit.cell:
			break
		grid.set_unit_at(unit.cell, null)
		unit.face_toward(best)
		unit.place_on_grid(grid, best)
	log.append("%s reposiciona → %s" % [unit.display_name, str(unit.cell)])


static func _find_tile(grid: TacticalGrid, t: int, unit: BattleUnit) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d := 999
	for y in TacticalGrid.HEIGHT:
		for x in TacticalGrid.WIDTH:
			var c := Vector2i(x, y)
			if grid.get_tile(c) != t:
				continue
			if grid.get_unit_at(c) != null and grid.get_unit_at(c) != unit:
				continue
			var d := grid.manhattan(unit.cell, c)
			if d < best_d:
				best_d = d
				best = c
	return best

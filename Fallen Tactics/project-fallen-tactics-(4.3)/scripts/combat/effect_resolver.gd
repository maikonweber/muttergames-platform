class_name EffectResolver
extends RefCounted
## Resolves card effect opcodes against combat state.


static func resolve(
	effects: Array,
	caster: BattleUnit,
	target: BattleUnit,
	target_cell: Vector2i,
	grid: TacticalGrid,
	combat: Node
) -> Dictionary:
	var log: Array[String] = []
	var hit_something := false
	for e in effects:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var op: String = str(e.get("op", ""))
		match op:
			"damage":
				var r := _op_damage(e, caster, target, grid, log)
				hit_something = hit_something or r
			"move":
				_op_move(e, caster, target_cell, grid, log)
			"block":
				caster.add_block(int(e.get("value", 0)))
				log.append("%s ganha %d Block" % [caster.display_name, int(e.get("value", 0))])
			"stance":
				caster.set_stance(str(e.get("value", "balance")))
				log.append("%s → postura %s" % [caster.display_name, caster.stance])
			"flag":
				_op_flag(e, caster)
			"prepare_reaction":
				caster.prepared_reaction = str(e.get("kind", ""))
				log.append("%s prepara %s" % [caster.display_name, caster.prepared_reaction])
			"delay_timeline":
				if target and target.alive:
					target.timeline_value += int(e.get("value", 0))
					log.append("%s atrasado +%d" % [target.display_name, int(e.get("value", 0))])
			"advance_timeline":
				caster.timeline_value = maxi(0, caster.timeline_value - int(e.get("value", 0)))
				log.append("%s adianta turno -%d" % [caster.display_name, int(e.get("value", 0))])
			"face_toward_caster":
				if target and target.alive:
					target.face_toward(caster.cell)
					log.append("%s vira para %s" % [target.display_name, caster.display_name])
			"free_facing":
				pass # facing set by player click flow later; default face move dir
			"strip_block":
				if target:
					target.block = 0
					log.append("%s perde Block" % target.display_name)
			"vulnerable":
				if target:
					target.vulnerable_stacks += int(e.get("value", 1))
					log.append("%s está Vulnerável" % target.display_name)
			"mark_duel":
				if target:
					caster.duel_target = target
					target.marked_by = caster
					log.append("Duelo: %s marca %s" % [caster.display_name, target.display_name])
			"charge":
				var r2 := _op_charge(e, caster, target, grid, log)
				hit_something = hit_something or r2
			"aoe_adjacent":
				var r3 := _op_aoe(e, caster, grid, combat, log)
				hit_something = hit_something or r3
			_:
				log.append("op desconhecida: %s" % op)
	return {"log": log, "hit": hit_something}


static func _op_flag(e: Dictionary, caster: BattleUnit) -> void:
	var name: String = str(e.get("name", ""))
	match name:
		"no_attack":
			caster.no_attack_this_turn = true
		"pressure":
			caster.pressure_ready = true
		"next_attack_bonus":
			caster.next_attack_bonus += int(e.get("value", 0))
		"duel_bonus":
			caster.duel_bonus = int(e.get("value", 3))
		"discard_one":
			pass # handled end of turn if needed


static func _damage_amount(base: int, caster: BattleUnit, target: BattleUnit) -> int:
	var dmg := base
	if caster.stance == "offense":
		dmg += 1
	if caster.pressure_ready:
		dmg += 2
	if caster.next_attack_bonus > 0:
		dmg += caster.next_attack_bonus
		caster.next_attack_bonus = 0
	if caster.duel_target == target and caster.duel_bonus > 0:
		dmg += caster.duel_bonus
	return dmg


static func _after_hit(caster: BattleUnit, did_hit: bool, combat: Node) -> void:
	if did_hit and caster.pressure_ready:
		caster.pressure_ready = false
		if caster.is_player:
			caster.draw_cards(1)
			if combat.has_method("refresh_hand_ui"):
				combat.refresh_hand_ui()


static func _op_damage(e: Dictionary, caster: BattleUnit, target: BattleUnit, grid: TacticalGrid, log: Array[String]) -> bool:
	if target == null or not target.alive:
		return false
	if caster.no_attack_this_turn:
		log.append("Não pode atacar neste turno (Sprint).")
		return false
	if bool(e.get("require_setup", false)):
		var ok := caster.stance == "offense" or caster.duel_target == target
		if not ok:
			log.append("Lâmina Final exige Ofensiva ou marca de Duelo.")
			return false
	var base := int(e.get("value", 0))
	var dmg := _damage_amount(base, caster, target)
	var from_dir: Vector2i = target.cell - caster.cell
	# normalize to unit step for facing
	var step := Vector2i(signi(from_dir.x), signi(from_dir.y))
	if abs(from_dir.x) > abs(from_dir.y):
		step = Vector2i(signi(from_dir.x), 0)
	elif abs(from_dir.y) > 0:
		step = Vector2i(0, signi(from_dir.y))
	caster.face_toward(target.cell)
	var dealt := target.take_damage(dmg, step, caster)
	log.append("%s causa %d em %s" % [caster.display_name, dealt, target.display_name])
	_after_hit(caster, dealt > 0 or target.block >= 0, null)
	if caster.pressure_ready:
		caster.pressure_ready = false
		caster.draw_cards(1)
	return true


static func _op_move(e: Dictionary, caster: BattleUnit, target_cell: Vector2i, grid: TacticalGrid, log: Array[String]) -> void:
	var max_tiles := int(e.get("max_tiles", 1))
	if not grid.in_bounds(target_cell):
		return
	if grid.manhattan(caster.cell, target_cell) > max_tiles:
		log.append("Fora de alcance de movimento.")
		return
	if target_cell != caster.cell and not grid.is_walkable(target_cell):
		# allow if only blocked by self
		if grid.get_unit_at(target_cell) != null:
			log.append("Tile ocupado.")
			return
		if grid.get_tile(target_cell) == TacticalGrid.TileType.WALL or grid.get_tile(target_cell) == TacticalGrid.TileType.PIT:
			log.append("Tile bloqueado.")
			return
	# Path cost check simplified: manhattan * min cost, water inflates
	var dist := grid.manhattan(caster.cell, target_cell)
	if dist > max_tiles:
		return
	var old := caster.cell
	if target_cell != old:
		caster.face_toward(target_cell)
		grid.set_unit_at(old, null)
		caster.place_on_grid(grid, target_cell)
		log.append("%s move para %s" % [caster.display_name, str(target_cell)])


static func _op_charge(e: Dictionary, caster: BattleUnit, target: BattleUnit, grid: TacticalGrid, log: Array[String]) -> bool:
	if target == null or not target.alive:
		return false
	if caster.no_attack_this_turn:
		log.append("Não pode atacar neste turno.")
		return false
	var max_tiles := int(e.get("max_tiles", 3))
	var dmg_base := int(e.get("damage", 4))
	var elev_bonus := int(e.get("elevation_bonus", 0))
	var from_elev := grid.is_elevated(caster.cell)
	# Must be aligned axis
	var d: Vector2i = target.cell - caster.cell
	if d.x != 0 and d.y != 0:
		log.append("Investida exige linha reta.")
		return false
	var dist := grid.manhattan(caster.cell, target.cell)
	if dist < 1 or dist > max_tiles:
		log.append("Fora de alcance da Investida.")
		return false
	# Move adjacent to target along line
	var step := Vector2i(signi(d.x), signi(d.y))
	var dest: Vector2i = target.cell - step
	if dest != caster.cell:
		if grid.get_unit_at(dest) != null and grid.get_unit_at(dest) != caster:
			log.append("Caminho bloqueado.")
			return false
		if grid.get_tile(dest) == TacticalGrid.TileType.WALL or grid.get_tile(dest) == TacticalGrid.TileType.PIT:
			log.append("Destino inválido.")
			return false
		grid.set_unit_at(caster.cell, null)
		caster.place_on_grid(grid, dest)
	if from_elev:
		dmg_base += elev_bonus
	var dmg := _damage_amount(dmg_base, caster, target)
	caster.face_toward(target.cell)
	var dealt := target.take_damage(dmg, step, caster)
	log.append("%s investe e causa %d em %s" % [caster.display_name, dealt, target.display_name])
	if caster.pressure_ready:
		caster.pressure_ready = false
		caster.draw_cards(1)
	return true


static func _op_aoe(e: Dictionary, caster: BattleUnit, grid: TacticalGrid, combat: Node, log: Array[String]) -> bool:
	var value := int(e.get("value", 3))
	var hit := false
	var units: Array = combat.get_all_units() if combat.has_method("get_all_units") else []
	for u in units:
		if u == caster or not u.alive or u.is_player == caster.is_player:
			continue
		if grid.manhattan(caster.cell, u.cell) != 1:
			continue
		var dmg := _damage_amount(value, caster, u)
		var step: Vector2i = u.cell - caster.cell
		var dealt: int = u.take_damage(dmg, step, caster)
		log.append("%s corta %s (%d)" % [caster.display_name, u.display_name, dealt])
		hit = true
	if hit and caster.pressure_ready:
		caster.pressure_ready = false
		caster.draw_cards(1)
	return hit

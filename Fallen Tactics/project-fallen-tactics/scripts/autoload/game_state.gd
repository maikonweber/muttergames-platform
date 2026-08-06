extends Node
## Run state: party, zone exploration, combat handoff.

const _ClassLibrary = preload("res://scripts/data/class_library.gd")

const ZONE_SCENE := "res://scenes/zone/zone_scene.tscn"
const COMBAT_SCENE := "res://scenes/combat/combat_scene.tscn"
const PVP_ARENA_SCENE := "res://scenes/pvp/pvp_arena.tscn"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var run_active: bool = false
var relic_ids: Array[String] = []
var encounter_index: int = 0
var last_combat_won: bool = false
## Saldo local pendente de sincronização com o ledger da plataforma.
var mutter_coins: int = 0

## Party heroes
var party: Array = []

## Zone persistence for current run
var zone: Dictionary = {}
## Combat request filled by Zone before changing scene
var combat_setup: Dictionary = {}
## After combat, Zone reads this
var combat_result: Dictionary = {}
var return_to_zone: bool = false

## Online PVP (Fallen Game Server)
var pvp_active: bool = false
var pvp_room_code: String = ""
var pvp_display_name: String = "Tactician"

var hero_card_ids: Array[String]:
	get:
		if party.is_empty():
			return []
		return party[0].get("card_ids", [])
	set(v):
		if party.is_empty():
			return
		party[0]["card_ids"] = v


func start_new_run() -> void:
	run_active = true
	relic_ids.clear()
	encounter_index = 0
	last_combat_won = false
	combat_setup.clear()
	combat_result.clear()
	return_to_zone = false
	party.clear()
	for class_id in _ClassLibrary.default_party_ids():
		party.append(_make_hero_state(class_id))
	zone = _generate_zone()


func _make_hero_state(class_id: String) -> Dictionary:
	var def: Dictionary = _ClassLibrary.get_def(class_id)
	var cards: Array[String] = []
	for c in def.get("deck_ids", []):
		cards.append(str(c))
	return {
		"class_id": str(def.get("id", class_id)),
		"display_name": str(def.get("display_name", class_id)),
		"max_hp": int(def.get("max_hp", 30)),
		"max_energy": int(def.get("max_energy", 3)),
		"energy_regen": int(def.get("energy_regen", 3)),
		"base_initiative": int(def.get("base_initiative", 10)),
		"color": def.get("color", Color.WHITE),
		"starting_stance": str(def.get("starting_stance", "balance")),
		"card_ids": cards,
		"level": 1,
	}


func add_card_reward(card_id: String, hero_index: int = 0) -> void:
	if hero_index < 0 or hero_index >= party.size():
		hero_index = 0
	if party.is_empty():
		return
	var cards: Array = party[hero_index].get("card_ids", [])
	cards.append(card_id)
	party[hero_index]["card_ids"] = cards


func next_encounter() -> String:
	## Linear combat scenarios (single mode — no zone).
	match encounter_index:
		0:
			return "encounter_01"
		1:
			return "encounter_02"
		_:
			return "encounter_boss"


func party_count() -> int:
	return party.size()


func _generate_zone() -> Dictionary:
	## Procedural-ish fixed seed layout for VS region.
	var enemies: Array = [
		{"id": "e1", "kind": "goblin", "cell": Vector2i(5, 3), "alive": true, "encounter": "encounter_01", "patrol": [Vector2i(5, 3), Vector2i(6, 3), Vector2i(6, 4), Vector2i(5, 4)]},
		{"id": "e2", "kind": "orc", "cell": Vector2i(9, 6), "alive": true, "encounter": "encounter_01", "patrol": [Vector2i(9, 6), Vector2i(10, 6), Vector2i(10, 7), Vector2i(9, 7)]},
		{"id": "e3", "kind": "archer", "cell": Vector2i(12, 2), "alive": true, "encounter": "encounter_02", "patrol": [Vector2i(12, 2), Vector2i(13, 2), Vector2i(13, 3)]},
		{"id": "e4", "kind": "goblin", "cell": Vector2i(8, 9), "alive": true, "encounter": "encounter_02", "patrol": [Vector2i(8, 9), Vector2i(9, 9), Vector2i(9, 10), Vector2i(8, 10)]},
		{"id": "boss", "kind": "captain", "cell": Vector2i(14, 5), "alive": true, "encounter": "encounter_boss", "patrol": [Vector2i(14, 5), Vector2i(14, 6)]},
	]
	var pois: Array = [
		{"id": "ruin1", "kind": "ruin", "cell": Vector2i(3, 8), "used": false},
		{"id": "altar1", "kind": "altar", "cell": Vector2i(7, 4), "used": false},
		{"id": "camp1", "kind": "camp", "cell": Vector2i(11, 8), "used": false},
	]
	return {
		"width": 16,
		"height": 12,
		"party_cell": Vector2i(1, 5),
		"move_points": 4,
		"move_max": 4,
		"vision_range": 4,
		"explored": [], # list of "x,y" strings, filled by ZoneMap
		"enemies": enemies,
		"pois": pois,
		"kills": 0,
		"boss_unlocked": false,
		"exit_reached": false,
		"log": [],
		"initialized": true,
	}


func begin_combat_from_zone(setup: Dictionary) -> void:
	combat_setup = setup.duplicate(true)
	combat_result.clear()
	return_to_zone = true
	get_tree().change_scene_to_file(COMBAT_SCENE)


func finish_combat(won: bool) -> void:
	last_combat_won = won
	combat_result = {
		"won": won,
		"enemy_map_id": str(combat_setup.get("enemy_map_id", "")),
		"encounter_id": str(combat_setup.get("encounter_id", "")),
	}
	if won:
		mutter_coins += 5
		encounter_index += 1
		var eid := str(combat_setup.get("enemy_map_id", ""))
		if zone.has("enemies"):
			for e in zone["enemies"]:
				if str(e.get("id", "")) == eid:
					e["alive"] = false
					zone["kills"] = int(zone.get("kills", 0)) + 1
		if int(zone.get("kills", 0)) >= 2:
			zone["boss_unlocked"] = true
	else:
		run_active = false
	combat_setup.clear()
	if return_to_zone and run_active:
		get_tree().change_scene_to_file(ZONE_SCENE)
	elif not run_active:
		# stay / reload zone will show defeat — or restart
		get_tree().change_scene_to_file(ZONE_SCENE)


func go_to_zone() -> void:
	if not run_active:
		start_new_run()
	get_tree().change_scene_to_file(ZONE_SCENE)


func go_to_menu() -> void:
	pvp_active = false
	get_tree().change_scene_to_file(MENU_SCENE)

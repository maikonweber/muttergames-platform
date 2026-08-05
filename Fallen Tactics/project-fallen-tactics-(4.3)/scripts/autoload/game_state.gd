extends Node
## Run-level state between combats (VS: minimal).

var run_active: bool = false
var hero_level: int = 1
var hero_card_ids: Array[String] = []
var relic_ids: Array[String] = []
var encounter_index: int = 0
var last_combat_won: bool = false

const STARTER_DECK: Array[String] = [
	"passo_combate", "passo_combate",
	"golpe", "golpe", "golpe",
	"estocada",
	"parry",
	"guarda_alta",
	"finta",
	"pressao",
	"giro",
	"sprint",
]


func start_new_run() -> void:
	run_active = true
	hero_level = 1
	hero_card_ids = STARTER_DECK.duplicate()
	relic_ids.clear()
	encounter_index = 0
	last_combat_won = false


func add_card_reward(card_id: String) -> void:
	hero_card_ids.append(card_id)


func next_encounter() -> String:
	# 0 tutorial, 1 elite mix, 2 boss
	match encounter_index:
		0:
			return "encounter_01"
		1:
			return "encounter_02"
		_:
			return "encounter_boss"

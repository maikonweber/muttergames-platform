class_name ChallengeData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var theme: String = ""
@export var briefing: String = ""
@export var model_id: String = "model_01"
@export var background_index: int = 1
@export var recommended_cosmetic_ids: Array[String] = []
@export var coin_reward: int = 30
@export var star_thresholds: Array[int] = [1, 2, 3]
@export var mandatory_objectives: Array[Dictionary] = []
@export var optional_objectives: Array[Dictionary] = []


func all_objectives() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item in mandatory_objectives:
		out.append(item)
	for item in optional_objectives:
		out.append(item)
	return out

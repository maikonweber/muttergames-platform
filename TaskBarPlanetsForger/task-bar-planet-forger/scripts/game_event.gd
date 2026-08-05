class_name CosmicEvent
extends RefCounted

var id: String
var title: String
var description: String
var category: String
var choices: Array[Dictionary]

func _init(p_id := "", p_title := "", p_description := "", p_category := "", p_choices: Array[Dictionary] = []) -> void:
	id = p_id
	title = p_title
	description = p_description
	category = p_category
	choices = p_choices

static func random_event(planets: Array[Planet], generator: RandomNumberGenerator = null) -> CosmicEvent:
	var candidates: Array[CosmicEvent] = [
		CosmicEvent.new("meteor", "Chuva de meteoros", "Fragmentos ricos atravessam o sistema.", "positivo", [{"label": "Coletar", "effect": {"Materia": 30.0}}, {"label": "Canalizar", "effect": {"Energia": 18.0}}]),
		CosmicEvent.new("aurora", "Aurora energetica", "A estrela libera uma onda de energia estavel.", "positivo", [{"label": "Absorver", "effect": {"Energia": 45.0}}]),
		CosmicEvent.new("drought", "Seca orbital", "As reservas de agua evaporam mais rapido.", "negativo", [{"label": "Proteger", "effect": {"Energia": -12.0, "Agua": 10.0}}, {"label": "Aceitar", "effect": {"Agua": -15.0}}]),
	]
	if not planets.is_empty():
		candidates.append(CosmicEvent.new("rain", "Nuvens cometarias", "Um cometa oferece agua ao planeta mais jovem.", "neutro", [{"label": "Capturar", "effect": {"Agua": 28.0}}]))
	if generator == null:
		return candidates[randi_range(0, candidates.size() - 1)]
	return candidates[generator.randi_range(0, candidates.size() - 1)]

func serialize() -> Dictionary:
	return {"id": id, "title": title, "description": description, "category": category, "choices": choices}

static func from_data(data: Dictionary) -> CosmicEvent:
	var raw_choices: Array = data.get("choices", []) as Array
	var choices: Array[Dictionary] = []
	for choice in raw_choices:
		if choice is Dictionary:
			choices.append(choice as Dictionary)
	return CosmicEvent.new(
		str(data.get("id", "")),
		str(data.get("title", "")),
		str(data.get("description", "")),
		str(data.get("category", "")),
		choices,
	)

class_name Planet
extends RefCounted

var id: String
var orbit: int
var type: String = "Rochoso"
var rarity: String = "Comum"
var temperature: float = 18.0
var atmosphere: float = 0.0
var water: float = 0.0
var life: bool = false
var civilization: bool = false
var age: float = 0.0
## A aparência procedural é reproduzível a partir desta seed e não depende do id do save.
var visual_seed: int = 0
var generator_version: int = 1

func _init(p_orbit: int = 0, generator: RandomNumberGenerator = null) -> void:
	id = str(Time.get_ticks_usec()) + "-" + str(randi())
	orbit = p_orbit
	if generator == null:
		temperature = [4.0, 18.0, 29.0].pick_random()
		rarity = ["Comum", "Incomum", "Raro"].pick_random()
		visual_seed = randi()
	else:
		temperature = [4.0, 18.0, 29.0][generator.randi_range(0, 2)]
		rarity = ["Comum", "Incomum", "Raro"][generator.randi_range(0, 2)]
		visual_seed = generator.randi()

func is_habitable() -> bool:
	return type in ["Rochoso", "Oceanico"] and atmosphere >= 50.0 and water >= 40.0 and temperature >= 0.0 and temperature <= 35.0

func evolve(delta: float, inventory: ResourceInventory) -> void:
	age += delta
	var rates := production_rates()
	for resource in rates:
		inventory.add(resource, float(rates[resource]) * delta)

func production_rates() -> Dictionary:
	var rates := {"Biomassa": 0.0, "Conhecimento": 0.0}
	if life:
		rates["Biomassa"] = 0.35
	if civilization:
		rates["Conhecimento"] = 0.18
	return rates

func stage_name() -> String:
	if civilization: return "Civilizacao"
	if life: return "Vida"
	if is_habitable(): return "Habitavel"
	return "Em formacao"

func serialize() -> Dictionary:
	return {"id": id, "orbit": orbit, "type": type, "rarity": rarity, "temperature": temperature, "atmosphere": atmosphere, "water": water, "life": life, "civilization": civilization, "age": age, "visual_seed": visual_seed, "generator_version": generator_version}

static func from_data(data: Dictionary) -> Planet:
	var planet := Planet.new(int(data.get("orbit", 0)))
	planet.id = str(data.get("id", planet.id))
	planet.type = str(data.get("type", "Rochoso"))
	planet.rarity = str(data.get("rarity", "Comum"))
	planet.temperature = float(data.get("temperature", 18.0))
	planet.atmosphere = float(data.get("atmosphere", 0.0))
	planet.water = float(data.get("water", 0.0))
	planet.life = bool(data.get("life", false))
	planet.civilization = bool(data.get("civilization", false))
	planet.age = float(data.get("age", 0.0))
	planet.visual_seed = int(data.get("visual_seed", planet.visual_seed))
	planet.generator_version = int(data.get("generator_version", 1))
	return planet

extends RefCounted

## Teste de domínio sem cena: pode ser chamado por um runner Godot ou GUT no futuro.
## Mantém a taxa exibida pela UI alinhada às regras de planeta.
static func run() -> void:
	var inventory := ResourceInventory.new()
	var planet := Planet.new(0)
	planet.life = true
	planet.civilization = true
	var before_biomass := float(inventory.amounts["Biomassa"])
	var before_knowledge := float(inventory.amounts["Conhecimento"])
	planet.evolve(10.0, inventory)
	assert(is_equal_approx(float(inventory.amounts["Biomassa"]) - before_biomass, 3.5))
	assert(is_equal_approx(float(inventory.amounts["Conhecimento"]) - before_knowledge, 1.8))
	assert(planet.production_rates()["Biomassa"] == 0.35)
	assert(planet.production_rates()["Conhecimento"] == 0.18)
	var missing := inventory.missing_resources({"Materia": 90.0, "Energia": 10.0})
	assert(is_equal_approx(float(missing["Materia"]), 20.0))
	assert(not missing.has("Energia"))

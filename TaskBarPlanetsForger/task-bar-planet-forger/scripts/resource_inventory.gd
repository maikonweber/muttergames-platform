class_name ResourceInventory
extends RefCounted

const RESOURCE_NAMES := ["Materia", "Energia", "Agua", "Biomassa", "Conhecimento", "Essencia"]

var amounts: Dictionary = {
	"Materia": 70.0, "Energia": 30.0, "Agua": 0.0,
	"Biomassa": 0.0, "Conhecimento": 0.0, "Essencia": 0.0,
}
var capacities: Dictionary = {
	"Materia": 500.0, "Energia": 300.0, "Agua": 200.0,
	"Biomassa": 200.0, "Conhecimento": 150.0, "Essencia": 999999.0,
}

func add(resource: String, value: float) -> float:
	if not amounts.has(resource):
		return 0.0
	var accepted := minf(value, float(capacities[resource]) - float(amounts[resource]))
	amounts[resource] += maxf(0.0, accepted)
	return accepted

func apply_delta(resource: String, value: float) -> float:
	if value >= 0.0:
		return add(resource, value)
	if not amounts.has(resource):
		return 0.0
	var removed := minf(-value, float(amounts[resource]))
	amounts[resource] -= removed
	return -removed

func can_pay(cost: Dictionary) -> bool:
	for resource in cost:
		if float(amounts.get(resource, 0.0)) < float(cost[resource]):
			return false
	return true

func pay(cost: Dictionary) -> bool:
	if not can_pay(cost):
		return false
	for resource in cost:
		amounts[resource] -= float(cost[resource])
	return true

func serialize() -> Dictionary:
	return {"amounts": amounts, "capacities": capacities}

func deserialize(data: Dictionary) -> void:
	amounts.merge(data.get("amounts", {}) as Dictionary, true)
	capacities.merge(data.get("capacities", {}) as Dictionary, true)

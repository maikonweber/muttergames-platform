class_name TutorialState
extends RefCounted

const STEPS := [
	"Crie dois asteroides com Matéria.",
	"Forje um planeta numa órbita vazia.",
	"Terraforme-o até torná-lo habitável.",
	"Inicie vida e observe a Biomassa crescer.",
	"Evolua uma civilização e produza Conhecimento.",
	"Preencha as órbitas para desbloquear a Supernova.",
]

var current_step := 0
var dismissed := false

func complete_current() -> void:
	if not dismissed:
		current_step = mini(current_step + 1, STEPS.size())

func is_complete() -> bool:
	return current_step >= STEPS.size()

func current_text() -> String:
	if dismissed or is_complete(): return "Tutorial concluído — explore o sistema livremente."
	return "Passo %d/%d: %s" % [current_step + 1, STEPS.size(), STEPS[current_step]]

func serialize() -> Dictionary:
	return {"current_step": current_step, "dismissed": dismissed}

func deserialize(data: Dictionary) -> void:
	current_step = clampi(int(data.get("current_step", 0)), 0, STEPS.size())
	dismissed = bool(data.get("dismissed", false))

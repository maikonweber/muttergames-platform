class_name ScoringService
extends RefCounted

const COVERAGE_MIN := 0.12
const COLOR_DISTANCE_MAX := 0.48


func evaluate(challenge: ChallengeData, session: MakeupSession) -> Dictionary:
	var result := {
		"challenge_id": challenge.id if challenge else "",
		"stars": 0,
		"coins": 0,
		"objectives": [],
		"coverage": {},
		"note": "O que vale é o que você pintou — o rostinho já é lindo.",
	}
	if challenge == null or session == null:
		return result
	for category in MakeupSession.LAYER_CATEGORIES:
		result["coverage"][category] = session.coverage(category)
	var mandatory_met := 0
	var mandatory_total := challenge.mandatory_objectives.size()
	var optional_met := 0
	var rows: Array = []
	for objective in challenge.mandatory_objectives:
		var row := _score_objective(objective, challenge, session, true)
		if row["met"]:
			mandatory_met += 1
		rows.append(row)
	for objective in challenge.optional_objectives:
		var row := _score_objective(objective, challenge, session, false)
		if row["met"]:
			optional_met += 1
		rows.append(row)
	result["objectives"] = rows
	var stars := 0
	if mandatory_total <= 0:
		stars = 1 if optional_met > 0 else 0
	elif mandatory_met > 0:
		stars = 1
		if mandatory_met >= mandatory_total:
			stars = 2
			if optional_met >= challenge.optional_objectives.size() and optional_met > 0:
				stars = 3
			elif challenge.optional_objectives.is_empty():
				stars = 3
	result["stars"] = stars
	var coins := 0
	if stars > 0:
		coins = int(round(float(challenge.coin_reward) * float(stars) / 3.0))
	elif _tried_anything(result["coverage"]):
		coins = 5
	result["coins"] = coins
	return result


func _score_objective(objective: Dictionary, challenge: ChallengeData, session: MakeupSession, mandatory: bool) -> Dictionary:
	var kind := String(objective.get("type", "coverage"))
	var category := String(objective.get("category", "lipstick"))
	var label := String(objective.get("label", category))
	var met := false
	var detail := ""
	match kind:
		"coverage":
			var amount: float = session.coverage(category)
			var minimum := float(objective.get("min_coverage", COVERAGE_MIN))
			met = amount >= minimum
			detail = "%d%% da região" % int(round(amount * 100.0))
		"recommended_color":
			var cosmetic_id := String(objective.get("cosmetic_id", ""))
			if cosmetic_id.is_empty() and not challenge.recommended_cosmetic_ids.is_empty():
				cosmetic_id = challenge.recommended_cosmetic_ids[0]
			var cosmetic: CosmeticData = ContentLibrary.get_cosmetic(cosmetic_id)
			var coverage_amount: float = session.coverage(category)
			if cosmetic and coverage_amount >= COVERAGE_MIN:
				var distance := _color_distance(session.average_color(category), cosmetic.color)
				met = distance <= COLOR_DISTANCE_MAX
				detail = "perto de %s" % cosmetic.display_name if met else "outra cor — ok, só não ganha o bônus"
			else:
				detail = "aplique a categoria para o bônus"
		_:
			detail = "objetivo desconhecido"
	return {
		"id": String(objective.get("id", kind)),
		"label": label,
		"met": met,
		"mandatory": mandatory,
		"detail": detail,
	}


func _tried_anything(coverage: Dictionary) -> bool:
	for key in coverage.keys():
		if float(coverage[key]) >= 0.04:
			return true
	return false


func _color_distance(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)

extends SceneTree

func _initialize() -> void:
	var failures := 0
	var library = load("res://scripts/data/content_library.gd").new()
	root.add_child(library)
	var model: ModelData = library.get_model("model_01")
	if model == null or model.face_base == null or model.mask_lips == null:
		push_error("smoke: model_01 não carregou")
		failures += 1
	var session := MakeupSession.new()
	session.load_model(model)
	var painted := session.stamp("lipstick", Vector2i(511, 783), 18, Color(0.8, 0.1, 0.2), 0.9, false)
	if not painted:
		push_error("smoke: stamp nos lábios não pintou")
		failures += 1
	var missed := session.stamp("lipstick", Vector2i(8, 8), 12, Color(0.8, 0.1, 0.2), 0.9, false)
	if missed:
		push_error("smoke: stamp fora da máscara pintou")
		failures += 1
	var challenge = library.default_challenge()
	if challenge == null or challenge.id != "challenge_gala_01":
		push_error("smoke: desafio de gala ausente")
		failures += 1
	var scoring = load("res://scripts/challenge/scoring_service.gd").new()
	session.apply_pilot_look()
	var result = scoring.evaluate(challenge, session)
	if int(result.get("stars", 0)) < 2:
		push_error("smoke: look piloto deveria cumprir os objetivos obrigatórios")
		failures += 1
	for model_id in library.model_ids():
		var other: ModelData = library.get_model(model_id)
		if other == null or other.face_base == null:
			push_error("smoke: falha ao carregar %s" % model_id)
			failures += 1
	if library.get_accessories().size() != 12:
		push_error("smoke: esperava 12 acessórios")
		failures += 1
	session.apply_mask_fill("eyeliner", Color(0.05, 0.04, 0.05), 0.9, 8)
	if session.coverage("eyeliner") < 0.2:
		push_error("smoke: delineador não preencheu a máscara")
		failures += 1
	var lashes = library.get_cosmetic("mascara_volumizing")
	if lashes == null:
		push_error("smoke: estilo de cílios ausente")
		failures += 1
	elif not session.apply_lashes(lashes) or not session.has_paint("mascara"):
		push_error("smoke: cílios não foram aplicados")
		failures += 1
	var earring = library.get_accessory("pearl_drop_earrings")
	if earring == null:
		push_error("smoke: brinco ausente")
		failures += 1
	else:
		session.toggle_accessory(earring)
		if session.equipped.get("ears", "") != "pearl_drop_earrings":
			push_error("smoke: acessório não equipou")
			failures += 1
		if not session.landmarks.has("ear_l") or not session.landmarks.has("bridge"):
			push_error("smoke: âncoras do rosto ausentes")
			failures += 1
	if library.background_count() != 6:
		push_error("smoke: esperava 6 fundos")
		failures += 1
	if failures == 0:
		print("LIRA_SMOKE_OK")
		quit(0)
	else:
		print("LIRA_SMOKE_FAIL %d" % failures)
		quit(1)

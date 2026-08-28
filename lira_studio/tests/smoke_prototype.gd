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
	var on_face := session.stamp("lipstick", Vector2i(512, 520), 18, Color(0.8, 0.1, 0.2), 0.9, false)
	if not on_face:
		push_error("smoke: stamp no rosto deveria pintar sem máscara da boca")
		failures += 1
	var missed := session.stamp("lipstick", Vector2i(8, 8), 12, Color(0.8, 0.1, 0.2), 0.9, false)
	if missed:
		push_error("smoke: stamp fora da personagem pintou")
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
		elif other.mask_skin == null:
			push_error("smoke: máscara de pele ausente em %s" % model_id)
			failures += 1
		else:
			var skin := other.mask_skin.get_image()
			if skin.get_pixel(512, 700).a < 0.8 or skin.get_pixel(12, 12).a > 0.05 or skin.get_pixel(512, 120).a > 0.05:
				push_error("smoke: máscara de pele invade cabelo ou cenário em %s" % model_id)
				failures += 1
	if library.get_accessories().size() != 12:
		push_error("smoke: esperava 12 acessórios")
		failures += 1
	session.apply_mask_fill("eyeliner", Color(0.05, 0.04, 0.05), 0.9, 8)
	if session.coverage("eyeliner") < 0.2:
		push_error("smoke: delineador não preencheu a máscara")
		failures += 1
	if library.get_cosmetics("lipstick").size() < 7:
		push_error("smoke: paleta de batom curta demais")
		failures += 1
	if library.get_cosmetics("eyeshadow").size() < 7:
		push_error("smoke: paleta de sombra curta demais")
		failures += 1
	if library.get_cosmetics("eyeliner").size() < 7:
		push_error("smoke: paleta de lápis curta demais")
		failures += 1
	if library.tint_swatches("mascara").size() < 6:
		push_error("smoke: cores de cílios ausentes")
		failures += 1
	var lashes = library.get_cosmetic("mascara_volumizing")
	if lashes == null:
		push_error("smoke: estilo de cílios ausente")
		failures += 1
	elif not session.apply_lashes(lashes, 24) or not session.has_paint("mascara"):
		push_error("smoke: cílios não foram aplicados")
		failures += 1
	else:
		var natural = library.get_cosmetic("mascara_natural_defined")
		var fan = library.get_cosmetic("mascara_dramatic_fan")
		session.apply_lashes(natural, 24)
		var natural_box := session.layer_bbox("mascara")
		session.apply_lashes(fan, 24)
		var fan_box := session.layer_bbox("mascara")
		if natural_box.size.y < 24 or fan_box.size.y < 24:
			push_error("smoke: cílios saíram como barra fina")
			failures += 1
		if fan_box.size.y < int(round(float(natural_box.size.y) * 1.2)):
			push_error("smoke: estilo leque deveria ser mais alto que o natural")
			failures += 1
		if fan_box.size.y > 280:
			push_error("smoke: cílios cobriram demais o rosto")
			failures += 1
		session.apply_lashes(fan, 48, Color(0.82, 0.28, 0.48), 1.0)
		var pink := session.average_color("mascara", false)
		if pink.r < 0.45 or pink.g > pink.r:
			push_error("smoke: cílios não receberam a cor escolhida")
			failures += 1
	var entitlements := Entitlements.new()
	var coral = library.get_cosmetic("lipstick_coral")
	var ruby = library.get_cosmetic("lipstick_ruby")
	var extra_doll: ModelData = library.get_model("model_03")
	var free_doll: ModelData = library.get_model("model_01")
	if coral == null or not coral.extra_pack:
		push_error("smoke: batom extra não marcado para o pacote")
		failures += 1
	if ruby == null or ruby.extra_pack:
		push_error("smoke: batom free ficou atrás do pacote")
		failures += 1
	if extra_doll == null or not extra_doll.extra_pack:
		push_error("smoke: boneca extra não marcada para o pacote")
		failures += 1
	if free_doll == null or free_doll.extra_pack:
		push_error("smoke: boneca free ficou atrás do pacote")
		failures += 1
	if entitlements.owns_extra_pack() or entitlements.can_use_cosmetic(coral):
		push_error("smoke: pacote extra veio liberado sem compra")
		failures += 1
	if not entitlements.can_use_cosmetic(ruby) or not entitlements.can_use_model(free_doll):
		push_error("smoke: conteúdo free ficou bloqueado")
		failures += 1
	entitlements.grant(ExtraPack.SKU)
	if not entitlements.can_use_cosmetic(coral) or not entitlements.can_use_model(extra_doll):
		push_error("smoke: compra do pacote não liberou extra")
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

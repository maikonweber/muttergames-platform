extends Node

const LAYER_ORDER: Array[String] = ["foundation", "blush", "eyeshadow", "lipstick"]

const _MODEL_DEFS := {
	"model_01": {
		"display_name": "Modelo 01",
		"overlays": {
			"foundation": "foundation_warm_natural",
			"blush": "blush_rose_soft",
			"eyeshadow": "eyeshadow_champagne_pearl",
			"lipstick": "lipstick_ruby_gloss",
		},
	},
	"model_02": {
		"display_name": "Modelo 02",
		"overlays": {
			"foundation": "foundation_deep_natural",
			"blush": "blush_berry_soft",
			"eyeshadow": "eyeshadow_copper_satin",
			"lipstick": "lipstick_plum_gloss",
		},
	},
	"model_03": {
		"display_name": "Modelo 03",
		"extra_pack": true,
		"overlays": {
			"foundation": "foundation_olive_natural",
			"blush": "blush_coral_soft",
			"eyeshadow": "eyeshadow_bronze_satin",
			"lipstick": "lipstick_terracotta_gloss",
		},
	},
	"model_04": {
		"display_name": "Modelo 04",
		"extra_pack": true,
		"overlays": {
			"foundation": "foundation_peach_natural",
			"blush": "blush_peach_soft",
			"eyeshadow": "eyeshadow_rose_gold_pearl",
			"lipstick": "lipstick_berry_gloss",
		},
	},
}

const _BACKGROUND_PATHS: Array[String] = [
	"res://assets/backgrounds/background_daily_01_v1.png",
	"res://assets/backgrounds/background_gala_01_v1.png",
	"res://assets/backgrounds/background_festival_01_v1.png",
	"res://assets/backgrounds/background_fantasy_01_v1.png",
	"res://assets/backgrounds/background_urban_editorial_01_v1.png",
	"res://assets/backgrounds/background_romantic_garden_01_v1.png",
]

var _models: Dictionary = {}
var _model_ids: Array[String] = []
var _thumbs: Dictionary = {}
var _backgrounds: Dictionary = {}
var _cosmetics: Array[CosmeticData] = []
var _cosmetic_by_id: Dictionary = {}
var _cosmetics_by_category: Dictionary = {}
var _challenges: Dictionary = {}
var _accessories: Array[AccessoryData] = []
var _accessory_by_id: Dictionary = {}


func _ready() -> void:
	_ensure_catalog()


func _ensure_catalog() -> void:
	if _cosmetics.is_empty():
		_cosmetics = _build_cosmetics()
		_index_cosmetics()
	if _challenges.is_empty():
		_challenges = _build_challenges()
	if _accessories.is_empty():
		_accessories = _build_accessories()
		_index_accessories()
	if _model_ids.is_empty():
		for key in _MODEL_DEFS.keys():
			_model_ids.append(String(key))
		_model_ids.sort()


func _index_cosmetics() -> void:
	_cosmetic_by_id.clear()
	_cosmetics_by_category.clear()
	for item in _cosmetics:
		_cosmetic_by_id[item.id] = item
		if not _cosmetics_by_category.has(item.category):
			var grouped: Array[CosmeticData] = []
			_cosmetics_by_category[item.category] = grouped
		(_cosmetics_by_category[item.category] as Array).append(item)


func _index_accessories() -> void:
	_accessory_by_id.clear()
	for item in _accessories:
		_accessory_by_id[item.id] = item


func model_ids() -> Array[String]:
	_ensure_catalog()
	return _model_ids


func is_extra_model(model_id: String) -> bool:
	return bool(_MODEL_DEFS.get(model_id, {}).get("extra_pack", false))


func get_model_thumb(model_id: String) -> Texture2D:
	if _thumbs.has(model_id):
		return _thumbs[model_id]
	if not _MODEL_DEFS.has(model_id):
		return null
	var thumb := _tex("%s/thumbnails/%s_thumb_v2.png" % [model_id, model_id])
	_thumbs[model_id] = thumb
	return thumb


func get_model(model_id: String) -> ModelData:
	if not _MODEL_DEFS.has(model_id):
		push_error("Modelo desconhecido: %s" % model_id)
		return null
	if not _models.has(model_id):
		_models[model_id] = _make_model(model_id)
	return _models[model_id]


func get_cosmetic(cosmetic_id: String) -> CosmeticData:
	_ensure_catalog()
	return _cosmetic_by_id.get(cosmetic_id, null) as CosmeticData


func get_cosmetics(category: String) -> Array[CosmeticData]:
	_ensure_catalog()
	var cached: Array = _cosmetics_by_category.get(category, [])
	var out: Array[CosmeticData] = []
	out.assign(cached)
	return out


func tint_swatches(category: String) -> Array[Dictionary]:
	if category != "mascara":
		return []
	return [
		{"display_name": "Preto", "color": Color(0.08, 0.05, 0.05), "extra_pack": false},
		{"display_name": "Marrom", "color": Color(0.32, 0.16, 0.09), "extra_pack": false},
		{"display_name": "Marinho", "color": Color(0.12, 0.18, 0.42), "extra_pack": true},
		{"display_name": "Roxo", "color": Color(0.36, 0.12, 0.40), "extra_pack": true},
		{"display_name": "Dourado", "color": Color(0.80, 0.58, 0.18), "extra_pack": true},
		{"display_name": "Rosa", "color": Color(0.82, 0.28, 0.48), "extra_pack": true},
		{"display_name": "Verde", "color": Color(0.12, 0.40, 0.24), "extra_pack": true},
		{"display_name": "Prata", "color": Color(0.74, 0.76, 0.80), "extra_pack": true},
	]


func default_challenge() -> ChallengeData:
	return get_challenge("challenge_gala_01")


func get_challenge(challenge_id: String) -> ChallengeData:
	_ensure_catalog()
	return _challenges.get(challenge_id, null)


func background_count() -> int:
	return _BACKGROUND_PATHS.size()


func get_background(index: int) -> Texture2D:
	if _BACKGROUND_PATHS.is_empty():
		return null
	var wrapped := posmod(index, _BACKGROUND_PATHS.size())
	if _backgrounds.has(wrapped):
		return _backgrounds[wrapped]
	var texture := load(_BACKGROUND_PATHS[wrapped]) as Texture2D
	_backgrounds[wrapped] = texture
	return texture


func _make_model(model_id: String) -> ModelData:
	var def: Dictionary = _MODEL_DEFS[model_id]
	var overlays: Dictionary = def["overlays"]
	var data := ModelData.new()
	data.id = model_id
	data.display_name = String(def["display_name"])
	# Todos os retratos e perfis usam a mesma revisao: v2 remove franja
	# cromatica das bordas e impede que a miniatura fique defasada da modelo.
	var face_version := "%s_face_base_v2.png" % model_id
	data.face_base = _tex("%s/base/%s" % [model_id, face_version])
	# A base do rosto já contém o cabelo final. As camadas técnicas atuais não
	# respeitam a mesma composição e ficavam sobre o rosto no runtime.
	data.hair_back = null
	data.hair_front = null
	data.thumb = get_model_thumb(model_id)
	data.smile = _tex("%s/expressions/%s_expression_smile_v1.png" % [model_id, model_id])
	data.mask_skin = _tex("%s/masks/%s_skin_mask.png" % [model_id, model_id])
	data.mask_lips = _tex("%s/masks/%s_lips_mask.png" % [model_id, model_id])
	data.mask_eye_l = _tex("%s/masks/%s_eye_l_mask.png" % [model_id, model_id])
	data.mask_eye_r = _tex("%s/masks/%s_eye_r_mask.png" % [model_id, model_id])
	data.mask_cheek_l = _tex("%s/masks/%s_cheek_l_mask.png" % [model_id, model_id])
	data.mask_cheek_r = _tex("%s/masks/%s_cheek_r_mask.png" % [model_id, model_id])
	data.mask_lash_l = _tex("%s/masks/%s_lash_l_mask.png" % [model_id, model_id])
	data.mask_lash_r = _tex("%s/masks/%s_lash_r_mask.png" % [model_id, model_id])
	data.overlay_foundation = _overlay_tex(model_id, "foundation", String(overlays["foundation"]))
	data.overlay_blush = _overlay_tex(model_id, "blush", String(overlays["blush"]))
	data.overlay_eyeshadow = _overlay_tex(model_id, "eyeshadow", String(overlays["eyeshadow"]))
	data.overlay_lipstick = _overlay_tex(model_id, "lipstick", String(overlays["lipstick"]))
	data.extra_pack = bool(def.get("extra_pack", false))
	return data


func _tex(rel: String) -> Texture2D:
	var path := "res://assets/models/%s" % rel
	var loaded := load(path) as Texture2D
	# Na exportação Android, PNGs importados viram `.ctex`; o arquivo PNG bruto
	# não entra no APK. Portanto carregue o recurso antes de consultar o disco.
	if loaded != null:
		return loaded
	# No primeiro início do editor, uma sprite nova pode ainda não ter cache de
	# importação. O fallback mantém esse fluxo local funcionando.
	if FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null:
			return ImageTexture.create_from_image(image)
	push_warning("Não foi possível carregar: %s" % path)
	return null


func _overlay_tex(model_id: String, folder: String, stem: String) -> Texture2D:
	return _tex("%s/makeup/%s/%s_%s_overlay_v1.png" % [model_id, folder, model_id, stem])


func _build_cosmetics() -> Array[CosmeticData]:
	var items: Array[CosmeticData] = []
	items.append(_cosmetic("lipstick_ruby", "lipstick", "Vermelho", Color(0.77, 0.12, 0.23), "gloss", 0.52, "res://assets/cosmetics/swatches/swatch_ruby_lip_card_v1.png"))
	items.append(_cosmetic("lipstick_rose", "lipstick", "Rosa", Color(0.88, 0.48, 0.60), "satin", 0.48, "res://assets/cosmetics/swatches/swatch_rose_lip_card_v1.png"))
	items.append(_cosmetic("lipstick_plum", "lipstick", "Roxo", Color(0.42, 0.18, 0.36), "matte", 0.52, "res://assets/cosmetics/swatches/swatch_plum_lip_card_v1.png"))
	items.append(_cosmetic("lipstick_coral", "lipstick", "Coral", Color(0.92, 0.36, 0.32), "gloss", 0.5, "", true))
	items.append(_cosmetic("lipstick_nude", "lipstick", "Nude", Color(0.86, 0.58, 0.50), "satin", 0.48, "", true))
	items.append(_cosmetic("lipstick_fuchsia", "lipstick", "Fúcsia", Color(0.86, 0.12, 0.46), "gloss", 0.52, "", true))
	items.append(_cosmetic("lipstick_wine", "lipstick", "Vinho", Color(0.48, 0.08, 0.18), "matte", 0.55, "", true))
	items.append(_cosmetic("lipstick_peach", "lipstick", "Pêssego", Color(0.96, 0.62, 0.52), "satin", 0.46, "", true))
	items.append(_cosmetic("eyeshadow_champagne", "eyeshadow", "Dourado", Color(0.91, 0.79, 0.60), "pearl", 0.48, "res://assets/cosmetics/swatches/swatch_champagne_shadow_card_v1.png"))
	items.append(_cosmetic("eyeshadow_copper", "eyeshadow", "Bronze", Color(0.72, 0.45, 0.20), "satin", 0.48, "res://assets/cosmetics/swatches/swatch_copper_shadow_card_v1.png"))
	items.append(_cosmetic("eyeshadow_violet", "eyeshadow", "Lilás", Color(0.48, 0.29, 0.60), "pearl", 0.45, "res://assets/cosmetics/swatches/swatch_violet_shadow_card_v1.png"))
	items.append(_cosmetic("eyeshadow_pink", "eyeshadow", "Rosa", Color(0.92, 0.48, 0.62), "pearl", 0.46, "", true))
	items.append(_cosmetic("eyeshadow_blue", "eyeshadow", "Azul", Color(0.28, 0.46, 0.78), "satin", 0.46, "", true))
	items.append(_cosmetic("eyeshadow_green", "eyeshadow", "Verde", Color(0.22, 0.52, 0.36), "satin", 0.46, "", true))
	items.append(_cosmetic("eyeshadow_silver", "eyeshadow", "Prata", Color(0.78, 0.80, 0.84), "pearl", 0.5, "", true))
	items.append(_cosmetic("eyeshadow_brown", "eyeshadow", "Marrom", Color(0.42, 0.24, 0.16), "matte", 0.48, "", true))
	items.append(_cosmetic("foundation_warm", "foundation", "Quente", Color(0.89, 0.73, 0.58), "matte", 0.28))
	items.append(_cosmetic("foundation_deep", "foundation", "Intenso", Color(0.45, 0.28, 0.18), "matte", 0.28))
	items.append(_cosmetic("foundation_olive", "foundation", "Oliva", Color(0.70, 0.55, 0.38), "matte", 0.28))
	items.append(_cosmetic("foundation_peach", "foundation", "Pêssego", Color(0.93, 0.74, 0.62), "matte", 0.28))
	items.append(_cosmetic("foundation_fair", "foundation", "Claro", Color(0.96, 0.84, 0.74), "matte", 0.26, "", true))
	items.append(_cosmetic("foundation_tan", "foundation", "Bronzeado", Color(0.72, 0.48, 0.32), "matte", 0.28, "", true))
	items.append(_cosmetic("blush_rose", "blush", "Rosa", Color(0.90, 0.45, 0.52), "satin", 0.4))
	items.append(_cosmetic("blush_berry", "blush", "Berry", Color(0.72, 0.22, 0.38), "satin", 0.4))
	items.append(_cosmetic("blush_coral", "blush", "Coral", Color(0.93, 0.48, 0.40), "satin", 0.4))
	items.append(_cosmetic("blush_peach", "blush", "Pêssego", Color(0.95, 0.62, 0.55), "satin", 0.4))
	items.append(_cosmetic("blush_apricot", "blush", "Damasco", Color(0.94, 0.52, 0.38), "satin", 0.4, "", true))
	items.append(_cosmetic("blush_mauve", "blush", "Malva", Color(0.78, 0.38, 0.50), "satin", 0.4, "", true))
	items.append(_cosmetic("eyeliner_black", "eyeliner", "Preto", Color(0.07, 0.05, 0.06), "matte", 0.9))
	items.append(_cosmetic("eyeliner_brown", "eyeliner", "Marrom", Color(0.32, 0.16, 0.10), "matte", 0.88))
	items.append(_cosmetic("eyeliner_navy", "eyeliner", "Marinho", Color(0.10, 0.16, 0.38), "matte", 0.9, "", true))
	items.append(_cosmetic("eyeliner_green", "eyeliner", "Verde", Color(0.08, 0.32, 0.22), "matte", 0.88, "", true))
	items.append(_cosmetic("eyeliner_gold", "eyeliner", "Dourado", Color(0.82, 0.64, 0.22), "satin", 0.85, "", true))
	items.append(_cosmetic("eyeliner_white", "eyeliner", "Branco", Color(0.96, 0.94, 0.92), "matte", 0.9, "", true))
	items.append(_cosmetic("eyeliner_purple", "eyeliner", "Roxo", Color(0.38, 0.16, 0.48), "matte", 0.88, "", true))
	items.append(_cosmetic("eyeliner_pink", "eyeliner", "Rosa", Color(0.86, 0.32, 0.52), "matte", 0.86, "", true))
	items.append(_style("mascara_natural_defined", "mascara", "Natural", Color(0.10, 0.06, 0.05), 0, 0.92, 3, "mascara"))
	items.append(_style("mascara_lengthening", "mascara", "Longos", Color(0.07, 0.04, 0.04), 1, 0.94, 4, "mascara"))
	items.append(_style("mascara_volumizing", "mascara", "Cheios", Color(0.06, 0.03, 0.03), 2, 0.96, 5, "mascara", true))
	items.append(_style("mascara_dramatic_fan", "mascara", "Leque", Color(0.05, 0.02, 0.03), 3, 0.98, 6, "mascara", true))
	return items


func _cosmetic(
		id: String,
		category: String,
		display_name: String,
		color: Color,
		finish: String,
		intensity: float,
		swatch_path: String = "",
		extra_pack: bool = false
	) -> CosmeticData:
	var data := CosmeticData.new()
	data.id = id
	data.category = category
	data.display_name = display_name
	data.color = color
	data.finish = finish
	data.default_intensity = intensity
	data.extra_pack = extra_pack
	if not swatch_path.is_empty():
		data.thumbnail = load(swatch_path) as Texture2D
	return data


func _style(
		id: String,
		category: String,
		display_name: String,
		color: Color,
		atlas_index: int,
		intensity: float,
		dilate: int,
		kind: String = "eyeliner",
		extra_pack: bool = false
	) -> CosmeticData:
	var data := _cosmetic(id, category, display_name, color, "matte", intensity, "", extra_pack)
	data.dilate_px = dilate
	data.atlas_index = atlas_index
	if kind == "mascara":
		data.apply_mode = "sprite"
		data.thumbnail = _atlas_cell("res://assets/cosmetics/mascara/mascara_style_atlas_v1.png", 2, 2, atlas_index)
	else:
		data.apply_mode = "paint"
		data.thumbnail = _atlas_cell("res://assets/cosmetics/eyeliner/eyeliner_style_atlas_v1.png", 3, 2, atlas_index)
	return data


func _atlas_cell(path: String, cols: int, rows: int, index: int) -> AtlasTexture:
	var sheet := load(path) as Texture2D
	if sheet == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var cell := Vector2(sheet.get_width() / float(cols), sheet.get_height() / float(rows))
	var col := index % cols
	var row := int(index / cols)
	var inset := cell * 0.08
	atlas.region = Rect2(Vector2(col, row) * cell + inset, cell - inset * 2.0)
	return atlas


func get_accessories() -> Array[AccessoryData]:
	_ensure_catalog()
	return _accessories


func get_accessory(accessory_id: String) -> AccessoryData:
	_ensure_catalog()
	return _accessory_by_id.get(accessory_id, null) as AccessoryData


func _build_accessories() -> Array[AccessoryData]:
	var items: Array[AccessoryData] = []
	items.append(_accessory("pearl_drop_earrings", "Brincos de pérola", "accessory_pearl_drop_earrings_v1.png", "ears", 0.20, true, "top"))
	items.append(_accessory("gold_hoop_earrings", "Argolas douradas", "accessory_gold_hoop_earrings_v1.png", "ears", 0.18, true, "top"))
	items.append(_accessory("star_barrette", "Presilha estrela", "accessory_star_barrette_v1.png", "temple_r", 0.22, false, "center", 18.0))
	items.append(_accessory("flower_barrette", "Presilha floral", "accessory_flower_barrette_v1.png", "temple_l", 0.20, false, "center", -16.0))
	items.append(_accessory("cat_eye_sunglasses", "Óculos gatinho", "accessory_cat_eye_sunglasses_v1.png", "bridge", 0.78, false, "center", 0.0, true))
	items.append(_accessory("heart_tiara", "Tiara de coração", "accessory_heart_tiara_v1.png", "crown", 0.62, false, "bottom", 0.0, true))
	items.append(_accessory("heart_stud_earrings", "Brincos de coração", "accessory_heart_stud_earrings_v1.png", "ears", 0.13, true, "center", 0.0, true))
	items.append(_accessory("moon_barrette", "Presilha de lua", "accessory_moon_barrette_v1.png", "temple_r", 0.20, false, "center", 14.0, true))
	items.append(_accessory("sapphire_barrette", "Presilha safira", "accessory_sapphire_barrette_v1.png", "temple_l", 0.24, false, "center", -12.0, true))
	items.append(_accessory("round_glasses", "Óculos redondos", "accessory_round_glasses_v1.png", "bridge", 0.80, false, "center", 0.0, true))
	items.append(_accessory("floral_headband", "Tiara floral", "accessory_floral_headband_v1.png", "crown", 0.72, false, "bottom", 0.0, true))
	items.append(_accessory("pearl_flower_necklace", "Colar de pérolas", "accessory_pearl_flower_necklace_v1.png", "neck", 0.68, false, "top", 0.0, true))
	return items


func _accessory(
		id: String,
		display_name: String,
		file_name: String,
		anchor: String,
		scale: float,
		pair: bool,
		pivot: String = "center",
		rotation_deg: float = 0.0,
		extra_pack: bool = false
	) -> AccessoryData:
	var data := AccessoryData.new()
	data.id = id
	data.display_name = display_name
	data.texture = load("res://assets/accessories/items/%s" % file_name) as Texture2D
	data.anchor = anchor
	data.scale = scale
	data.pair = pair
	data.pivot = pivot
	data.rotation_deg = rotation_deg
	data.extra_pack = extra_pack
	return data


func _build_challenges() -> Dictionary:
	var gala := ChallengeData.new()
	gala.id = "challenge_gala_01"
	gala.display_name = "Noite de gala"
	gala.theme = "festa"
	gala.briefing = "Pinte os lábios e as pálpebras. Escolha as cores que você mais gostar!"
	gala.model_id = "model_01"
	gala.background_index = 1
	gala.recommended_cosmetic_ids = ["lipstick_ruby", "eyeshadow_champagne"]
	gala.coin_reward = 30
	gala.mandatory_objectives = []
	gala.mandatory_objectives.append({"id": "apply_lipstick", "type": "coverage", "category": "lipstick", "label": "Pintou os lábios", "min_coverage": 0.12})
	gala.mandatory_objectives.append({"id": "apply_eyeshadow", "type": "coverage", "category": "eyeshadow", "label": "Pintou as pálpebras", "min_coverage": 0.12})
	gala.optional_objectives = []
	gala.optional_objectives.append({"id": "gala_lipstick_color", "type": "recommended_color", "category": "lipstick", "cosmetic_id": "lipstick_ruby", "label": "Bônus: batom vermelho"})
	return {gala.id: gala}

class_name ModelData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var face_base: Texture2D
@export var hair_back: Texture2D
@export var hair_front: Texture2D
@export var thumb: Texture2D
@export var smile: Texture2D
@export var mask_skin: Texture2D
@export var mask_lips: Texture2D
@export var mask_eye_l: Texture2D
@export var mask_eye_r: Texture2D
@export var mask_cheek_l: Texture2D
@export var mask_cheek_r: Texture2D
@export var mask_lash_l: Texture2D
@export var mask_lash_r: Texture2D
@export var overlay_foundation: Texture2D
@export var overlay_blush: Texture2D
@export var overlay_eyeshadow: Texture2D
@export var overlay_lipstick: Texture2D
@export var extra_pack: bool = false

const CANVAS_SIZE := Vector2i(1024, 1536)

func mask_for(category: String) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	match category:
		"lipstick":
			if mask_lips:
				out.append(mask_lips)
		"eyeshadow":
			if mask_eye_l:
				out.append(mask_eye_l)
			if mask_eye_r:
				out.append(mask_eye_r)
		"foundation":
			if mask_skin:
				out.append(mask_skin)
		"blush":
			if mask_cheek_l:
				out.append(mask_cheek_l)
			if mask_cheek_r:
				out.append(mask_cheek_r)
		"mascara", "eyeliner":
			if mask_lash_l:
				out.append(mask_lash_l)
			if mask_lash_r:
				out.append(mask_lash_r)
	return out


func overlay_for(category: String) -> Texture2D:
	match category:
		"foundation":
			return overlay_foundation
		"blush":
			return overlay_blush
		"eyeshadow":
			return overlay_eyeshadow
		"lipstick":
			return overlay_lipstick
		_:
			return null

class_name MakeupSession
extends RefCounted

signal model_changed
signal layers_changed
signal accessories_changed

const LAYER_CATEGORIES: Array[String] = [
	"foundation", "blush", "eyeshadow", "eyeliner", "mascara", "lipstick",
]

var model: ModelData
var head_rect := Rect2i(200, 200, 624, 900)
var landmarks: Dictionary = {}
var equipped: Dictionary = {}
var _layers: Dictionary = {}
var _textures: Dictionary = {}
var _masks: Dictionary = {}
var _mask_bbox: Dictionary = {}
var _face_image: Image
var _lash_cache: Dictionary = {}
var _texture_sync_queued: Dictionary = {}


func load_model(next_model: ModelData) -> void:
	model = next_model
	_layers.clear()
	_textures.clear()
	_masks.clear()
	_mask_bbox.clear()
	equipped.clear()
	landmarks.clear()
	_face_image = null
	if model == null:
		model_changed.emit()
		layers_changed.emit()
		accessories_changed.emit()
		return
	if model.face_base:
		_face_image = _as_rgba(model.face_base.get_image())
	for category in LAYER_CATEGORIES:
		var image := Image.create(ModelData.CANVAS_SIZE.x, ModelData.CANVAS_SIZE.y, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 0))
		_layers[category] = image
		_textures[category] = ImageTexture.create_from_image(image)
		_masks[category] = _load_masks(model.mask_for(category))
		_mask_bbox[category] = _compute_bbox(_masks[category])
	head_rect = _mask_bbox.get("foundation", Rect2i(200, 200, 624, 900))
	_compute_landmarks()
	model_changed.emit()
	layers_changed.emit()
	accessories_changed.emit()


func layer_texture(category: String) -> Texture2D:
	return _textures.get(category, null)


func duplicate_layer(category: String) -> Image:
	var image: Image = _layers.get(category, null)
	if image == null:
		return null
	return image.duplicate()


func snapshot() -> Dictionary:
	var snap := {}
	for category in LAYER_CATEGORIES:
		var image: Image = _layers.get(category, null)
		snap[category] = image.duplicate() if image else null
	snap["accessories"] = equipped.duplicate()
	return snap


func restore_snapshot(snap: Dictionary) -> void:
	for category in LAYER_CATEGORIES:
		if not snap.has(category):
			continue
		var image: Image = snap[category]
		if image == null:
			continue
		_layers[category] = image.duplicate()
		_sync_texture(category)
	if snap.has("accessories"):
		equipped = (snap["accessories"] as Dictionary).duplicate()
		accessories_changed.emit()
	layers_changed.emit()


func restore_layer(category: String, image: Image) -> void:
	if image == null or not _layers.has(category):
		return
	_layers[category] = image.duplicate()
	_sync_texture(category)
	layers_changed.emit()


func clear_layer(category: String) -> void:
	var image: Image = _layers.get(category, null)
	if image == null:
		return
	image.fill(Color(0, 0, 0, 0))
	_sync_texture(category)
	layers_changed.emit()


func clear_all() -> void:
	for category in LAYER_CATEGORIES:
		clear_layer(category)


func apply_pilot_look() -> void:
	if model == null:
		return
	for category in LAYER_CATEGORIES:
		var overlay := model.overlay_for(category)
		if overlay == null:
			continue
		var src := _as_rgba(overlay.get_image())
		if src == null:
			continue
		_layers[category] = src
		_sync_texture(category)
	var lashes: CosmeticData = null
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		var library = (tree as SceneTree).root.get_node_or_null("ContentLibrary")
		if library:
			lashes = library.get_cosmetic("mascara_natural_defined")
	if lashes:
		apply_lashes(lashes)
	else:
		layers_changed.emit()


func toggle_accessory(accessory: AccessoryData) -> void:
	if accessory == null:
		return
	if String(equipped.get(accessory.anchor, "")) == accessory.id:
		equipped.erase(accessory.anchor)
	else:
		equipped[accessory.anchor] = accessory.id
	accessories_changed.emit()


func apply_mask_fill(category: String, color: Color, intensity: float, dilate_px: int = 8) -> bool:
	var image: Image = _layers.get(category, null)
	var masks: Array = _masks.get(category, [])
	if image == null or masks.is_empty():
		return false
	var bbox: Rect2i = _mask_bbox.get(category, Rect2i())
	if bbox.size.x < 2:
		return false
	var pad := maxi(dilate_px, 0)
	var x0 := clampi(bbox.position.x - pad, 0, image.get_width() - 1)
	var y0 := clampi(bbox.position.y - pad, 0, image.get_height() - 1)
	var x1 := clampi(bbox.end.x + pad, 0, image.get_width() - 1)
	var y1 := clampi(bbox.end.y + pad, 0, image.get_height() - 1)
	var painted := false
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var mask_v := _mask_tolerant(masks, x, y, pad)
			if mask_v <= 0.02:
				continue
			var amount := clampf(intensity * mask_v, 0.0, 1.0)
			var dst := image.get_pixel(x, y)
			image.set_pixel(x, y, _blend_over(dst, _shaded(color, x, y), amount))
			painted = true
	if painted:
		_sync_texture(category)
		layers_changed.emit()
	return painted


func apply_lashes(
		cosmetic: CosmeticData,
		size_px: int = 24,
		tint: Color = Color(0, 0, 0, 0),
		intensity: float = -1.0
	) -> bool:
	var image: Image = _layers.get("mascara", null)
	if image == null or cosmetic == null:
		return false
	image.fill(Color(0, 0, 0, 0))
	var color := tint if tint.a > 0.05 else cosmetic.color
	var amount := intensity if intensity >= 0.0 else cosmetic.default_intensity
	var painted := false
	var masks: Array = _masks.get("mascara", [])
	var size_mul := clampf(float(maxi(size_px, 8)) / 24.0, 0.45, 1.7)
	for side in 2:
		var piece := _lash_piece(cosmetic, side)
		var strip: Image = piece.get("image", null)
		if strip == null:
			continue
		var eye := _eye_box_for_side(side)
		if eye.size.x < 8:
			continue
		var attach := int(piece.get("attach", int(strip.get_height() * 0.88)))
		var outer_pad := int(round(float(eye.size.x) * 0.06))
		var x0 := eye.position.x - (outer_pad if side == 0 else int(round(float(eye.size.x) * 0.03)))
		var x1 := eye.end.x + (outer_pad if side == 1 else int(round(float(eye.size.x) * 0.03)))
		var target_w := float(maxi(x1 - x0, 8))
		var scale := target_w / float(maxi(strip.get_width(), 1))
		var dest_w := maxi(int(round(float(strip.get_width()) * scale)), 8)
		var dest_h := maxi(int(round(float(strip.get_height()) * scale * size_mul * 0.62)), 22)
		var scaled := strip.duplicate()
		scaled.resize(dest_w, dest_h, Image.INTERPOLATE_CUBIC)
		var attach_s := float(attach) * (float(dest_h) / float(maxi(strip.get_height(), 1)))
		var dest_x := x0
		var fallback_y := int(round(float(eye.position.y) + float(eye.size.y) * 0.55))
		var mask: Image = masks[side] if side < masks.size() else null
		var line := _lash_line_samples(mask, dest_x, dest_w, fallback_y)
		if _blit_lashes_along(image, scaled, dest_x, line, attach_s, color, amount):
			painted = true
	_sync_texture("mascara")
	layers_changed.emit()
	return painted


func layer_bbox(category: String) -> Rect2i:
	var image: Image = _layers.get(category, null)
	if image == null:
		return Rect2i()
	return _opaque_bbox(image)


func has_paint(category: String) -> bool:
	var image: Image = _layers.get(category, null)
	if image == null:
		return false
	for y in range(0, image.get_height(), 6):
		for x in range(0, image.get_width(), 6):
			if image.get_pixel(x, y).a > 0.18:
				return true
	return false


func _lash_piece(cosmetic: CosmeticData, side: int) -> Dictionary:
	var style := cosmetic.id.trim_prefix("mascara_") if cosmetic else ""
	var key := "%s:%d" % [style, side]
	if _lash_cache.has(key):
		return _lash_cache[key]
	var empty := {}
	var side_name := "left" if side == 0 else "right"
	var path := "res://assets/cosmetics/mascara/items/mascara_%s_%s_v1.png" % [style, side_name]
	var sheet := load(path) as Texture2D
	if sheet == null:
		sheet = load("res://assets/cosmetics/mascara/mascara_style_atlas_v1.png") as Texture2D
	if sheet == null:
		return empty
	var src := _as_rgba(sheet.get_image())
	if src == null:
		return empty
	var cell := src
	if src.get_width() > 400 and src.get_height() > 400:
		var cols := 2
		var cell_w := int(src.get_width() / cols)
		var cell_h := int(src.get_height() / cols)
		var col := cosmetic.atlas_index % cols
		var row := int(cosmetic.atlas_index / cols)
		cell = src.get_region(Rect2i(col * cell_w, row * cell_h, cell_w, cell_h))
		var box := _opaque_bbox(cell)
		if box.size.x < 8:
			return empty
		var gap := _pair_gap_x(cell, box)
		var half := Rect2i(box)
		if side == 0:
			half.size.x = maxi(gap - box.position.x, 4)
		else:
			half.position.x = gap
			half.size.x = maxi(box.end.x - gap, 4)
		cell = cell.get_region(half)
	var tight := _opaque_bbox(cell)
	if tight.size.x < 8 or tight.size.y < 6:
		return empty
	var strip := cell.get_region(tight)
	var attach := _lash_root_row(strip)
	var keep_below := maxi(int(round(float(strip.get_height()) * 0.05)), 4)
	var cut_h := mini(strip.get_height(), attach + keep_below)
	if cut_h < strip.get_height():
		strip = strip.get_region(Rect2i(0, 0, strip.get_width(), cut_h))
	attach = clampi(attach, 0, strip.get_height() - 1)
	var data := {"image": strip, "attach": attach}
	_lash_cache[key] = data
	return data


func _eye_box_for_side(side: int) -> Rect2i:
	var lash := _side_bbox("mascara", side)
	if lash.size.x >= 8:
		return lash
	return _side_bbox("eyeshadow", side)


func _side_bbox(category: String, side: int) -> Rect2i:
	var masks: Array = _masks.get(category, [])
	if side < 0 or side >= masks.size():
		return Rect2i()
	return _compute_bbox([masks[side]])


func _pair_gap_x(cell: Image, box: Rect2i) -> int:
	var x0 := box.position.x + int(float(box.size.x) * 0.28)
	var x1 := box.position.x + int(float(box.size.x) * 0.72)
	var best_x := box.position.x + int(round(float(box.size.x) * 0.5))
	var best_mass := 1 << 30
	var peak := 1
	for x in range(box.position.x, box.end.x):
		var mass := 0
		for y in range(box.position.y, box.end.y):
			if cell.get_pixel(x, y).a > 0.08:
				mass += 1
		peak = maxi(peak, mass)
		if x < x0 or x > x1:
			continue
		if mass < best_mass:
			best_mass = mass
			best_x = x
	if best_mass > maxi(8, int(float(peak) * 0.08)):
		return box.position.x + int(round(float(box.size.x) * 0.5))
	return best_x


func _lash_root_row(src: Image) -> int:
	var y_start := int(float(src.get_height()) * 0.58)
	var best_y := src.get_height() - 1
	var best_n := -1
	for y in range(src.get_height() - 1, y_start - 1, -1):
		var n := 0
		for x in src.get_width():
			if src.get_pixel(x, y).a > 0.16:
				n += 1
		if n > best_n:
			best_n = n
			best_y = y
	return best_y


func _opaque_bbox(src: Image) -> Rect2i:
	var min_x := src.get_width()
	var min_y := src.get_height()
	var max_x := 0
	var max_y := 0
	var found := false
	for y in src.get_height():
		for x in src.get_width():
			if src.get_pixel(x, y).a < 0.10:
				continue
			found = true
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if not found:
		return Rect2i()
	return Rect2i(min_x, min_y, maxi(max_x - min_x + 1, 1), maxi(max_y - min_y + 1, 1))


func _lash_line_samples(mask: Image, dest_x: int, dest_w: int, fallback_y: int) -> PackedInt32Array:
	var line := PackedInt32Array()
	line.resize(dest_w)
	var last := fallback_y
	for i in dest_w:
		var y := _mask_ridge_y(mask, dest_x + i)
		if y < 0:
			y = last
		else:
			last = y
		line[i] = y
	var lead := 0
	while lead < dest_w and _mask_ridge_y(mask, dest_x + lead) < 0:
		lead += 1
	if lead > 0 and lead < dest_w:
		for i in lead:
			line[i] = line[lead]
	for _pass in 2:
		for i in range(1, dest_w - 1):
			line[i] = int(round((float(line[i - 1]) + float(line[i]) + float(line[i + 1])) / 3.0))
	return line


func _mask_ridge_y(mask: Image, x: int) -> int:
	if mask == null or x < 0 or x >= mask.get_width():
		return -1
	var best_y := -1
	var best_a := 0.08
	for y in mask.get_height():
		var a := mask.get_pixel(x, y).a
		if a > best_a:
			best_a = a
			best_y = y
	return best_y


func _blit_lashes_along(
		dst: Image,
		src: Image,
		dest_x: int,
		line: PackedInt32Array,
		attach_s: float,
		color: Color,
		intensity: float
	) -> bool:
	var painted := false
	var amount := clampf(intensity, 0.35, 1.0)
	for x in src.get_width():
		if x >= line.size():
			break
		var dest_y := int(round(float(line[x]) - attach_s + 3.0))
		for y in src.get_height():
			var pixel := src.get_pixel(x, y)
			if pixel.a < 0.14:
				continue
			var dx := dest_x + x
			var dy := dest_y + y
			if dx < 0 or dy < 0 or dx >= dst.get_width() or dy >= dst.get_height():
				continue
			var fiber := clampf(pixel.a, 0.0, 1.0)
			var lift := clampf((1.0 - fiber) * 0.22, 0.0, 0.28)
			var tinted := Color(
				clampf(color.r + lift, 0.0, 1.0),
				clampf(color.g + lift, 0.0, 1.0),
				clampf(color.b + lift, 0.0, 1.0),
				pixel.a * amount
			)
			dst.set_pixel(dx, dy, _blend_over(dst.get_pixel(dx, dy), tinted, tinted.a))
			painted = true
	return painted


func coverage(category: String) -> float:
	var image: Image = _layers.get(category, null)
	var masks: Array = _masks.get(category, [])
	if image == null or masks.is_empty():
		return 0.0
	var mask_sum := 0.0
	var paint_sum := 0.0
	var step := 4
	for y in range(0, image.get_height(), step):
		for x in range(0, image.get_width(), step):
			var mask_v := _mask_value_at(masks, x, y)
			if mask_v <= 0.05:
				continue
			mask_sum += mask_v
			paint_sum += image.get_pixel(x, y).a * mask_v
	if mask_sum <= 0.001:
		return 0.0
	return clampf(paint_sum / mask_sum, 0.0, 1.0)


func average_color(category: String, clip_to_mask: bool = true) -> Color:
	var image: Image = _layers.get(category, null)
	var masks: Array = _masks.get(category, [])
	if image == null:
		return Color(0, 0, 0, 0)
	var rgb := Vector3.ZERO
	var weight := 0.0
	var step := 4
	for y in range(0, image.get_height(), step):
		for x in range(0, image.get_width(), step):
			var pixel := image.get_pixel(x, y)
			if pixel.a <= 0.05:
				continue
			if clip_to_mask and not masks.is_empty() and _mask_value_at(masks, x, y) <= 0.05:
				continue
			rgb += Vector3(pixel.r, pixel.g, pixel.b) * pixel.a
			weight += pixel.a
	if weight <= 0.001:
		return Color(0, 0, 0, 0)
	rgb /= weight
	return Color(rgb.x, rgb.y, rgb.z, 1.0)


func stamp(
		category: String,
		center: Vector2i,
		radius: int,
		color: Color,
		intensity: float,
		erase: bool,
		dilate_px: int = 0
	) -> bool:
	var image: Image = _layers.get(category, null)
	if image == null or radius <= 0:
		return false
	var painted := false
	var r := maxi(radius, 1)
	var r2 := float(r * r)
	var width := image.get_width()
	var height := image.get_height()
	var x0 := clampi(center.x - r, 0, width - 1)
	var y0 := clampi(center.y - r, 0, height - 1)
	var x1 := clampi(center.x + r, 0, width - 1)
	var y1 := clampi(center.y + r, 0, height - 1)
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var dx := float(x - center.x)
			var dy := float(y - center.y)
			var dist2 := dx * dx + dy * dy
			if dist2 > r2:
				continue
			var surface := _character_coverage(x, y, dilate_px)
			if surface <= 0.02:
				continue
			var falloff := 1.0 - sqrt(dist2) / float(r)
			falloff *= falloff * (2.0 - falloff)
			var coverage := clampf(falloff * intensity * surface, 0.0, 1.0)
			if coverage <= 0.001:
				continue
			var dst := image.get_pixel(x, y)
			if erase:
				dst.a = maxf(dst.a - coverage, 0.0)
				image.set_pixel(x, y, dst)
			else:
				image.set_pixel(x, y, _blend_over(dst, _shaded(color, x, y), coverage))
			painted = true
	if painted:
		_queue_texture_sync(category)
	return painted


func _character_coverage(x: int, y: int, dilate_px: int = 0) -> float:
	if _face_image:
		if x >= 0 and y >= 0 and x < _face_image.get_width() and y < _face_image.get_height():
			var alpha := _face_image.get_pixel(x, y).a
			if alpha > 0.12:
				return alpha
	var face_masks: Array = _masks.get("foundation", [])
	var value := _mask_value_at(face_masks, x, y)
	if value > 0.02:
		return value
	if dilate_px > 0:
		return _mask_tolerant(face_masks, x, y, dilate_px)
	return 0.0


func _sync_texture(category: String) -> void:
	var image: Image = _layers.get(category, null)
	var tex: ImageTexture = _textures.get(category, null)
	if image == null:
		return
	if tex == null:
		_textures[category] = ImageTexture.create_from_image(image)
	else:
		tex.update(image)


func _queue_texture_sync(category: String) -> void:
	# Varios eventos de mouse podem chegar no mesmo frame. Um unico upload da
	# imagem final mantem a pintura fluida e evita trabalho repetido na GPU.
	if _texture_sync_queued.has(category):
		return
	_texture_sync_queued[category] = true
	call_deferred("_flush_texture_sync", category)


func _flush_texture_sync(category: String) -> void:
	_texture_sync_queued.erase(category)
	_sync_texture(category)


func _load_masks(textures: Array[Texture2D]) -> Array[Image]:
	var masks: Array[Image] = []
	for texture in textures:
		if texture == null:
			continue
		var src := _as_rgba(texture.get_image())
		if src == null:
			continue
		if src.get_size() != ModelData.CANVAS_SIZE:
			src.resize(ModelData.CANVAS_SIZE.x, ModelData.CANVAS_SIZE.y, Image.INTERPOLATE_BILINEAR)
		masks.append(src)
	return masks


func _mask_value_at(masks: Array, x: int, y: int) -> float:
	var value := 0.0
	for mask in masks:
		var image := mask as Image
		if image == null:
			continue
		if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
			continue
		value = maxf(value, _mask_value(image.get_pixel(x, y)))
	return value


func _mask_tolerant(masks: Array, x: int, y: int, dilate: int) -> float:
	var value := _mask_value_at(masks, x, y)
	if dilate <= 0:
		return value
	var extra := 0.0
	for ox in [-dilate, 0, dilate]:
		for oy in [-dilate, 0, dilate]:
			if ox == 0 and oy == 0:
				continue
			extra = maxf(extra, _mask_value_at(masks, x + ox, y + oy))
	return maxf(value, extra * 0.65)


func _compute_landmarks() -> void:
	var eye_masks: Array = _masks.get("eyeshadow", [])
	var eye_l := _compute_bbox([eye_masks[0]] if eye_masks.size() > 0 else [])
	var eye_r := _compute_bbox([eye_masks[1]] if eye_masks.size() > 1 else [])
	if eye_l.size.x < 2 or eye_r.size.x < 2:
		var head := head_rect
		var cx := float(head.position.x) + float(head.size.x) * 0.5
		var cy := float(head.position.y) + float(head.size.y) * 0.42
		var ipd := maxf(float(head.size.x) * 0.42, 80.0)
		_fill_landmarks(Vector2(cx - ipd * 0.5, cy), Vector2(cx + ipd * 0.5, cy), ipd)
		return
	var left := Vector2(
		float(eye_l.position.x) + float(eye_l.size.x) * 0.5,
		float(eye_l.position.y) + float(eye_l.size.y) * 0.92
	)
	var right := Vector2(
		float(eye_r.position.x) + float(eye_r.size.x) * 0.5,
		float(eye_r.position.y) + float(eye_r.size.y) * 0.92
	)
	_fill_landmarks(left, right, maxf(right.x - left.x, 80.0))
	landmarks["eye_outer_l"] = Vector2(float(eye_l.position.x), left.y)
	landmarks["eye_outer_r"] = Vector2(float(eye_r.end.x), right.y)


func _fill_landmarks(left: Vector2, right: Vector2, ipd: float) -> void:
	var mid := (left + right) * 0.5
	var face_top := float(head_rect.position.y)
	if _face_image:
		var bb := _alpha_bbox(_face_image)
		if bb.size.y > 4:
			face_top = float(bb.position.y)
			landmarks["face_bbox"] = bb
	var lips: Rect2i = _mask_bbox.get("lipstick", Rect2i())
	var lips_bottom := float(lips.end.y) if lips.size.y > 2 else mid.y + ipd * 1.15
	landmarks["eye_l"] = left
	landmarks["eye_r"] = right
	landmarks["ipd"] = ipd
	landmarks["head_width"] = ipd * 2.35
	landmarks["bridge"] = Vector2(mid.x, mid.y + ipd * 0.06)
	landmarks["ear_l"] = Vector2(mid.x - ipd * 1.10, mid.y + ipd * 0.34)
	landmarks["ear_r"] = Vector2(mid.x + ipd * 1.10, mid.y + ipd * 0.34)
	landmarks["temple_l"] = Vector2(left.x - ipd * 0.38, left.y - ipd * 0.32)
	landmarks["temple_r"] = Vector2(right.x + ipd * 0.38, right.y - ipd * 0.32)
	landmarks["crown"] = Vector2(mid.x, face_top + ipd * 0.10)
	landmarks["neck"] = Vector2(mid.x, lips_bottom + ipd * 0.42)
	if not landmarks.has("eye_outer_l"):
		landmarks["eye_outer_l"] = Vector2(left.x - ipd * 0.28, left.y)
		landmarks["eye_outer_r"] = Vector2(right.x + ipd * 0.28, right.y)
	head_rect = Rect2i(
		int(mid.x - ipd * 1.18),
		int(face_top),
		int(ipd * 2.36),
		int(maxf(lips_bottom + ipd * 0.7 - face_top, ipd * 2.4))
	)


func _alpha_bbox(image: Image) -> Rect2i:
	if image == null:
		return Rect2i()
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := 0
	var max_y := 0
	var found := false
	for y in range(0, image.get_height(), 3):
		for x in range(0, image.get_width(), 3):
			if image.get_pixel(x, y).a < 0.32:
				continue
			found = true
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if not found:
		return Rect2i()
	return Rect2i(min_x, min_y, maxi(max_x - min_x, 1), maxi(max_y - min_y, 1))


func _compute_bbox(masks: Array) -> Rect2i:
	var min_x := ModelData.CANVAS_SIZE.x
	var min_y := ModelData.CANVAS_SIZE.y
	var max_x := 0
	var max_y := 0
	var found := false
	for mask in masks:
		var image := mask as Image
		if image == null:
			continue
		for y in range(0, image.get_height(), 2):
			for x in range(0, image.get_width(), 2):
				if _mask_value(image.get_pixel(x, y)) <= 0.08:
					continue
				found = true
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if not found:
		return Rect2i()
	return Rect2i(min_x, min_y, maxi(max_x - min_x, 1), maxi(max_y - min_y, 1))


func _as_rgba(image: Image) -> Image:
	if image == null:
		return null
	var copy := image.duplicate()
	if copy.get_format() != Image.FORMAT_RGBA8:
		copy.convert(Image.FORMAT_RGBA8)
	return copy


func _mask_value(pixel: Color) -> float:
	return maxf(pixel.r, maxf(pixel.g, pixel.b)) * pixel.a


func _shaded(color: Color, x: int, y: int) -> Color:
	if _face_image == null:
		return color
	if x < 0 or y < 0 or x >= _face_image.get_width() or y >= _face_image.get_height():
		return color
	var face := _face_image.get_pixel(x, y)
	var luma := face.r * 0.299 + face.g * 0.587 + face.b * 0.114
	var light := clampf(0.38 + luma * 0.85, 0.28, 1.12)
	return Color(color.r * light, color.g * light, color.b * light, color.a)


func _blend_over(dst: Color, color: Color, coverage: float) -> Color:
	var out_a := coverage + dst.a * (1.0 - coverage)
	if out_a <= 0.001:
		return Color(0, 0, 0, 0)
	var rgb := Vector3(color.r, color.g, color.b) * coverage + Vector3(dst.r, dst.g, dst.b) * dst.a * (1.0 - coverage)
	rgb /= out_a
	return Color(rgb.x, rgb.y, rgb.z, out_a)

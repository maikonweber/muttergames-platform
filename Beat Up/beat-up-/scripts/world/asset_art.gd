extends RefCounted
class_name AssetArt
## Carrega PNGs Meshy 2D, remove fundo (chroma), corta e escala para o jogo.
##
## Paths em `assets/generated/2d/<preset>/<preset>.png` (ver services/meshy).
## Cache estático evita reprocessar a mesma textura. Fallback: caller usa polígonos.
##
## `CAR_FACING_OFFSET` alinha o nariz do sprite (~135° na textura) com `facing=0`.

const ROOT := "res://assets/generated/2d"

const TILE_ROAD := ROOT + "/tile_road/tile_road.png"
const TILE_AVENUE := ROOT + "/tile_avenue/tile_avenue.png"
const TILE_CROSSWALK := ROOT + "/tile_crosswalk/tile_crosswalk.png"
const TILE_PARK := ROOT + "/tile_park/tile_park.png"
const TILE_BUILDING := ROOT + "/tile_building_downtown/tile_building_downtown.png"
const TILE_BUILDING_RES := ROOT + "/tile_building_residential/tile_building_residential.png"
const TILE_BUILDING_IND := ROOT + "/tile_building_industrial/tile_building_industrial.png"

const SPRITE_PLAYER := ROOT + "/sprite_player_car/sprite_player_car.png"
const SPRITE_POLICE := ROOT + "/sprite_police_car/sprite_police_car.png"
const SPRITE_TAXI := ROOT + "/sprite_npc_taxi/sprite_npc_taxi.png"
const SPRITE_VAN := ROOT + "/sprite_npc_van/sprite_npc_van.png"
const SPRITE_TREE := ROOT + "/sprite_tree/sprite_tree.png"
const SPRITE_BUSH := ROOT + "/sprite_bush/sprite_bush.png"
const SPRITE_HYDRANT := ROOT + "/sprite_hydrant/sprite_hydrant.png"
const SPRITE_BENCH := ROOT + "/sprite_bench/sprite_bench.png"
const SPRITE_CONE := ROOT + "/sprite_traffic_cone/sprite_traffic_cone.png"
const SPRITE_LAMP := ROOT + "/sprite_street_lamp/sprite_street_lamp.png"
const UI_WANTED := ROOT + "/ui_wanted_alert/ui_wanted_alert.png"
const UI_RADIO := ROOT + "/ui_radio_plate/ui_radio_plate.png"

const CAR_PIXEL_WIDTH := 48.0
const PROP_PIXEL_HEIGHT := 48.0
const TREE_PIXEL_HEIGHT := 64.0

## Meshy cars face ~bottom-left in the texture (≈135°). Align nose with drive facing.
const CAR_FACING_OFFSET := -2.356194490192345  # -3*PI/4
## Shift sprite so tires sit on the road contact point (collision center).
const CAR_FOOT_Y := 10.0

static var _tex_cache: Dictionary = {}
static var _tile_cache: Dictionary = {}


static func clear_cache() -> void:
	_tex_cache.clear()
	_tile_cache.clear()


static func load_image(path: String) -> Image:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		# Godot may need absolute path via ProjectSettings
		var abs_path := ProjectSettings.globalize_path(path)
		if not FileAccess.file_exists(abs_path):
			push_warning("AssetArt missing: %s" % path)
			return null
		var img_disk := Image.load_from_file(abs_path)
		return img_disk
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null or img.is_empty():
		# Fallback: imported texture
		var tex := load(path) as Texture2D
		if tex != null:
			return tex.get_image()
		push_warning("AssetArt failed to load: %s" % path)
		return null
	return img


static func make_texture(path: String, max_w: float = 0.0, max_h: float = 0.0) -> Texture2D:
	var key := "%s|%.1f|%.1f" % [path, max_w, max_h]
	if _tex_cache.has(key):
		return _tex_cache[key] as Texture2D
	var img := load_image(path)
	if img == null:
		return null
	prepare_sprite(img)
	if max_w > 0.0 or max_h > 0.0:
		_fit_image(img, max_w if max_w > 0.0 else 9999.0, max_h if max_h > 0.0 else 9999.0)
	var tex := ImageTexture.create_from_image(img)
	_tex_cache[key] = tex
	return tex


static func apply_car_sprite(visual: Node2D, path: String) -> bool:
	if visual == null:
		return false
	var sprite := visual.get_node_or_null("Sprite") as Sprite2D
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		visual.add_child(sprite)
	var tex := make_texture(path, CAR_PIXEL_WIDTH, CAR_PIXEL_WIDTH)
	if tex == null:
		return false
	sprite.texture = tex
	sprite.centered = true
	# Pivot near tire contact so rotation does not sink the car into the tile plane.
	var half_h := float(tex.get_height()) * 0.5
	sprite.offset = Vector2(0.0, half_h - CAR_FOOT_Y)
	sprite.position = Vector2.ZERO
	sprite.rotation = 0.0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.visible = true
	for child in visual.get_children():
		if child is Polygon2D:
			(child as CanvasItem).visible = false
	return true


static func make_tile_cell(path: String, width: int, height: int) -> Image:
	var key := "%s|%d|%d|mask" % [path, width, height]
	if _tile_cache.has(key):
		return (_tile_cache[key] as Image).duplicate()
	var img := load_image(path)
	if img == null:
		return null
	prepare_sprite(img)
	img.resize(width, height, Image.INTERPOLATE_LANCZOS)
	_mask_isometric_diamond(img)
	_tile_cache[key] = img.duplicate()
	return img


static func _mask_isometric_diamond(img: Image) -> void:
	## Keep only the diamond footprint so art does not bleed like a raised slab.
	var w := img.get_width()
	var h := img.get_height()
	if w < 2 or h < 2:
		return
	var cx := float(w) * 0.5
	var cy := float(h) * 0.5
	for y in h:
		for x in w:
			var nx: float = absf(float(x) - cx) / cx
			var ny: float = absf(float(y) - cy) / cy
			if nx + ny > 1.02:
				img.set_pixel(x, y, Color(0, 0, 0, 0))


static func prepare_sprite(img: Image) -> void:
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	_chroma_key_background(img)
	_crop_to_alpha(img)


static func make_sprite_node(path: String, max_w: float, max_h: float, centered: bool = true) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = make_texture(path, max_w, max_h)
	sprite.centered = centered
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return sprite


static func _chroma_key_background(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	if w < 2 or h < 2:
		return
	# Sample corners — Meshy tiles often sit on flat studio BG.
	var samples: Array[Color] = [
		img.get_pixel(0, 0),
		img.get_pixel(w - 1, 0),
		img.get_pixel(0, h - 1),
		img.get_pixel(w - 1, h - 1),
		img.get_pixel(w / 2, 0),
		img.get_pixel(0, h / 2),
	]
	var key := samples[0]
	var same := 0
	for c in samples:
		if _color_dist(c, key) < 0.12:
			same += 1
	# Only key if background is mostly flat (opaque corners).
	if same < 4 or key.a < 0.85:
		return
	var thresh := 0.18
	for y in h:
		for x in w:
			var p := img.get_pixel(x, y)
			if p.a < 0.05:
				continue
			if _color_dist(p, key) <= thresh:
				img.set_pixel(x, y, Color(0, 0, 0, 0))


static func _crop_to_alpha(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var min_x := w
	var min_y := h
	var max_x := -1
	var max_y := -1
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.08:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x:
		return
	var pad := 2
	min_x = maxi(0, min_x - pad)
	min_y = maxi(0, min_y - pad)
	max_x = mini(w - 1, max_x + pad)
	max_y = mini(h - 1, max_y + pad)
	var region := img.get_region(Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1))
	img.copy_from(region)


static func _fit_image(img: Image, max_w: float, max_h: float) -> void:
	var w := float(img.get_width())
	var h := float(img.get_height())
	if w <= 0.0 or h <= 0.0:
		return
	var scale: float = minf(max_w / w, max_h / h)
	if scale >= 0.999:
		return
	var nw := maxi(1, int(round(w * scale)))
	var nh := maxi(1, int(round(h * scale)))
	img.resize(nw, nh, Image.INTERPOLATE_LANCZOS)


static func _color_dist(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)

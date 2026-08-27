class_name MakeupCanvas
extends Control

var session: MakeupSession
var tools: ToolController
var history: HistoryService

var _hair_back: TextureRect
var _face: TextureRect
var _layers: Dictionary = {}
var _hair_front: TextureRect
var _debug_a: TextureRect
var _debug_b: TextureRect
var _acc_mid: Control
var _acc_front: Control
var _acc_cache: Dictionary = {}
var _show_celebration_expression := false

var _painting := false
var _stroke_dirty := false
var _stroke_before: Dictionary = {}
var _last_pixel := Vector2i(-1, -1)


func setup(p_session: MakeupSession, p_tools: ToolController, p_history: HistoryService) -> void:
	session = p_session
	tools = p_tools
	history = p_history
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	if session:
		session.model_changed.connect(_refresh_model)
		session.layers_changed.connect(_refresh_layers)
		session.accessories_changed.connect(_refresh_accessories)
	if tools:
		tools.changed.connect(_refresh_debug)
	GameState.before_after_changed.connect(func(_active: bool) -> void: _refresh_layers())
	GameState.debug_masks_changed.connect(func(_active: bool) -> void: _refresh_debug())
	resized.connect(_refresh_accessories)
	_refresh_model()


func _build() -> void:
	_hair_back = _make_layer("HairBack")
	_face = _make_layer("Face")
	for category in MakeupSession.LAYER_CATEGORIES:
		_layers[category] = _make_layer("Layer_%s" % category)
	_debug_a = _make_layer("DebugA")
	_debug_b = _make_layer("DebugB")
	_debug_a.modulate = Color(1.0, 0.25, 0.55, 0.38)
	_debug_b.modulate = Color(0.35, 0.7, 1.0, 0.38)
	_acc_mid = _make_anchor_layer("AccMid")
	_hair_front = _make_layer("HairFront")
	_acc_front = _make_anchor_layer("AccFront")


func _make_layer(node_name: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.grow_horizontal = Control.GROW_DIRECTION_BOTH
	rect.grow_vertical = Control.GROW_DIRECTION_BOTH
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(rect)
	return rect


func _make_anchor_layer(node_name: String) -> Control:
	var holder := Control.new()
	holder.name = node_name
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	return holder


func face_rect() -> Rect2:
	var view := size
	var tex := Vector2(ModelData.CANVAS_SIZE)
	if view.x <= 1.0 or view.y <= 1.0:
		return Rect2()
	var scale := minf(view.x / tex.x, view.y / tex.y)
	var drawn := tex * scale
	var origin := (view - drawn) * 0.5
	return Rect2(origin, drawn)


func pixel_at(local_pos: Vector2) -> Vector2i:
	var rect := face_rect()
	if rect.size.x <= 0.0:
		return Vector2i(-1, -1)
	var uv := (local_pos - rect.position) / rect.size
	if uv.x < 0.0 or uv.y < 0.0 or uv.x > 1.0 or uv.y > 1.0:
		return Vector2i(-1, -1)
	return Vector2i(
		clampi(int(uv.x * ModelData.CANVAS_SIZE.x), 0, ModelData.CANVAS_SIZE.x - 1),
		clampi(int(uv.y * ModelData.CANVAS_SIZE.y), 0, ModelData.CANVAS_SIZE.y - 1)
	)


func _gui_input(event: InputEvent) -> void:
	if session == null or tools == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_stroke(event.position)
		else:
			_end_stroke()
		accept_event()
	elif event is InputEventMouseMotion and _painting:
		_continue_stroke(event.position)
		accept_event()


func _begin_stroke(local_pos: Vector2) -> void:
	if tools.is_accessory_tool():
		return
	var pixel := pixel_at(local_pos)
	if pixel.x < 0:
		return
	_stroke_before = session.snapshot()
	_painting = true
	_stroke_dirty = false
	_last_pixel = pixel
	if tools.is_sprite_tool():
		var cosmetic := tools.current_cosmetic()
		if cosmetic and session.apply_lashes(cosmetic):
			_stroke_dirty = true
		_painting = false
		return
	if tools.is_fill_tool():
		var cosmetic := tools.current_cosmetic()
		var dilate := cosmetic.dilate_px if cosmetic else 8
		if session.apply_mask_fill(tools.paint_category(), tools.current_color(), tools.intensity, dilate):
			_stroke_dirty = true
		_painting = false
		return
	_stamp(pixel)


func _continue_stroke(local_pos: Vector2) -> void:
	if not _painting:
		return
	var pixel := pixel_at(local_pos)
	if pixel.x < 0:
		return
	_stamp_line(_last_pixel, pixel)
	_last_pixel = pixel


func _end_stroke() -> void:
	_painting = false
	_last_pixel = Vector2i(-1, -1)
	if history and _stroke_dirty:
		history.push_snapshot(_stroke_before)
	_stroke_before = {}


func _stamp_line(from_px: Vector2i, to_px: Vector2i) -> void:
	var from := Vector2(from_px)
	var to := Vector2(to_px)
	var distance := from.distance_to(to)
	var spacing := maxf(float(tools.brush_radius) * 0.35, 1.0)
	var steps := maxi(int(distance / spacing), 1)
	for i in range(steps + 1):
		var point := from.lerp(to, float(i) / float(steps))
		_stamp(Vector2i(point.round()))


func _stamp(pixel: Vector2i) -> void:
	var category := tools.paint_category()
	if category.is_empty():
		return
	var painted := session.stamp(
		category,
		pixel,
		tools.brush_radius,
		tools.current_color(),
		tools.intensity,
		tools.erase or tools.category == "eraser"
	)
	if painted:
		_stroke_dirty = true
		session.layers_changed.emit()


func _refresh_model() -> void:
	var model := session.model if session else null
	if model == null:
		_face.texture = null
		_hair_back.texture = null
		_hair_front.texture = null
		return
	_face.texture = model.smile if _show_celebration_expression and model.smile else model.face_base
	_hair_back.texture = model.hair_back
	_hair_front.texture = model.hair_front
	_refresh_layers()
	_refresh_debug()
	_refresh_accessories()


func set_celebration_expression(active: bool) -> void:
	if _show_celebration_expression == active:
		return
	_show_celebration_expression = active
	_refresh_model()


func _refresh_layers() -> void:
	var hide_makeup := GameState.before_after
	for category in MakeupSession.LAYER_CATEGORIES:
		var rect: TextureRect = _layers.get(category, null)
		if rect == null:
			continue
		rect.visible = not hide_makeup
		rect.texture = session.layer_texture(category) if session else null
	_refresh_accessories()


func _refresh_accessories() -> void:
	if _acc_mid == null or _acc_front == null:
		return
	for child in _acc_mid.get_children():
		child.queue_free()
	for child in _acc_front.get_children():
		child.queue_free()
	if session == null or GameState.before_after:
		return
	var face := face_rect()
	if face.size.x <= 1.0 or session.landmarks.is_empty():
		return
	var canvas_size := Vector2(ModelData.CANVAS_SIZE)
	var view_scale := face.size / canvas_size
	for slot in session.equipped.keys():
		var accessory := ContentLibrary.get_accessory(String(session.equipped[slot]))
		if accessory == null or accessory.texture == null:
			continue
		var parent := _acc_front if accessory.anchor in ["crown", "neck", "temple_l", "temple_r"] else _acc_mid
		var placements := _placements_for(accessory)
		for placement in placements:
			parent.add_child(_make_accessory_sprite(accessory, placement, face, view_scale))


func _placements_for(accessory: AccessoryData) -> Array[Dictionary]:
	var marks := session.landmarks
	match accessory.anchor:
		"ears":
			return [
				{"point": marks.get("ear_l", Vector2(300, 700)), "split": 0},
				{"point": marks.get("ear_r", Vector2(720, 700)), "split": 1},
			]
		"temple_l":
			return [{"point": marks.get("temple_l", Vector2(320, 520)), "split": -1}]
		"temple_r":
			return [{"point": marks.get("temple_r", Vector2(700, 520)), "split": -1}]
		"bridge":
			var left: Vector2 = marks.get("eye_outer_l", Vector2(330, 560))
			var right: Vector2 = marks.get("eye_outer_r", Vector2(690, 560))
			return [{
				"point": marks.get("bridge", Vector2(512, 580)),
				"split": -1,
				"target_width": maxf(right.x - left.x, 80.0) * 1.16,
			}]
		"crown":
			return [{"point": marks.get("crown", Vector2(512, 120)), "split": -1}]
		"neck":
			return [{"point": marks.get("neck", Vector2(512, 980)), "split": -1}]
		_:
			return [{"point": Vector2(512, 700), "split": -1}]


func _make_accessory_sprite(
		accessory: AccessoryData,
		placement: Dictionary,
		face: Rect2,
		view_scale: Vector2
	) -> Control:
	var tex := _accessory_texture(accessory, int(placement.get("split", -1)))
	var tex_size := Vector2(tex.get_width(), tex.get_height())
	var head_w := float(session.landmarks.get("head_width", 420.0))
	var target_w := float(placement.get("target_width", head_w * accessory.scale))
	var canvas_scale := maxf(target_w, 24.0) / maxf(tex_size.x, 1.0)
	var canvas_size := tex_size * canvas_scale
	var pivot_uv := Vector2(0.5, 0.5)
	match accessory.pivot:
		"top":
			pivot_uv = Vector2(0.5, 0.08)
		"bottom":
			pivot_uv = Vector2(0.5, 0.92)
	var canvas_pivot := Vector2(canvas_size.x * pivot_uv.x, canvas_size.y * pivot_uv.y)
	var view_point: Vector2 = face.position + Vector2(placement["point"]) * view_scale
	var view_size := Vector2(canvas_size.x * view_scale.x, canvas_size.y * view_scale.y)
	var view_pivot := Vector2(canvas_pivot.x * view_scale.x, canvas_pivot.y * view_scale.y)
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.position = view_point
	holder.rotation_degrees = accessory.rotation_deg
	var sprite := TextureRect.new()
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_SCALE
	sprite.texture = tex
	sprite.size = view_size
	sprite.position = -view_pivot
	holder.add_child(sprite)
	return holder


func _accessory_texture(accessory: AccessoryData, split: int) -> Texture2D:
	var key := "%s:%d" % [accessory.id, split]
	if _acc_cache.has(key):
		return _acc_cache[key]
	var source := accessory.texture
	var image := source.get_image()
	if image == null:
		_acc_cache[key] = source
		return source
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	var box := _opaque_bbox(image)
	if box.size.x < 4:
		_acc_cache[key] = source
		return source
	if split >= 0:
		var mid := box.position.x + int(round(float(box.size.x) * 0.5))
		if split == 0:
			box.size.x = maxi(mid - box.position.x, 4)
		else:
			var right := box.end.x
			box.position.x = mid
			box.size.x = maxi(right - mid, 4)
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = Rect2(box)
	atlas.filter_clip = true
	_acc_cache[key] = atlas
	return atlas


func _opaque_bbox(image: Image) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := 0
	var max_y := 0
	var found := false
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a < 0.12:
				continue
			found = true
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if not found:
		return Rect2i()
	return Rect2i(min_x, min_y, maxi(max_x - min_x + 1, 1), maxi(max_y - min_y + 1, 1))


func _refresh_debug() -> void:
	var show := GameState.debug_masks and session != null and session.model != null and tools != null
	_debug_a.visible = show
	_debug_b.visible = show
	if not show:
		_debug_a.texture = null
		_debug_b.texture = null
		return
	var masks := session.model.mask_for(tools.paint_category())
	if masks.is_empty():
		_debug_a.visible = false
		_debug_b.visible = false
		return
	_debug_a.texture = masks[0] if masks.size() > 0 else null
	_debug_b.texture = masks[1] if masks.size() > 1 else null
	_debug_b.visible = show and masks.size() > 1

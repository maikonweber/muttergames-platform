extends Node

signal model_id_changed(model_id: String)
signal before_after_changed(active: bool)
signal debug_masks_changed(active: bool)
signal play_mode_changed(mode: String)

var selected_model_id: String = "model_01"
var background_index: int = 0
var before_after: bool = false
var debug_masks: bool = false
var play_mode: String = "challenge"


func set_play_mode(mode: String) -> void:
	if play_mode == mode:
		return
	play_mode = mode
	play_mode_changed.emit(mode)


func is_free_play() -> bool:
	return play_mode == "free"


func select_model(model_id: String) -> void:
	if selected_model_id == model_id:
		return
	selected_model_id = model_id
	before_after = false
	model_id_changed.emit(model_id)


func cycle_background() -> void:
	var n := ContentLibrary.background_count()
	if n <= 0:
		return
	background_index = (background_index + 1) % n


func set_before_after(active: bool) -> void:
	if before_after == active:
		return
	before_after = active
	before_after_changed.emit(active)


func toggle_before_after() -> void:
	set_before_after(not before_after)


func toggle_debug_masks() -> void:
	debug_masks = not debug_masks
	debug_masks_changed.emit(debug_masks)

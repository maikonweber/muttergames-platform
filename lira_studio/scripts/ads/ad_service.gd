extends Node

## Intersticiais em ações de destaque (rostinho, limpar, surpresa).

signal interstitial_finished

const APP_ID_ANDROID := "ca-app-pub-5667103684184988~1277904095"
const INTERSTITIAL_ANDROID := "ca-app-pub-5667103684184988/3054020193"
const TEST_INTERSTITIAL_ANDROID := "ca-app-pub-3940256099942544/1033173712"
const LOAD_WAIT_SEC := 3.5
const FALLBACK_WAIT_SEC := 2.0

var _interstitial: InterstitialAd
var _loader: InterstitialAdLoader
var _showing := false
var _loading := false
var _pending_show := false
var _wait_token := 0
var _fallback: Control


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_initialize_sdk()
	_load_interstitial()


func is_showing() -> bool:
	return _showing or _pending_show


func show_interstitial() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	if _showing or _pending_show:
		return true
	_pending_show = true
	if _interstitial:
		_show_loaded()
		return true
	_load_interstitial()
	_wait_token += 1
	var token := _wait_token
	get_tree().create_timer(LOAD_WAIT_SEC).timeout.connect(func() -> void:
		if token != _wait_token or not _pending_show or _showing:
			return
		_show_fallback()
	)
	return true


func _initialize_sdk() -> void:
	var request_config := RequestConfiguration.new()
	request_config.max_ad_content_rating = RequestConfiguration.MAX_AD_CONTENT_RATING_G
	MobileAds.set_request_configuration(request_config)
	MobileAds.initialize()


func _ad_unit_id() -> String:
	if OS.get_name() == "Android":
		return INTERSTITIAL_ANDROID
	return TEST_INTERSTITIAL_ANDROID


func _load_interstitial() -> void:
	if _loading or _interstitial != null:
		return
	_loading = true
	_loader = InterstitialAdLoader.new()
	var callback := InterstitialAdLoadCallback.new()
	callback.on_ad_loaded = _on_interstitial_loaded
	callback.on_ad_failed_to_load = _on_interstitial_failed_to_load
	_loader.load(_ad_unit_id(), AdRequest.new(), callback)


func _on_interstitial_loaded(ad: InterstitialAd) -> void:
	_loading = false
	_interstitial = ad
	var callbacks := FullScreenContentCallback.new()
	callbacks.on_ad_dismissed_full_screen_content = _on_interstitial_closed
	callbacks.on_ad_failed_to_show_full_screen_content = _on_interstitial_failed_to_show
	_interstitial.full_screen_content_callback = callbacks
	if _pending_show and not _showing:
		_show_loaded()


func _on_interstitial_failed_to_load(_error: LoadAdError) -> void:
	_loading = false
	_interstitial = null
	if _pending_show and not _showing:
		_show_fallback()


func _show_loaded() -> void:
	if _interstitial == null:
		_show_fallback()
		return
	_pending_show = false
	_showing = true
	_interstitial.show()


func _on_interstitial_failed_to_show(_error: AdError) -> void:
	_show_fallback()


func _on_interstitial_closed() -> void:
	_finish_interstitial()


func _show_fallback() -> void:
	if _showing and _fallback and is_instance_valid(_fallback):
		return
	_close_fallback()
	if _interstitial:
		_interstitial.destroy()
		_interstitial = null
	_pending_show = false
	_showing = true
	_fallback = ColorRect.new()
	_fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fallback.color = Color(0.18, 0.08, 0.14, 0.94)
	_fallback.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_fallback)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -260
	card.offset_right = 260
	card.offset_top = -180
	card.offset_bottom = 180
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.96, 0.95, 0.98)
	style.border_color = Color(0.92, 0.72, 0.32)
	style.set_border_width_all(4)
	style.set_corner_radius_all(28)
	style.set_content_margin_all(22)
	card.add_theme_stylebox_override("panel", style)
	_fallback.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	card.add_child(box)
	var tag := Label.new()
	tag.text = "Publicidade"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color", Color(0.72, 0.48, 0.12))
	box.add_child(tag)
	var title := Label.new()
	title.text = "Já já você volta a pintar"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.42, 0.18, 0.30))
	box.add_child(title)
	var body := Label.new()
	body.text = "Um anúncio rápido enquanto a maquiagem se arruma."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 16)
	body.add_theme_color_override("font_color", Color(0.42, 0.18, 0.30))
	box.add_child(body)
	var skip := Button.new()
	skip.text = "Continuar"
	skip.custom_minimum_size = Vector2(0, 52)
	skip.pressed.connect(_finish_interstitial)
	box.add_child(skip)
	get_tree().create_timer(FALLBACK_WAIT_SEC).timeout.connect(_finish_interstitial)


func _close_fallback() -> void:
	if _fallback and is_instance_valid(_fallback):
		_fallback.queue_free()
	_fallback = null


func _finish_interstitial() -> void:
	if not _showing and not _pending_show:
		return
	_wait_token += 1
	_close_fallback()
	if _interstitial:
		_interstitial.destroy()
		_interstitial = null
	var was_busy := _showing or _pending_show
	_showing = false
	_pending_show = false
	if was_busy:
		interstitial_finished.emit()
	_load_interstitial()

extends Node

## Intersticiais na troca de rostinho. Isolado do restante do jogo.

signal interstitial_finished

const APP_ID_ANDROID := "ca-app-pub-5667103684184988~1277904095"
const INTERSTITIAL_ANDROID := "ca-app-pub-5667103684184988/3054020193"
const TEST_INTERSTITIAL_ANDROID := "ca-app-pub-3940256099942544/1033173712"

var _interstitial: InterstitialAd
var _loader: InterstitialAdLoader
var _showing := false
var _loading := false
var _available := false


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_available = true
	_initialize_sdk()
	_load_interstitial()


func is_showing() -> bool:
	return _showing


func show_on_face_change() -> bool:
	if not _available or _showing:
		return _showing
	if _interstitial == null:
		_load_interstitial()
		return false
	_showing = true
	_interstitial.show()
	return true


func _initialize_sdk() -> void:
	var request_config := RequestConfiguration.new()
	request_config.tag_for_child_directed_treatment = RequestConfiguration.TagForChildDirectedTreatment.TRUE
	request_config.tag_for_under_age_of_consent = RequestConfiguration.TagForUnderAgeOfConsent.TRUE
	request_config.max_ad_content_rating = RequestConfiguration.MAX_AD_CONTENT_RATING_G
	MobileAds.set_request_configuration(request_config)
	MobileAds.initialize()


func _ad_unit_id() -> String:
	if OS.get_name() == "Android":
		return INTERSTITIAL_ANDROID
	return TEST_INTERSTITIAL_ANDROID


func _load_interstitial() -> void:
	if not _available or _loading or _interstitial != null:
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


func _on_interstitial_failed_to_load(_error: LoadAdError) -> void:
	_loading = false
	_interstitial = null
	if _showing:
		_finish_interstitial()


func _on_interstitial_failed_to_show(_error: AdError) -> void:
	_finish_interstitial()


func _on_interstitial_closed() -> void:
	_finish_interstitial()


func _finish_interstitial() -> void:
	if _interstitial:
		_interstitial.destroy()
		_interstitial = null
	var was_showing := _showing
	_showing = false
	if was_showing:
		interstitial_finished.emit()
	_load_interstitial()

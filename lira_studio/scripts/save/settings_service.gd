extends Node

var music: float = 0.7
var sfx: float = 0.8
var vibration: bool = true


func _ready() -> void:
	_sync_from_save()
	SaveService.changed.connect(_sync_from_save)


func _sync_from_save() -> void:
	var settings: Dictionary = SaveService.data.get("settings", {})
	music = float(settings.get("music", 0.7))
	sfx = float(settings.get("sfx", 0.8))
	vibration = bool(settings.get("vibration", true))

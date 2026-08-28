extends Node

const SAVE_PATH := "user://lira_save.json"
const SAVE_VERSION := 1

signal changed

var data: Dictionary = {}


func _ready() -> void:
	load_save()


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		data = _blank()
		save()
		changed.emit()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		data = _blank()
		changed.emit()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		data = _blank()
		changed.emit()
		return
	data = _migrate(parsed)
	changed.emit()


func save() -> void:
	data["version"] = SAVE_VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível gravar o save em %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	changed.emit()


func _blank() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"coins": 0,
		"stars": {},
		"completed": [],
		"owned_skus": [],
		"settings": {
			"music": 0.7,
			"sfx": 0.8,
			"vibration": true,
		},
	}


func _migrate(raw: Dictionary) -> Dictionary:
	var next := _blank()
	next["coins"] = int(raw.get("coins", 0))
	var stars: Variant = raw.get("stars", {})
	if typeof(stars) == TYPE_DICTIONARY:
		next["stars"] = stars
	var completed: Variant = raw.get("completed", [])
	if typeof(completed) == TYPE_ARRAY:
		next["completed"] = completed
	var owned: Variant = raw.get("owned_skus", [])
	if typeof(owned) == TYPE_ARRAY:
		next["owned_skus"] = owned
	var settings: Variant = raw.get("settings", {})
	if typeof(settings) == TYPE_DICTIONARY:
		next["settings"].merge(settings, true)
	next["version"] = SAVE_VERSION
	return next

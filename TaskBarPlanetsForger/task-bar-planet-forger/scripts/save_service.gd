class_name SaveService
extends RefCounted

const SAVE_PATH := "user://taskbar_planets_save.json"
const BACKUP_PATH := "user://taskbar_planets_save.backup.json"
const TEMP_PATH := "user://taskbar_planets_save.tmp.json"
const SCHEMA_VERSION := 2

static func save(data: Dictionary) -> bool:
	data["schema_version"] = SCHEMA_VERSION
	data["saved_at"] = Time.get_unix_time_from_system()
	data["checksum"] = ""
	data["checksum"] = JSON.stringify(data).sha256_text()
	var json := JSON.stringify(data)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null: return false
	file.store_string(json)
	file.close()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	return DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH) == OK

static func load() -> Dictionary:
	for path in [SAVE_PATH, BACKUP_PATH]:
		if not FileAccess.file_exists(path): continue
		var file := FileAccess.open(path, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			var data: Dictionary = parsed
			var version := int(data.get("schema_version", 0))
			if version == 1: return data # migração compatível: novos campos recebem padrão.
			if version == SCHEMA_VERSION:
				var expected := str(data.get("checksum", ""))
				data["checksum"] = ""
				if expected == JSON.stringify(data).sha256_text():
					data["checksum"] = expected
					return data
	return {}

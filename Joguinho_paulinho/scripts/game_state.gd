extends Node

signal started
signal paused_changed(is_paused: bool)
signal collected(kind: String, count: int, total: int)
signal dialogue_shown(speaker: String, line: String)
signal dialogue_closed
signal won
signal nearby_prompt_changed(text: String)

enum Phase { TITLE, PLAY, PAUSE, WIN }

var phase: Phase = Phase.TITLE
var counts: Dictionary = {"limao": 0, "gelo": 0, "tampinha": 0}
var totals: Dictionary = {"limao": 0, "gelo": 0, "tampinha": 0}
var nearby_prompt: String = ""
var _talking: bool = false


func total_found() -> int:
	return int(counts["limao"]) + int(counts["gelo"]) + int(counts["tampinha"])


func total_needed() -> int:
	return int(totals["limao"]) + int(totals["gelo"]) + int(totals["tampinha"])


func register_pickup(kind: String) -> void:
	if not totals.has(kind):
		totals[kind] = 0
	totals[kind] = int(totals[kind]) + 1


func start_game() -> void:
	if phase != Phase.TITLE:
		return
	phase = Phase.PLAY
	started.emit()


func toggle_pause() -> void:
	if phase == Phase.PLAY:
		phase = Phase.PAUSE
		paused_changed.emit(true)
	elif phase == Phase.PAUSE:
		phase = Phase.PLAY
		paused_changed.emit(false)


func collect(kind: String) -> void:
	if phase != Phase.PLAY:
		return
	if not counts.has(kind):
		counts[kind] = 0
	counts[kind] = int(counts[kind]) + 1
	collected.emit(kind, total_found(), total_needed())
	if total_needed() > 0 and total_found() >= total_needed():
		phase = Phase.WIN
		won.emit()


func show_dialogue(speaker: String, line: String) -> void:
	_talking = true
	dialogue_shown.emit(speaker, line)


func close_dialogue() -> void:
	if not _talking:
		return
	_talking = false
	dialogue_closed.emit()


func is_talking() -> bool:
	return _talking


func set_nearby_prompt(text: String) -> void:
	if nearby_prompt == text:
		return
	nearby_prompt = text
	nearby_prompt_changed.emit(text)


func kind_label(kind: String) -> String:
	match kind:
		"limao":
			return "limão"
		"gelo":
			return "gelo"
		"tampinha":
			return "tampinha"
		_:
			return kind

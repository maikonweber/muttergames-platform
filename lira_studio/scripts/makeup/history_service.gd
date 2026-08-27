class_name HistoryService
extends RefCounted

signal changed

const MAX_STEPS := 24

var _undo: Array[Dictionary] = []
var _redo: Array[Dictionary] = []


func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


func clear() -> void:
	_undo.clear()
	_redo.clear()
	changed.emit()


func push_snapshot(before: Dictionary) -> void:
	_undo.append(before)
	if _undo.size() > MAX_STEPS:
		_undo.pop_front()
	_redo.clear()
	changed.emit()


func undo(session: MakeupSession) -> void:
	if session == null or _undo.is_empty():
		return
	var before: Dictionary = _undo.pop_back()
	_redo.append(session.snapshot())
	session.restore_snapshot(before)
	changed.emit()


func redo(session: MakeupSession) -> void:
	if session == null or _redo.is_empty():
		return
	var after: Dictionary = _redo.pop_back()
	_undo.append(session.snapshot())
	session.restore_snapshot(after)
	changed.emit()

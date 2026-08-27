class_name ChallengeService
extends RefCounted

signal started(challenge: ChallengeData)
signal finished(result: Dictionary)

var challenge: ChallengeData
var last_result: Dictionary = {}
var _scoring := ScoringService.new()


func start(challenge_id: String = "") -> ChallengeData:
	if challenge_id.is_empty():
		challenge = ContentLibrary.default_challenge()
	else:
		challenge = ContentLibrary.get_challenge(challenge_id)
	last_result = {}
	started.emit(challenge)
	return challenge


func finish(session: MakeupSession) -> Dictionary:
	last_result = _scoring.evaluate(challenge, session)
	finished.emit(last_result)
	return last_result

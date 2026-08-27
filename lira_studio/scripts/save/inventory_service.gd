extends Node

signal coins_changed(total: int)

var coins: int = 0


func _ready() -> void:
	_sync_from_save()
	SaveService.changed.connect(_sync_from_save)


func add_coins(amount: int) -> void:
	if amount == 0:
		return
	coins = maxi(coins + amount, 0)
	SaveService.data["coins"] = coins
	SaveService.save()
	coins_changed.emit(coins)


func record_challenge(challenge_id: String, stars: int, coins_earned: int) -> void:
	var best: Dictionary = SaveService.data.get("stars", {})
	var previous := int(best.get(challenge_id, 0))
	if stars > previous:
		best[challenge_id] = stars
		SaveService.data["stars"] = best
	var completed: Array = SaveService.data.get("completed", [])
	if stars > 0 and not completed.has(challenge_id):
		completed.append(challenge_id)
		SaveService.data["completed"] = completed
	coins = maxi(coins + coins_earned, 0)
	SaveService.data["coins"] = coins
	SaveService.save()
	coins_changed.emit(coins)


func _sync_from_save() -> void:
	coins = int(SaveService.data.get("coins", 0))
	coins_changed.emit(coins)

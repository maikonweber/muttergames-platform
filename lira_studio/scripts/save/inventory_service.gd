extends Node

signal coins_changed(total: int)
signal pack_changed(owned: bool)

var coins: int = 0
var entitlements := Entitlements.new()


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


func owns_extra_pack() -> bool:
	return entitlements.owns_extra_pack()


func grant_extra_pack() -> void:
	if entitlements.owns_extra_pack():
		return
	entitlements.grant(ExtraPack.SKU)
	_persist_owned()
	pack_changed.emit(true)


func can_use_cosmetic(item: CosmeticData) -> bool:
	return entitlements.can_use_cosmetic(item)


func can_use_model(model: ModelData) -> bool:
	return entitlements.can_use_model(model)


func can_use_model_id(model_id: String) -> bool:
	return entitlements.can_use_flag(ContentLibrary.is_extra_model(model_id))


func can_use_accessory(item: AccessoryData) -> bool:
	return entitlements.can_use_accessory(item)


func can_use_tint(swatch: Dictionary) -> bool:
	return entitlements.can_use_tint(swatch)


func _sync_from_save() -> void:
	coins = int(SaveService.data.get("coins", 0))
	coins_changed.emit(coins)
	var before := entitlements.owns_extra_pack()
	var raw: Variant = SaveService.data.get("owned_skus", [])
	var skus: PackedStringArray = []
	if typeof(raw) == TYPE_ARRAY:
		for item in raw:
			skus.append(String(item))
	entitlements.set_owned(skus)
	var after := entitlements.owns_extra_pack()
	if before != after:
		pack_changed.emit(after)


func _persist_owned() -> void:
	var listed: Array = []
	for sku in entitlements.owned_skus():
		listed.append(sku)
	SaveService.data["owned_skus"] = listed
	SaveService.save()

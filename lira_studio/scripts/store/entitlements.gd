class_name Entitlements
extends RefCounted

var _owned: Dictionary = {}


func set_owned(skus: PackedStringArray) -> void:
	_owned.clear()
	for sku in skus:
		if not String(sku).is_empty():
			_owned[String(sku)] = true


func grant(sku: String) -> void:
	if sku.is_empty():
		return
	_owned[sku] = true


func owns(sku: String) -> bool:
	return bool(_owned.get(sku, false))


func owns_extra_pack() -> bool:
	return owns(ExtraPack.SKU)


func can_use_flag(requires_pack: bool) -> bool:
	return (not requires_pack) or owns_extra_pack()


func can_use_cosmetic(item: CosmeticData) -> bool:
	if item == null:
		return false
	return can_use_flag(item.extra_pack)


func can_use_model(model: ModelData) -> bool:
	if model == null:
		return false
	return can_use_flag(model.extra_pack)


func can_use_accessory(item: AccessoryData) -> bool:
	if item == null:
		return false
	return can_use_flag(item.extra_pack)


func can_use_tint(swatch: Dictionary) -> bool:
	return can_use_flag(bool(swatch.get("extra_pack", false)))


func owned_skus() -> PackedStringArray:
	var out: PackedStringArray = []
	for key in _owned.keys():
		if _owned[key]:
			out.append(String(key))
	out.sort()
	return out

extends Node

signal purchase_finished(ok: bool, sku: String, message: String)

var _adapter: RefCounted


func _ready() -> void:
	_adapter = _pick_adapter()
	if ExtraPack.PURCHASES_ENABLED:
		restore()


func _pick_adapter() -> RefCounted:
	if OS.has_feature("android") and Engine.has_singleton("GodotGooglePlayBilling"):
		return PlayStoreAdapter.new()
	return DevStoreAdapter.new()


func is_play_store() -> bool:
	return _adapter is PlayStoreAdapter


func purchase_extra_pack() -> void:
	if not ExtraPack.PURCHASES_ENABLED:
		purchase_finished.emit(false, ExtraPack.SKU, "")
		return
	if InventoryService.owns_extra_pack():
		purchase_finished.emit(true, ExtraPack.SKU, "Pacote já desbloqueado")
		return
	var result: Dictionary = _adapter.purchase(ExtraPack.SKU)
	if bool(result.get("pending", false)):
		purchase_finished.emit(true, ExtraPack.SKU, "Abra a janela da Play para confirmar")
		return
	if not bool(result.get("ok", false)):
		purchase_finished.emit(false, ExtraPack.SKU, String(result.get("error", "Não deu para comprar")))
		return
	InventoryService.grant_extra_pack()
	purchase_finished.emit(true, ExtraPack.SKU, "Pacote extra liberado")


func restore() -> void:
	var remote: PackedStringArray = _adapter.restore()
	for sku in remote:
		if sku == ExtraPack.SKU:
			InventoryService.grant_extra_pack()

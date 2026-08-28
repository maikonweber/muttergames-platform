class_name PlayStoreAdapter
extends RefCounted

## Ponte para o plugin GodotGooglePlayBilling, quando o AAB Android o tiver ligado.
## Sem o singleton, a compra falha de forma explícita em vez de liberar o pacote.


func purchase(sku: String) -> Dictionary:
	if not Engine.has_singleton("GodotGooglePlayBilling"):
		return {
			"ok": false,
			"sku": sku,
			"source": "play",
			"error": "Plugin da Play ausente. Use teste interno com GodotGooglePlayBilling.",
		}
	var billing := Engine.get_singleton("GodotGooglePlayBilling")
	if billing.has_method("purchase"):
		billing.purchase(sku)
		return {"ok": true, "sku": sku, "source": "play", "pending": true}
	if billing.has_method("purchaseItem"):
		billing.purchaseItem(sku)
		return {"ok": true, "sku": sku, "source": "play", "pending": true}
	return {"ok": false, "sku": sku, "source": "play", "error": "API de compra desconhecida"}


func restore() -> PackedStringArray:
	var owned: PackedStringArray = []
	if not Engine.has_singleton("GodotGooglePlayBilling"):
		return owned
	var billing := Engine.get_singleton("GodotGooglePlayBilling")
	if billing.has_method("queryPurchases"):
		billing.queryPurchases("inapp")
	return owned

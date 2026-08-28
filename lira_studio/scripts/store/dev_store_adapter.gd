class_name DevStoreAdapter
extends RefCounted

## Editor, desktop e teste interno sem plugin da Play: concede na hora após a confirmação da UI.


func purchase(sku: String) -> Dictionary:
	return {"ok": true, "sku": sku, "source": "dev"}


func restore() -> PackedStringArray:
	return PackedStringArray()

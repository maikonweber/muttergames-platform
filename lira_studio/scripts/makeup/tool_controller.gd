class_name ToolController
extends RefCounted

signal changed

const TOOLS: Array[String] = [
	"lipstick", "eyeshadow", "foundation", "blush",
	"eyeliner", "mascara", "accessory", "eraser",
]
const FILL_TOOLS: Array[String] = ["eyeliner"]
const SPRITE_TOOLS: Array[String] = ["mascara"]

var category: String = "lipstick"
var cosmetic_id: String = "lipstick_ruby"
var brush_radius: int = 12
var intensity: float = 0.55
var erase: bool = false

const BRUSH_FOR_TOOL := {
	"lipstick": 11,
	"eyeshadow": 14,
	"foundation": 26,
	"blush": 18,
	"eyeliner": 8,
	"mascara": 9,
	"eraser": 16,
}


func is_fill_tool() -> bool:
	return (not erase) and category in FILL_TOOLS


func is_sprite_tool() -> bool:
	return (not erase) and category in SPRITE_TOOLS


func is_accessory_tool() -> bool:
	return (not erase) and category == "accessory"


func paint_category() -> String:
	if erase or category == "eraser":
		return _layer_from_cosmetic()
	if category == "accessory":
		return ""
	return category


func select_tool(tool_id: String) -> void:
	if tool_id == "eraser":
		erase = true
		category = "eraser"
		brush_radius = int(BRUSH_FOR_TOOL.get("eraser", 16))
		changed.emit()
		return
	erase = false
	category = tool_id
	brush_radius = int(BRUSH_FOR_TOOL.get(tool_id, 12))
	var items := ContentLibrary.get_cosmetics(tool_id)
	if items.is_empty():
		changed.emit()
		return
	var keep := false
	for item in items:
		if item.id == cosmetic_id:
			keep = true
			break
	if not keep:
		select_cosmetic(items[0])
		return
	var current := ContentLibrary.get_cosmetic(cosmetic_id)
	if current:
		intensity = current.default_intensity
	changed.emit()


func select_cosmetic(data: CosmeticData) -> void:
	if data == null:
		return
	erase = false
	category = data.category
	cosmetic_id = data.id
	intensity = data.default_intensity
	brush_radius = int(BRUSH_FOR_TOOL.get(data.category, 12))
	changed.emit()


func set_brush_radius(value: int) -> void:
	brush_radius = clampi(value, 6, 80)


func set_intensity(value: float) -> void:
	intensity = clampf(value, 0.05, 1.0)


func current_cosmetic() -> CosmeticData:
	return ContentLibrary.get_cosmetic(cosmetic_id)


func current_color() -> Color:
	var data := current_cosmetic()
	return data.color if data else Color.WHITE


func _layer_from_cosmetic() -> String:
	var data := current_cosmetic()
	if data:
		return data.category
	return "lipstick"

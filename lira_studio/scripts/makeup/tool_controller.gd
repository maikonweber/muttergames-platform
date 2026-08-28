class_name ToolController
extends RefCounted

signal changed

const TOOLS: Array[String] = [
	"lipstick", "eyeshadow", "foundation", "blush",
	"eyeliner", "mascara", "accessory", "eraser",
]
const FILL_TOOLS: Array[String] = []
const SPRITE_TOOLS: Array[String] = ["mascara"]

var category: String = "lipstick"
var cosmetic_id: String = "lipstick_ruby"
var brush_radius: int = 14
var intensity: float = 0.55
var erase: bool = false
var color_override: Color = Color(0, 0, 0, 0)

const BRUSH_MIN := 8
const BRUSH_MAX := 120

const BRUSH_FOR_TOOL := {
	"lipstick": 14,
	"eyeshadow": 20,
	"foundation": 42,
	"blush": 28,
	"eyeliner": 14,
	"mascara": 20,
	"eraser": 24,
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
		color_override = Color(0, 0, 0, 0)
		brush_radius = int(BRUSH_FOR_TOOL.get("eraser", 24))
		changed.emit()
		return
	erase = false
	category = tool_id
	if category != "mascara" and category != "eyeliner":
		color_override = Color(0, 0, 0, 0)
	brush_radius = int(BRUSH_FOR_TOOL.get(tool_id, 14))
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
	if data.category != "mascara":
		color_override = Color(0, 0, 0, 0)
	brush_radius = int(BRUSH_FOR_TOOL.get(data.category, 14))
	changed.emit()


func select_tint(color: Color) -> void:
	color_override = color
	changed.emit()


func max_brush_radius() -> int:
	return BRUSH_MAX


func set_brush_radius(value: int) -> void:
	var next := clampi(value, BRUSH_MIN, BRUSH_MAX)
	if next == brush_radius:
		return
	brush_radius = next
	changed.emit()


func set_intensity(value: float) -> void:
	var next := clampf(value, 0.05, 1.0)
	if is_equal_approx(next, intensity):
		return
	intensity = next
	changed.emit()


func current_cosmetic() -> CosmeticData:
	return ContentLibrary.get_cosmetic(cosmetic_id)


func current_color() -> Color:
	if color_override.a > 0.05:
		return color_override
	var data := current_cosmetic()
	return data.color if data else Color.WHITE


func _layer_from_cosmetic() -> String:
	var data := current_cosmetic()
	if data:
		return data.category
	return "lipstick"

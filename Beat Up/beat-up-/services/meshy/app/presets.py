from __future__ import annotations

from typing import TypedDict


class AssetPreset(TypedDict):
	id: str
	name: str
	prompt: str
	texture_prompt: str
	art_style: str
	tags: list[str]


# Prompts tuned for Beat Up: compact arcade city props / vehicles (3D refs → later iso sprites).
BEAT_UP_PRESETS: list[AssetPreset] = [
	{
		"id": "player_car",
		"name": "Player car",
		"prompt": (
			"Compact arcade city hatchback car, low poly game asset, clean readable silhouette, "
			"bright cyan body paint, short wheelbase, windshield visible, no driver, "
			"centered on ground, isometric friendly proportions, white studio background style mesh"
		),
		"texture_prompt": "bright cyan paint, black tires, clear glass windshield, subtle dirt, game-ready PBR",
		"art_style": "realistic",
		"tags": ["vehicle", "player"],
	},
	{
		"id": "police_car",
		"name": "Police car",
		"prompt": (
			"Arcade police cruiser sedan, low poly game asset, dark navy body with white doors, "
			"roof light bar, readable silhouette, no characters, centered on ground"
		),
		"texture_prompt": "navy and white police paint, chrome bumpers, emergency light bar, game-ready PBR",
		"art_style": "realistic",
		"tags": ["vehicle", "police"],
	},
	{
		"id": "npc_taxi",
		"name": "NPC taxi",
		"prompt": (
			"Arcade yellow taxi cab sedan, low poly game asset, roof taxi sign, "
			"compact city car proportions, centered on ground, no people"
		),
		"texture_prompt": "classic yellow taxi paint, checkered accents, black tires, game-ready PBR",
		"art_style": "realistic",
		"tags": ["vehicle", "npc"],
	},
	{
		"id": "npc_van",
		"name": "NPC delivery van",
		"prompt": (
			"Small delivery van, low poly game asset, boxy silhouette, city utility vehicle, "
			"centered on ground, no logos with text, no people"
		),
		"texture_prompt": "muted white and gray van paint, dirty panel, black tires, game-ready PBR",
		"art_style": "realistic",
		"tags": ["vehicle", "npc"],
	},
	{
		"id": "tree_city",
		"name": "City tree",
		"prompt": (
			"Single deciduous city street tree, low poly game asset, short trunk, rounded canopy, "
			"centered on ground plane, no pot, park prop for isometric city"
		),
		"texture_prompt": "green foliage, brown bark, subtle variation, game-ready PBR",
		"art_style": "realistic",
		"tags": ["prop", "vegetation"],
	},
	{
		"id": "bush",
		"name": "Bush",
		"prompt": (
			"Low rounded bush shrub, low poly game asset, dense leaves, centered on ground, park prop"
		),
		"texture_prompt": "green leaves, soft variation, game-ready PBR",
		"art_style": "realistic",
		"tags": ["prop", "vegetation"],
	},
	{
		"id": "fire_hydrant",
		"name": "Fire hydrant",
		"prompt": (
			"American fire hydrant street prop, low poly game asset, short and chunky, "
			"centered on ground, readable silhouette"
		),
		"texture_prompt": "red metal paint, slight wear, game-ready PBR",
		"art_style": "realistic",
		"tags": ["prop", "street"],
	},
	{
		"id": "bench",
		"name": "Park bench",
		"prompt": (
			"Park bench with backrest, low poly game asset, wood planks and metal frame, "
			"centered on ground, plaza prop"
		),
		"texture_prompt": "wood planks, dark metal legs, game-ready PBR",
		"art_style": "realistic",
		"tags": ["prop", "park"],
	},
	{
		"id": "building_downtown",
		"name": "Downtown building block",
		"prompt": (
			"Low poly city building block for top-down game, rectangular tall commercial building, "
			"flat roof with vents, simple windows, dense downtown style, centered mesh"
		),
		"texture_prompt": "red brick facade, dark window glass, gray roof, game-ready PBR",
		"art_style": "realistic",
		"tags": ["building", "downtown"],
	},
	{
		"id": "building_residential",
		"name": "Residential building",
		"prompt": (
			"Low poly small residential apartment block, shorter than downtown towers, "
			"balconies, pitched or flat roof, centered mesh for city builder"
		),
		"texture_prompt": "warm orange plaster walls, tiled accents, game-ready PBR",
		"art_style": "realistic",
		"tags": ["building", "residential"],
	},
]


def get_preset(preset_id: str) -> AssetPreset | None:
	for preset in BEAT_UP_PRESETS:
		if preset["id"] == preset_id:
			return preset
	return None


def list_preset_ids() -> list[str]:
	return [p["id"] for p in BEAT_UP_PRESETS]

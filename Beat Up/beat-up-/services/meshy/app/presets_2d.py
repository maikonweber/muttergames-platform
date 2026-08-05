from __future__ import annotations

from typing import TypedDict

ISO_STYLE = (
	"Isometric 2D arcade game art, Godot diamond-down perspective, "
	"64x32 tile footprint feel, top-left lighting, clean readable silhouette, "
	"transparent or flat chroma background, no text, no watermark, no UI chrome"
)


class Asset2DPreset(TypedDict):
	id: str
	name: str
	prompt: str
	tags: list[str]
	aspect_ratio: str
	generate_multi_view: bool
	group: str  # tiles | vehicles | props | ui


BEAT_UP_2D_PRESETS: list[Asset2DPreset] = [
	# --- tiles ---
	{
		"id": "tile_road",
		"name": "Road tile",
		"prompt": (
			f"{ISO_STYLE}. Single isometric diamond asphalt road tile, dark gray pavement, "
			"subtle cracks, faint lane wear, seamless-ready edges"
		),
		"tags": ["tile", "road"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	{
		"id": "tile_avenue",
		"name": "Avenue tile",
		"prompt": (
			f"{ISO_STYLE}. Single isometric diamond wider avenue asphalt tile, darker pavement, "
			"white dashed center line marking, city boulevard"
		),
		"tags": ["tile", "road", "avenue"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	{
		"id": "tile_crosswalk",
		"name": "Crosswalk tile",
		"prompt": (
			f"{ISO_STYLE}. Single isometric diamond road tile with bold yellow zebra crosswalk stripes"
		),
		"tags": ["tile", "road", "crosswalk"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	{
		"id": "tile_park",
		"name": "Park grass tile",
		"prompt": (
			f"{ISO_STYLE}. Single isometric diamond grass park tile, soft green lawn, "
			"subtle dirt path speckles, urban plaza grass"
		),
		"tags": ["tile", "park"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	{
		"id": "tile_building_downtown",
		"name": "Downtown building tile",
		"prompt": (
			f"{ISO_STYLE}. Isometric city building roof/block tile, tall dense downtown style, "
			"red brick or dark commercial facade top, flat roof vents, readable solid block"
		),
		"tags": ["tile", "building", "downtown"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	{
		"id": "tile_building_residential",
		"name": "Residential building tile",
		"prompt": (
			f"{ISO_STYLE}. Isometric residential apartment roof tile, warm orange plaster walls, "
			"lower height than downtown, simple windows, suburban block"
		),
		"tags": ["tile", "building", "residential"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	{
		"id": "tile_building_industrial",
		"name": "Industrial building tile",
		"prompt": (
			f"{ISO_STYLE}. Isometric industrial warehouse roof tile, gray concrete and metal, "
			"vents and pipes, flat utilitarian roof"
		),
		"tags": ["tile", "building", "industrial"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "tiles",
	},
	# --- vehicles ---
	{
		"id": "sprite_player_car",
		"name": "Player car sprite",
		"prompt": (
			f"{ISO_STYLE}. Compact arcade hatchback car top-down isometric, bright cyan body, "
			"clear windshield, short wheelbase, single vehicle centered, game sprite"
		),
		"tags": ["vehicle", "player"],
		"aspect_ratio": "1:1",
		"generate_multi_view": True,
		"group": "vehicles",
	},
	{
		"id": "sprite_police_car",
		"name": "Police car sprite",
		"prompt": (
			f"{ISO_STYLE}. Arcade police cruiser top-down isometric, navy and white doors, "
			"roof light bar, chase vehicle sprite, centered"
		),
		"tags": ["vehicle", "police"],
		"aspect_ratio": "1:1",
		"generate_multi_view": True,
		"group": "vehicles",
	},
	{
		"id": "sprite_npc_taxi",
		"name": "NPC taxi sprite",
		"prompt": (
			f"{ISO_STYLE}. Yellow taxi cab top-down isometric, roof taxi sign, city traffic NPC sprite"
		),
		"tags": ["vehicle", "npc"],
		"aspect_ratio": "1:1",
		"generate_multi_view": True,
		"group": "vehicles",
	},
	{
		"id": "sprite_npc_van",
		"name": "NPC van sprite",
		"prompt": (
			f"{ISO_STYLE}. Small delivery van top-down isometric, boxy white-gray body, traffic NPC"
		),
		"tags": ["vehicle", "npc"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "vehicles",
	},
	# --- props ---
	{
		"id": "sprite_tree",
		"name": "City tree",
		"prompt": (
			f"{ISO_STYLE}. Single street tree prop, rounded canopy, short trunk, y-sortable footprint"
		),
		"tags": ["prop", "vegetation"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "props",
	},
	{
		"id": "sprite_bush",
		"name": "Bush",
		"prompt": (
			f"{ISO_STYLE}. Low rounded bush shrub park prop, dense green leaves, small footprint"
		),
		"tags": ["prop", "vegetation"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "props",
	},
	{
		"id": "sprite_hydrant",
		"name": "Fire hydrant",
		"prompt": (
			f"{ISO_STYLE}. Red fire hydrant street prop, chunky silhouette, sidewalk fixture"
		),
		"tags": ["prop", "street"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "props",
	},
	{
		"id": "sprite_bench",
		"name": "Park bench",
		"prompt": (
			f"{ISO_STYLE}. Park bench with backrest, wood and metal, plaza prop"
		),
		"tags": ["prop", "park"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "props",
	},
	{
		"id": "sprite_traffic_cone",
		"name": "Traffic cone",
		"prompt": (
			f"{ISO_STYLE}. Orange traffic cone with white stripe, street prop"
		),
		"tags": ["prop", "street"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "props",
	},
	{
		"id": "sprite_street_lamp",
		"name": "Street lamp",
		"prompt": (
			f"{ISO_STYLE}. Simple city street lamp post, tall thin prop, sidewalk fixture"
		),
		"tags": ["prop", "street"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "props",
	},
	# --- ui ---
	{
		"id": "ui_wanted_alert",
		"name": "Wanted / police alert icon",
		"prompt": (
			"Flat 2D UI icon for arcade chase game, police alert star or siren badge, "
			"bold high contrast, transparent background, no text, beat-em-up HUD style"
		),
		"tags": ["ui"],
		"aspect_ratio": "1:1",
		"generate_multi_view": False,
		"group": "ui",
	},
	{
		"id": "ui_radio_plate",
		"name": "Radio station plate",
		"prompt": (
			"Flat 2D UI radio station nameplate for arcade car game HUD, "
			"small rectangular panel, retro speaker motif, transparent background, no readable text"
		),
		"tags": ["ui"],
		"aspect_ratio": "16:9",
		"generate_multi_view": False,
		"group": "ui",
	},
]

# Full in-game pack order (all groups).
CORE_2D_PACK_IDS: list[str] = [p["id"] for p in BEAT_UP_2D_PRESETS]


def get_2d_preset(preset_id: str) -> Asset2DPreset | None:
	for preset in BEAT_UP_2D_PRESETS:
		if preset["id"] == preset_id:
			return preset
	return None


def list_2d_preset_ids() -> list[str]:
	return [p["id"] for p in BEAT_UP_2D_PRESETS]


def filter_2d_presets(
	*,
	preset_ids: list[str] | None = None,
	tags: list[str] | None = None,
	groups: list[str] | None = None,
) -> list[Asset2DPreset]:
	selected = list(BEAT_UP_2D_PRESETS)
	if preset_ids:
		idset = set(preset_ids)
		selected = [p for p in selected if p["id"] in idset]
	if tags:
		tagset = set(tags)
		selected = [p for p in selected if tagset.intersection(p["tags"])]
	if groups:
		groupset = set(groups)
		selected = [p for p in selected if p["group"] in groupset]
	return selected

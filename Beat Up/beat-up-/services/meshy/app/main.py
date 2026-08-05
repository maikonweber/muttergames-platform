from __future__ import annotations

from typing import Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from .config import settings
from .meshy_client import MeshyClient, MeshyError, slugify
from .presets import BEAT_UP_PRESETS, get_preset, list_preset_ids
from .presets_2d import (
	BEAT_UP_2D_PRESETS,
	CORE_2D_PACK_IDS,
	filter_2d_presets,
	get_2d_preset,
	list_2d_preset_ids,
)

app = FastAPI(
	title="Beat Up Meshy Asset Service",
	version="1.0.0",
	description="Thin proxy around Meshy API for generating Beat Up game assets. Keeps API keys server-side.",
)


class TextTo3DRequest(BaseModel):
	prompt: str = Field(..., min_length=3, max_length=600)
	stem: str | None = None
	art_style: str = "realistic"
	enable_pbr: bool = True
	should_remesh: bool = True
	texture_prompt: str | None = None
	ai_model: str = "latest"
	refine: bool = True


class ImageTo3DRequest(BaseModel):
	image_url: str
	stem: str | None = None
	should_texture: bool = True
	enable_pbr: bool = True
	ai_model: str = "latest"


class PresetGenerateRequest(BaseModel):
	preset_id: str
	refine: bool = True
	ai_model: str = "latest"


class PackGenerateRequest(BaseModel):
	preset_ids: list[str] | None = None
	tags: list[str] | None = None
	refine: bool = True
	ai_model: str = "latest"
	max_assets: int = Field(default=10, ge=1, le=20)


class TextToImageRequest(BaseModel):
	prompt: str = Field(..., min_length=3, max_length=1200)
	stem: str | None = None
	ai_model: str = "nano-banana"
	aspect_ratio: str = "1:1"
	generate_multi_view: bool = False


class Preset2DGenerateRequest(BaseModel):
	preset_id: str
	ai_model: str = "nano-banana"


class Pack2DGenerateRequest(BaseModel):
	preset_ids: list[str] | None = None
	tags: list[str] | None = None
	groups: list[str] | None = None
	ai_model: str = "nano-banana"
	max_assets: int = Field(default=20, ge=1, le=30)
	core_pack: bool = False


def _client() -> MeshyClient:
	try:
		return MeshyClient()
	except MeshyError as exc:
		raise HTTPException(status_code=503, detail=str(exc)) from exc


@app.get("/health")
async def health() -> dict[str, Any]:
	return {
		"ok": True,
		"output_dir": str(settings.resolved_output_dir()),
		"has_api_key": bool(settings.meshy_api_key),
	}


@app.get("/balance")
async def balance() -> dict[str, Any]:
	client = _client()
	try:
		return await client.get_balance()
	except MeshyError as exc:
		raise HTTPException(status_code=502, detail=str(exc)) from exc


@app.get("/presets")
async def presets() -> dict[str, Any]:
	return {"presets": BEAT_UP_PRESETS, "ids": list_preset_ids()}


@app.get("/presets/2d")
async def presets_2d() -> dict[str, Any]:
	return {
		"presets": BEAT_UP_2D_PRESETS,
		"ids": list_2d_preset_ids(),
		"core_pack_ids": CORE_2D_PACK_IDS,
	}


@app.post("/generate/text-to-3d")
async def generate_text_to_3d(body: TextTo3DRequest) -> dict[str, Any]:
	client = _client()
	stem = body.stem or slugify(body.prompt)
	try:
		return await client.text_to_3d_preview_and_refine(
			body.prompt,
			stem,
			art_style=body.art_style,
			enable_pbr=body.enable_pbr,
			should_remesh=body.should_remesh,
			texture_prompt=body.texture_prompt,
			ai_model=body.ai_model,
			refine=body.refine,
		)
	except MeshyError as exc:
		raise HTTPException(status_code=502, detail=str(exc)) from exc


@app.post("/generate/image-to-3d")
async def generate_image_to_3d(body: ImageTo3DRequest) -> dict[str, Any]:
	client = _client()
	stem = body.stem or "image_asset"
	try:
		return await client.image_to_3d(
			body.image_url,
			stem,
			should_texture=body.should_texture,
			enable_pbr=body.enable_pbr,
			ai_model=body.ai_model,
		)
	except MeshyError as exc:
		raise HTTPException(status_code=502, detail=str(exc)) from exc


@app.post("/generate/preset")
async def generate_preset(body: PresetGenerateRequest) -> dict[str, Any]:
	preset = get_preset(body.preset_id)
	if preset is None:
		raise HTTPException(
			status_code=404,
			detail=f"Unknown preset '{body.preset_id}'. Known: {list_preset_ids()}",
		)
	client = _client()
	try:
		return await client.text_to_3d_preview_and_refine(
			preset["prompt"],
			preset["id"],
			art_style=preset["art_style"],
			texture_prompt=preset["texture_prompt"],
			ai_model=body.ai_model,
			refine=body.refine,
		)
	except MeshyError as exc:
		raise HTTPException(status_code=502, detail=str(exc)) from exc


@app.post("/generate/pack")
async def generate_pack(body: PackGenerateRequest) -> dict[str, Any]:
	"""Generate multiple Beat Up presets. Uses credits — prefer a small pack first."""
	selected = list(BEAT_UP_PRESETS)
	if body.preset_ids:
		selected = [p for p in selected if p["id"] in body.preset_ids]
	if body.tags:
		tagset = set(body.tags)
		selected = [p for p in selected if tagset.intersection(p["tags"])]
	selected = selected[: body.max_assets]
	if not selected:
		raise HTTPException(status_code=400, detail="No presets matched filters.")

	client = _client()
	results: list[dict[str, Any]] = []
	errors: list[dict[str, str]] = []
	for preset in selected:
		try:
			result = await client.text_to_3d_preview_and_refine(
				preset["prompt"],
				preset["id"],
				art_style=preset["art_style"],
				texture_prompt=preset["texture_prompt"],
				ai_model=body.ai_model,
				refine=body.refine,
			)
			results.append(result)
		except MeshyError as exc:
			errors.append({"preset_id": preset["id"], "error": str(exc)})

	return {
		"generated": results,
		"errors": errors,
		"output_dir": str(settings.resolved_output_dir()),
	}


@app.post("/generate/text-to-image")
async def generate_text_to_image(body: TextToImageRequest) -> dict[str, Any]:
	client = _client()
	stem = body.stem or slugify(body.prompt)
	try:
		return await client.text_to_image(
			body.prompt,
			stem,
			ai_model=body.ai_model,
			aspect_ratio=body.aspect_ratio,
			generate_multi_view=body.generate_multi_view,
		)
	except MeshyError as exc:
		raise HTTPException(status_code=502, detail=str(exc)) from exc


@app.post("/generate/preset-2d")
async def generate_preset_2d(body: Preset2DGenerateRequest) -> dict[str, Any]:
	preset = get_2d_preset(body.preset_id)
	if preset is None:
		raise HTTPException(
			status_code=404,
			detail=f"Unknown 2D preset '{body.preset_id}'. Known: {list_2d_preset_ids()}",
		)
	client = _client()
	try:
		return await client.generate_2d_preset(preset, ai_model=body.ai_model)
	except MeshyError as exc:
		raise HTTPException(status_code=502, detail=str(exc)) from exc


@app.post("/generate/pack-2d")
async def generate_pack_2d(body: Pack2DGenerateRequest) -> dict[str, Any]:
	"""Generate Beat Up 2D text-to-image pack (~3 credits/image with nano-banana)."""
	if body.core_pack:
		selected = filter_2d_presets(preset_ids=CORE_2D_PACK_IDS)
	else:
		selected = filter_2d_presets(
			preset_ids=body.preset_ids,
			tags=body.tags,
			groups=body.groups,
		)
	selected = selected[: body.max_assets]
	if not selected:
		raise HTTPException(status_code=400, detail="No 2D presets matched filters.")

	client = _client()
	results: list[dict[str, Any]] = []
	errors: list[dict[str, str]] = []
	for preset in selected:
		try:
			results.append(await client.generate_2d_preset(preset, ai_model=body.ai_model))
		except MeshyError as exc:
			errors.append({"preset_id": preset["id"], "error": str(exc)})

	return {
		"generated": results,
		"errors": errors,
		"output_dir": str(settings.resolved_output_dir() / "2d"),
	}


@app.get("/")
async def root() -> dict[str, str]:
	return {
		"service": "beat-up-meshy",
		"docs": "/docs",
		"health": "/health",
	}

from __future__ import annotations

import asyncio
import json
import re
from pathlib import Path
from typing import Any

import httpx

from .config import Settings, settings


class MeshyError(RuntimeError):
	pass


class MeshyClient:
	def __init__(self, cfg: Settings | None = None) -> None:
		self.cfg = cfg or settings
		if not self.cfg.meshy_api_key:
			raise MeshyError(
				"MESHY_API_KEY missing. Copy services/meshy/.env.example to .env and set your key."
			)
		self._headers = {
			"Authorization": f"Bearer {self.cfg.meshy_api_key}",
			"Content-Type": "application/json",
		}

	def _url(self, path: str) -> str:
		base = self.cfg.meshy_base_url.rstrip("/")
		return f"{base}/{path.lstrip('/')}"

	async def _request(
		self,
		method: str,
		path: str,
		*,
		json: dict[str, Any] | None = None,
		timeout: float = 60.0,
	) -> dict[str, Any]:
		async with httpx.AsyncClient(timeout=timeout) as client:
			response = await client.request(
				method,
				self._url(path),
				headers=self._headers,
				json=json,
			)
		if response.status_code == 401:
			raise MeshyError("Unauthorized — check MESHY_API_KEY (revoke if leaked).")
		if response.status_code == 429:
			raise MeshyError("Rate limited (429). Wait and retry.")
		if response.status_code >= 400:
			detail = response.text[:800]
			raise MeshyError(f"Meshy HTTP {response.status_code}: {detail}")
		data = response.json()
		if not isinstance(data, dict):
			raise MeshyError(f"Unexpected response type: {type(data)}")
		return data

	async def create_text_to_3d(self, payload: dict[str, Any]) -> str:
		data = await self._request("POST", "/v2/text-to-3d", json=payload)
		task_id = data.get("result")
		if not task_id:
			raise MeshyError(f"No task id in response: {data}")
		return str(task_id)

	async def get_text_to_3d(self, task_id: str) -> dict[str, Any]:
		return await self._request("GET", f"/v2/text-to-3d/{task_id}")

	async def create_image_to_3d(self, payload: dict[str, Any]) -> str:
		data = await self._request("POST", "/v1/image-to-3d", json=payload)
		task_id = data.get("result")
		if not task_id:
			raise MeshyError(f"No task id in response: {data}")
		return str(task_id)

	async def get_image_to_3d(self, task_id: str) -> dict[str, Any]:
		return await self._request("GET", f"/v1/image-to-3d/{task_id}")

	async def create_text_to_image(self, payload: dict[str, Any]) -> str:
		data = await self._request("POST", "/v1/text-to-image", json=payload)
		task_id = data.get("result")
		if not task_id:
			raise MeshyError(f"No task id in response: {data}")
		return str(task_id)

	async def get_text_to_image(self, task_id: str) -> dict[str, Any]:
		return await self._request("GET", f"/v1/text-to-image/{task_id}")

	async def get_balance(self) -> dict[str, Any]:
		return await self._request("GET", "/v1/balance")

	async def poll_task(
		self,
		getter,
		task_id: str,
		*,
		interval: float | None = None,
		timeout: float | None = None,
	) -> dict[str, Any]:
		interval = interval if interval is not None else self.cfg.poll_interval_sec
		timeout = timeout if timeout is not None else self.cfg.poll_timeout_sec
		elapsed = 0.0
		while elapsed <= timeout:
			task = await getter(task_id)
			status = str(task.get("status", ""))
			if status in ("SUCCEEDED", "FAILED", "CANCELED"):
				if status != "SUCCEEDED":
					err = (task.get("task_error") or {}).get("message") or status
					raise MeshyError(f"Task {task_id} {status}: {err}")
				return task
			await asyncio.sleep(interval)
			elapsed += interval
		raise MeshyError(f"Task {task_id} timed out after {timeout}s")

	async def download_file(self, url: str, dest: Path) -> Path:
		dest.parent.mkdir(parents=True, exist_ok=True)
		async with httpx.AsyncClient(timeout=120.0, follow_redirects=True) as client:
			response = await client.get(url)
		response.raise_for_status()
		dest.write_bytes(response.content)
		return dest

	async def save_model_urls(
		self,
		task: dict[str, Any],
		dest_dir: Path,
		stem: str,
		*,
		formats: tuple[str, ...] = ("glb",),
	) -> dict[str, str]:
		urls = task.get("model_urls") or {}
		saved: dict[str, str] = {}
		for fmt in formats:
			url = urls.get(fmt)
			if not url:
				continue
			path = await self.download_file(url, dest_dir / f"{stem}.{fmt}")
			saved[fmt] = str(path)
		thumb = task.get("thumbnail_url")
		if thumb:
			path = await self.download_file(thumb, dest_dir / f"{stem}_preview.png")
			saved["preview"] = str(path)
		if not saved:
			raise MeshyError("No downloadable model_urls in task result.")
		return saved

	async def text_to_3d_preview_and_refine(
		self,
		prompt: str,
		stem: str,
		*,
		art_style: str = "realistic",
		enable_pbr: bool = True,
		should_remesh: bool = True,
		texture_prompt: str | None = None,
		ai_model: str = "latest",
		refine: bool = True,
	) -> dict[str, Any]:
		out = self.cfg.resolved_output_dir() / stem
		out.mkdir(parents=True, exist_ok=True)

		preview_id = await self.create_text_to_3d(
			{
				"mode": "preview",
				"prompt": prompt,
				"art_style": art_style,
				"should_remesh": should_remesh,
				"ai_model": ai_model,
			}
		)
		preview_task = await self.poll_task(self.get_text_to_3d, preview_id)
		files = await self.save_model_urls(preview_task, out, f"{stem}_preview")

		result: dict[str, Any] = {
			"kind": "text-to-3d",
			"stem": stem,
			"preview_task_id": preview_id,
			"files": files,
			"prompt": prompt,
		}

		if not refine:
			return result

		refine_payload: dict[str, Any] = {
			"mode": "refine",
			"preview_task_id": preview_id,
			"enable_pbr": enable_pbr,
			"ai_model": ai_model,
		}
		if texture_prompt:
			refine_payload["texture_prompt"] = texture_prompt

		refine_id = await self.create_text_to_3d(refine_payload)
		refine_task = await self.poll_task(self.get_text_to_3d, refine_id)
		refined_files = await self.save_model_urls(refine_task, out, f"{stem}_refined")
		result["refine_task_id"] = refine_id
		result["files"].update({f"refined_{k}": v for k, v in refined_files.items()})
		return result

	async def image_to_3d(
		self,
		image_url: str,
		stem: str,
		*,
		should_texture: bool = True,
		enable_pbr: bool = True,
		ai_model: str = "latest",
	) -> dict[str, Any]:
		out = self.cfg.resolved_output_dir() / stem
		out.mkdir(parents=True, exist_ok=True)
		task_id = await self.create_image_to_3d(
			{
				"image_url": image_url,
				"should_texture": should_texture,
				"enable_pbr": enable_pbr,
				"ai_model": ai_model,
			}
		)
		task = await self.poll_task(self.get_image_to_3d, task_id)
		files = await self.save_model_urls(task, out, stem)
		return {
			"kind": "image-to-3d",
			"stem": stem,
			"task_id": task_id,
			"files": files,
			"image_url": image_url,
		}

	async def save_image_urls(
		self,
		task: dict[str, Any],
		dest_dir: Path,
		stem: str,
	) -> dict[str, str]:
		urls = task.get("image_urls") or []
		if not urls:
			raise MeshyError("No image_urls in text-to-image task result.")
		saved: dict[str, str] = {}
		dest_dir.mkdir(parents=True, exist_ok=True)
		for index, url in enumerate(urls):
			suffix = "" if index == 0 else f"_{index + 1}"
			path = await self.download_file(url, dest_dir / f"{stem}{suffix}.png")
			key = "png" if index == 0 else f"png_{index + 1}"
			saved[key] = str(path)
		return saved

	async def text_to_image(
		self,
		prompt: str,
		stem: str,
		*,
		ai_model: str = "nano-banana",
		aspect_ratio: str = "1:1",
		generate_multi_view: bool = False,
		subdir: str = "2d",
	) -> dict[str, Any]:
		out = self.cfg.resolved_output_dir() / subdir / stem
		out.mkdir(parents=True, exist_ok=True)

		payload: dict[str, Any] = {
			"ai_model": ai_model,
			"prompt": prompt,
		}
		if generate_multi_view:
			payload["generate_multi_view"] = True
		else:
			payload["aspect_ratio"] = aspect_ratio

		task_id = await self.create_text_to_image(payload)
		task = await self.poll_task(self.get_text_to_image, task_id)
		files = await self.save_image_urls(task, out, stem)
		meta_path = out / f"{stem}.json"
		meta_path.write_text(
			json.dumps(
				{
					"task_id": task_id,
					"prompt": prompt,
					"ai_model": ai_model,
					"aspect_ratio": None if generate_multi_view else aspect_ratio,
					"generate_multi_view": generate_multi_view,
					"files": files,
					"consumed_credits": task.get("consumed_credits"),
				},
				indent=2,
			),
			encoding="utf-8",
		)
		return {
			"kind": "text-to-image",
			"stem": stem,
			"task_id": task_id,
			"files": files,
			"prompt": prompt,
			"consumed_credits": task.get("consumed_credits"),
			"meta": str(meta_path),
		}

	async def generate_2d_preset(
		self,
		preset: dict[str, Any],
		*,
		ai_model: str = "nano-banana",
	) -> dict[str, Any]:
		return await self.text_to_image(
			preset["prompt"],
			preset["id"],
			ai_model=ai_model,
			aspect_ratio=preset.get("aspect_ratio", "1:1"),
			generate_multi_view=bool(preset.get("generate_multi_view")),
			subdir="2d",
		)


def slugify(text: str) -> str:
	s = text.lower().strip()
	s = re.sub(r"[^a-z0-9]+", "_", s)
	return s.strip("_")[:64] or "asset"

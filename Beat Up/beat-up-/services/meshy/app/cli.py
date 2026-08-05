from __future__ import annotations

import asyncio
import sys
from pathlib import Path

import typer
from rich import print as rprint

# Allow `python -m app.cli` from services/meshy
ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
	sys.path.insert(0, str(ROOT))

from app.config import settings  # noqa: E402
from app.meshy_client import MeshyClient, MeshyError  # noqa: E402
from app.presets import BEAT_UP_PRESETS, get_preset, list_preset_ids  # noqa: E402
from app.presets_2d import (  # noqa: E402
	BEAT_UP_2D_PRESETS,
	CORE_2D_PACK_IDS,
	filter_2d_presets,
	get_2d_preset,
	list_2d_preset_ids,
)

cli = typer.Typer(help="Beat Up Meshy asset CLI", no_args_is_help=True)


@cli.command("presets")
def cmd_presets() -> None:
	"""List Beat Up 3D asset presets."""
	for preset in BEAT_UP_PRESETS:
		tags = ", ".join(preset["tags"])
		rprint(f"[bold cyan]{preset['id']}[/] - {preset['name']} ({tags})")


@cli.command("presets-2d")
def cmd_presets_2d() -> None:
	"""List Beat Up 2D text-to-image presets."""
	for preset in BEAT_UP_2D_PRESETS:
		tags = ", ".join(preset["tags"])
		mv = " multi-view" if preset["generate_multi_view"] else ""
		rprint(
			f"[bold magenta]{preset['id']}[/] - {preset['name']} "
			f"[{preset['group']}] ({tags}){mv}"
		)


@cli.command("balance")
def cmd_balance() -> None:
	"""Show Meshy credit balance."""

	async def _run() -> None:
		client = MeshyClient()
		data = await client.get_balance()
		rprint(data)

	try:
		asyncio.run(_run())
	except MeshyError as exc:
		rprint(f"[red]{exc}[/]")
		raise typer.Exit(1) from exc


@cli.command("generate")
def cmd_generate(
	preset_id: str = typer.Argument(..., help=f"3D: {', '.join(list_preset_ids())}"),
	refine: bool = typer.Option(True, help="Run preview + refine (uses more credits)"),
	preview_only: bool = typer.Option(False, "--preview-only", help="Skip refine stage"),
) -> None:
	"""Generate one 3D preset and download GLB under assets/generated/."""
	preset = get_preset(preset_id)
	if preset is None:
		rprint(f"[red]Unknown preset:[/] {preset_id}")
		rprint("Known:", ", ".join(list_preset_ids()))
		raise typer.Exit(1)

	do_refine = refine and not preview_only

	async def _run() -> None:
		client = MeshyClient()
		rprint(f"[yellow]Generating[/] {preset['id']} … (poll can take several minutes)")
		result = await client.text_to_3d_preview_and_refine(
			preset["prompt"],
			preset["id"],
			art_style=preset["art_style"],
			texture_prompt=preset["texture_prompt"],
			refine=do_refine,
		)
		rprint("[green]Done[/]", result)

	try:
		asyncio.run(_run())
	except MeshyError as exc:
		rprint(f"[red]{exc}[/]")
		raise typer.Exit(1) from exc


@cli.command("generate-2d")
def cmd_generate_2d(
	preset_id: str = typer.Argument(..., help=f"2D: {', '.join(list_2d_preset_ids())}"),
	ai_model: str = typer.Option("nano-banana", help="nano-banana | nano-banana-2 | …"),
) -> None:
	"""Generate one 2D preset via text-to-image → assets/generated/2d/."""
	preset = get_2d_preset(preset_id)
	if preset is None:
		rprint(f"[red]Unknown 2D preset:[/] {preset_id}")
		rprint("Known:", ", ".join(list_2d_preset_ids()))
		raise typer.Exit(1)

	async def _run() -> None:
		client = MeshyClient()
		rprint(f"[yellow]Generating 2D[/] {preset['id']} …")
		result = await client.generate_2d_preset(preset, ai_model=ai_model)
		rprint("[green]Done[/]", result)

	try:
		asyncio.run(_run())
	except MeshyError as exc:
		rprint(f"[red]{exc}[/]")
		raise typer.Exit(1) from exc


@cli.command("pack")
def cmd_pack(
	tag: list[str] = typer.Option(None, "--tag", help="Filter by tag, e.g. vehicle"),
	ids: list[str] = typer.Option(None, "--id", help="Specific preset ids"),
	max_assets: int = typer.Option(3, help="Safety cap (credits)"),
	preview_only: bool = typer.Option(False, "--preview-only"),
) -> None:
	"""Generate a small pack of 3D presets (default max 3)."""
	selected = list(BEAT_UP_PRESETS)
	if ids:
		selected = [p for p in selected if p["id"] in ids]
	if tag:
		tagset = set(tag)
		selected = [p for p in selected if tagset.intersection(p["tags"])]
	selected = selected[:max_assets]
	if not selected:
		rprint("[red]No presets matched[/]")
		raise typer.Exit(1)

	async def _run() -> None:
		client = MeshyClient()
		out = settings.resolved_output_dir()
		rprint(f"Output: {out}")
		for preset in selected:
			rprint(f"[yellow]-> {preset['id']}[/]")
			try:
				result = await client.text_to_3d_preview_and_refine(
					preset["prompt"],
					preset["id"],
					art_style=preset["art_style"],
					texture_prompt=preset["texture_prompt"],
					refine=not preview_only,
				)
				rprint(f"[green]OK[/] {preset['id']}", result.get("files"))
			except MeshyError as exc:
				rprint(f"[red]FAIL {preset['id']}:[/] {exc}")

	asyncio.run(_run())


@cli.command("pack-2d")
def cmd_pack_2d(
	tag: list[str] = typer.Option(None, "--tag", help="Filter by tag"),
	group: list[str] = typer.Option(
		None, "--group", help="tiles | vehicles | props | ui"
	),
	ids: list[str] = typer.Option(None, "--id", help="Specific 2D preset ids"),
	core: bool = typer.Option(False, "--core", help="Full Beat Up 2D game pack"),
	max_assets: int = typer.Option(20, help="Safety cap"),
	ai_model: str = typer.Option("nano-banana"),
) -> None:
	"""Generate 2D text-to-image pack (~3 credits each with nano-banana)."""
	if core:
		selected = filter_2d_presets(preset_ids=CORE_2D_PACK_IDS)
	else:
		selected = filter_2d_presets(preset_ids=ids or None, tags=tag or None, groups=group or None)
	selected = selected[:max_assets]
	if not selected:
		rprint("[red]No 2D presets matched[/]")
		raise typer.Exit(1)

	async def _run() -> None:
		client = MeshyClient()
		out = settings.resolved_output_dir() / "2d"
		rprint(f"Output: {out}")
		rprint(f"Assets: {len(selected)} | model={ai_model}")
		ok = 0
		for preset in selected:
			rprint(f"[yellow]-> {preset['id']}[/] ({preset['group']})")
			try:
				result = await client.generate_2d_preset(preset, ai_model=ai_model)
				ok += 1
				rprint(f"[green]OK[/] {preset['id']}", result.get("files"))
			except MeshyError as exc:
				rprint(f"[red]FAIL {preset['id']}:[/] {exc}")
		rprint(f"[bold]Finished {ok}/{len(selected)}[/]")

	asyncio.run(_run())


@cli.command("serve")
def cmd_serve(
	host: str = typer.Option(None),
	port: int = typer.Option(None),
) -> None:
	"""Start the FastAPI microservice."""
	import uvicorn

	uvicorn.run(
		"app.main:app",
		host=host or settings.host,
		port=port or settings.port,
		reload=False,
	)


if __name__ == "__main__":
	cli()

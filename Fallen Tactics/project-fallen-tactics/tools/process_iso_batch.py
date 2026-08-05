# -*- coding: utf-8 -*-
"""Batch process isometric assets from latest Imagine session images."""
from __future__ import annotations

from pathlib import Path

from process_iso_assets import chroma_key, diamond_mask, make_preview, make_tile, make_unit

ROOT = Path(r"C:\Users\plugify\Documents\project-fallen-tactics")
SESS = Path(r"C:\Users\plugify\.grok\sessions")


def latest_images() -> dict[str, Path]:
    hits = list(SESS.rglob("images/*.jpg")) + list(SESS.rglob("images/*.png"))
    hits.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    by: dict[str, Path] = {}
    for h in hits:
        by.setdefault(h.name, h)
    return by


def main() -> None:
    by = latest_images()
    # Prefer highest numbers from current session for new gens
    # 5,6 = grass/stone gens; 7,8 = unit edits (attack / idle_sw) — verify by size/content later
    grass2 = by.get("5.jpg")
    stone1 = by.get("6.jpg")
    unit_a = by.get("7.jpg")
    unit_b = by.get("8.jpg")

    tile_dir = ROOT / "assets" / "tiles" / "combat"
    unit_dir = ROOT / "assets" / "units" / "espadachim"

    if grass2:
        make_tile(grass2, tile_dir / "grass_02.png")
    if stone1:
        make_tile(stone1, tile_dir / "stone_01.png")

    # Process both unit edits to idle_sw and attack_slash_se.
    # Heuristic: wider bbox after chroma often = attack (sword extended).
    if unit_a and unit_b:
        from PIL import Image

        def width_after(src: Path) -> int:
            im = chroma_key(Image.open(src).convert("RGBA"))
            bb = im.getbbox()
            return 0 if not bb else bb[2] - bb[0]

        w7, w8 = width_after(unit_a), width_after(unit_b)
        print(f"width after chroma 7={w7} 8={w8}")
        if w7 >= w8:
            attack_src, idle_sw_src = unit_a, unit_b
        else:
            attack_src, idle_sw_src = unit_b, unit_a
        make_unit(idle_sw_src, unit_dir / "espadachim_idle_sw.png")
        make_unit(attack_src, unit_dir / "espadachim_attack_slash_se.png")
    elif unit_a:
        make_unit(unit_a, unit_dir / "espadachim_attack_slash_se.png")

    # Preview with existing se idle + grass_01
    grass = tile_dir / "grass_01.png"
    stone = tile_dir / "stone_01.png"
    unit = unit_dir / "espadachim_idle_se.png"
    if grass.exists() and unit.exists():
        make_preview(grass, unit, ROOT / "assets" / "_preview_iso_pivot.png")

    # Extra preview: attack pose
    atk = unit_dir / "espadachim_attack_slash_se.png"
    if grass.exists() and atk.exists():
        make_preview(grass, atk, ROOT / "assets" / "_preview_attack_slash_se.png")

    # Preview SW
    sw = unit_dir / "espadachim_idle_sw.png"
    if grass.exists() and sw.exists():
        make_preview(grass, sw, ROOT / "assets" / "_preview_idle_sw.png")

    print("Batch done.")
    for p in [
        tile_dir / "grass_02.png",
        tile_dir / "stone_01.png",
        unit_dir / "espadachim_idle_sw.png",
        unit_dir / "espadachim_attack_slash_se.png",
    ]:
        print(" ", "OK" if p.exists() else "MISSING", p.name, p.stat().st_size if p.exists() else 0)


if __name__ == "__main__":
    main()

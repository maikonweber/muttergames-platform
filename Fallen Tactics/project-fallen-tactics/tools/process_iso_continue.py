# -*- coding: utf-8 -*-
"""Process new tiles + enemy units from Imagine session into project assets."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

from process_iso_assets import chroma_key, make_tile, make_unit

ROOT = Path(r"C:\Users\plugify\Documents\project-fallen-tactics")
SESS = Path(r"C:\Users\plugify\.grok\sessions")
TILE_DIR = ROOT / "assets" / "tiles" / "combat"
UNIT_ROOT = ROOT / "assets" / "units"


def session_images() -> dict[str, Path]:
    hits = list(SESS.rglob("images/*.jpg")) + list(SESS.rglob("images/*.png"))
    hits.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    by: dict[str, Path] = {}
    for h in hits:
        by.setdefault(h.name, h)
    return by


def avg_rgb(path: Path, mode: str = "tile") -> tuple[float, float, float]:
    im = Image.open(path).convert("RGBA")
    if mode == "unit":
        im = chroma_key(im)
    w, h = im.size
    px = im.load()
    rs = gs = bs = n = 0
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b, a = px[x, y]
            if a < 40:
                continue
            # skip near-green for units
            if mode == "unit" and g > r + 30 and g > b + 30:
                continue
            rs += r
            gs += g
            bs += b
            n += 1
    if n == 0:
        return (0, 0, 0)
    return (rs / n, gs / n, bs / n)


def classify_tile(rgb: tuple[float, float, float]) -> str:
    r, g, b = rgb
    # water: blue dominant
    if b > r + 15 and b > g:
        return "water_01"
    # pit: very dark
    if (r + g + b) / 3 < 55:
        return "pit_01"
    # elevated: brown/ochre (r and g mid, b lower)
    if r > 80 and g > 60 and r >= g and b < g:
        if r > g + 5:
            return "elevated_01"
    # wall: dark purple-grey low sat
    if abs(r - g) < 25 and abs(g - b) < 30 and (r + g + b) / 3 < 90:
        return "wall_01"
    # elevated fallback ochre-ish
    if r > g and g > b and r > 90:
        return "elevated_01"
    if b > g:
        return "water_01"
    return "wall_01"


def classify_unit(rgb: tuple[float, float, float]) -> str:
    r, g, b = rgb
    # goblin green
    if g > r + 10 and g > b + 10:
        return "goblin"
    # archer gold/yellow
    if r > 120 and g > 90 and b < 100 and r >= g:
        return "arqueiro"
    # captain red
    if r > g + 20 and r > b + 15:
        return "capitao"
    # orc rust orange
    if r > 100 and g < r and b < g + 20:
        return "orc"
    # defaults by remaining
    if g > r and g > b:
        return "goblin"
    if r > 140:
        return "capitao"
    return "orc"


def main() -> None:
    by = session_images()
    # Tiles expected as 9-12
    tile_srcs = [by[n] for n in ("9.jpg", "10.jpg", "11.jpg", "12.jpg") if n in by]
    used_names: set[str] = set()
    for src in tile_srcs:
        rgb = avg_rgb(src, "tile")
        name = classify_tile(rgb)
        # avoid collisions
        base = name
        i = 2
        while name in used_names:
            name = f"{base}_{i}"
            i += 1
        used_names.add(name)
        # normalize known names
        if not name.endswith("_01") and "_" not in name.replace("elevated_01", "e"):
            pass
        out_name = name if name.endswith(".png") else f"{name}.png"
        # force standard names if collision free
        print(f"tile {src.name} rgb={tuple(round(x) for x in rgb)} -> {out_name}")
        make_tile(src, TILE_DIR / out_name)

    # If classification failed uniqueness, also write by index fallback
    expected = ["water_01.png", "wall_01.png", "pit_01.png", "elevated_01.png"]
    existing = {p.name for p in TILE_DIR.glob("*.png")}
    missing = [e for e in expected if e not in existing]
    if missing and tile_srcs:
        print("missing after classify:", missing)
        # assign remaining sources in order to missing
        for src, name in zip(tile_srcs, expected):
            if name in missing or name not in existing:
                make_tile(src, TILE_DIR / name)
                print("fallback wrote", name)

    # Units 13-16
    unit_srcs = [by[n] for n in ("13.jpg", "14.jpg", "15.jpg", "16.jpg") if n in by]
    assigned: set[str] = set()
    for src in unit_srcs:
        rgb = avg_rgb(src, "unit")
        folder = classify_unit(rgb)
        # unique
        if folder in assigned:
            for alt in ("goblin", "orc", "arqueiro", "capitao"):
                if alt not in assigned:
                    folder = alt
                    break
        assigned.add(folder)
        out = UNIT_ROOT / folder / f"{folder}_idle_se.png"
        print(f"unit {src.name} rgb={tuple(round(x) for x in rgb)} -> {out}")
        make_unit(src, out)

    # Ensure all 4 exist via fallbacks if needed
    for folder in ("goblin", "orc", "arqueiro", "capitao"):
        p = UNIT_ROOT / folder / f"{folder}_idle_se.png"
        print("exists" if p.exists() else "MISSING", p)

    print("done")


if __name__ == "__main__":
    main()

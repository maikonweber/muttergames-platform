# -*- coding: utf-8 -*-
"""Post-process generated art into engine-ready isometric assets."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(r"C:\Users\plugify\Documents\project-fallen-tactics")
SESSION_IMAGES = Path(
    r"C:\Users\plugify\.grok\sessions\C%3A%5CUsers%5Cplugify"
    r"\019fc004-c324-7773-a61e-42d595a8f839\images"
)
# Fallback if session path encoding differs
if not SESSION_IMAGES.exists():
    # try without URL encoding
    alt = Path(r"C:\Users\plugify\.grok\sessions")
    candidates = list(alt.glob("**/images/1.jpg"))
    if candidates:
        SESSION_IMAGES = candidates[0].parent

OUT_TILE = ROOT / "assets" / "tiles" / "combat" / "grass_01.png"
OUT_UNIT = ROOT / "assets" / "units" / "espadachim" / "espadachim_idle_se.png"
OUT_PREVIEW = ROOT / "assets" / "_preview_iso_pivot.png"


def diamond_mask(w: int, h: int) -> Image.Image:
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)
    # points: top, right, bottom, left
    pts = [(w // 2, 0), (w - 1, h // 2), (w // 2, h - 1), (0, h // 2)]
    draw.polygon(pts, fill=255)
    return mask


def make_tile(src: Path, out: Path, w: int = 128, h: int = 64) -> None:
    im = Image.open(src).convert("RGBA")
    # Center-crop to 2:1 then resize
    sw, sh = im.size
    target_ratio = w / h
    src_ratio = sw / sh
    if src_ratio > target_ratio:
        new_w = int(sh * target_ratio)
        left = (sw - new_w) // 2
        im = im.crop((left, 0, left + new_w, sh))
    else:
        new_h = int(sw / target_ratio)
        top = (sh - new_h) // 2
        im = im.crop((0, top, sw, top + new_h))
    im = im.resize((w, h), Image.Resampling.LANCZOS)

    # If background is not transparent, still force diamond alpha
    mask = diamond_mask(w, h)
    # Soften diamond edge 1px
    mask = mask.filter(ImageFilter.MinFilter(3))
    r, g, b, a = im.split()
    # Boost green grass readability slightly
    rgb = Image.merge("RGB", (r, g, b))
    rgb = ImageEnhance.Color(rgb).enhance(1.05)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.08)
    r, g, b = rgb.split()
    out_im = Image.merge("RGBA", (r, g, b, mask))
    out.parent.mkdir(parents=True, exist_ok=True)
    out_im.save(out, "PNG")
    print(f"Wrote tile {out} {out_im.size}")


def chroma_key(
    im: Image.Image,
    key=(0, 255, 0),
    tol: int = 90,
    spill: float = 0.35,
) -> Image.Image:
    """Remove green (or similar) screen; also kill near-white / checkerboard greys."""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    kr, kg, kb = key
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            # green screen
            dist = abs(r - kr) + abs(g - kg) + abs(b - kb)
            green_dom = g > r + 25 and g > b + 25 and g > 80
            if dist < tol or green_dom:
                px[x, y] = (0, 0, 0, 0)
                continue
            # near white / light grey (studio / checker light)
            if r > 210 and g > 210 and b > 210:
                px[x, y] = (0, 0, 0, 0)
                continue
            # checker dark grey cells
            if abs(r - g) < 12 and abs(g - b) < 12 and 90 < r < 190 and max(r, g, b) - min(r, g, b) < 15:
                # only if near edges-ish? too aggressive - skip unless very flat grey
                if r < 160 and abs(r - 128) < 40:
                    # likely checker mid; only remove if neighbors also grey - simple: skip
                    pass
            # despill green on edges
            if g > r and g > b:
                ng = int(g * (1.0 - spill) + max(r, b) * spill)
                px[x, y] = (r, ng, b, a)
    return im


def make_unit(src: Path, out: Path, size: int = 128) -> None:
    im = Image.open(src).convert("RGBA")
    im = chroma_key(im)
    # Trim to content bbox
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    # Fit into size with padding, feet near bottom-center (~60% height for iso)
    # Scale so max dimension fits with margin
    margin = 6
    max_w = size - margin * 2
    max_h = int(size * 0.78)  # leave room for head in canvas
    iw, ih = im.size
    scale = min(max_w / iw, max_h / ih)
    nw, nh = max(1, int(iw * scale)), max(1, int(ih * scale))
    im = im.resize((nw, nh), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # Place feet near y= size*0.72 (iso pivot)
    px = (size - nw) // 2
    py = int(size * 0.72) - nh
    py = max(margin, min(py, size - nh - margin))
    canvas.paste(im, (px, py), im)

    # Flattened 2:1 oval shadow under feet
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    cx, cy = size // 2, int(size * 0.72)
    sd.ellipse((cx - 22, cy - 8, cx + 22, cy + 8), fill=(0, 0, 0, 70))
    canvas = Image.alpha_composite(shadow, canvas)

    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out, "PNG")
    print(f"Wrote unit {out} {canvas.size} bbox={canvas.getbbox()}")


def make_preview(tile: Path, unit: Path, out: Path) -> None:
    """Preview: few diamonds + unit at pivot for validation."""
    W, H = 128, 64
    preview = Image.new("RGBA", (512, 320), (26, 20, 32, 255))
    tile_im = Image.open(tile).convert("RGBA")
    unit_im = Image.open(unit).convert("RGBA")

    def cell_to_screen(cx: int, cy: int, ox: int = 256, oy: int = 40):
        sx = ox + (cx - cy) * (W // 2)
        sy = oy + (cx + cy) * (H // 2)
        return sx, sy

    # draw 3x3-ish diamonds
    for cy in range(3):
        for cx in range(3):
            sx, sy = cell_to_screen(cx, cy)
            # paste diamond centered: top of diamond at sy - wait, diamond image is the full 128x64
            # center of diamond is at (sx, sy + H/2)? Our formula is usually for center or top.
            # Use center of tile at (sx, sy)
            preview.alpha_composite(tile_im, (sx - W // 2, sy - H // 2))

    # unit on cell 1,1
    ux, uy = cell_to_screen(1, 1)
    # unit pivot feet at center of diamond
    preview.alpha_composite(unit_im, (ux - 64, uy - int(128 * 0.72)))

    # crosshair at pivot
    d = ImageDraw.Draw(preview)
    d.line((ux - 6, uy, ux + 6, uy), fill=(255, 224, 138, 200), width=1)
    d.line((ux, uy - 6, ux, uy + 6), fill=(255, 224, 138, 200), width=1)

    out.parent.mkdir(parents=True, exist_ok=True)
    preview.save(out, "PNG")
    print(f"Wrote preview {out}")


def main() -> None:
    # Prefer edited chroma versions 3=grass, 4=unit when present
    hits = list(Path(r"C:\Users\plugify\.grok\sessions").rglob("images/*.jpg"))
    hits.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    by_name = {}
    for h in hits:
        by_name.setdefault(h.name, h)
    grass_src = by_name.get("3.jpg") or by_name.get("1.jpg")
    unit_src = by_name.get("4.jpg") or by_name.get("2.jpg")
    if not grass_src or not unit_src:
        raise SystemExit(f"sources missing grass={grass_src} unit={unit_src}")
    print("grass", grass_src)
    print("unit", unit_src)

    make_tile(grass_src, OUT_TILE)
    make_unit(unit_src, OUT_UNIT)
    make_preview(OUT_TILE, OUT_UNIT, OUT_PREVIEW)


if __name__ == "__main__":
    main()

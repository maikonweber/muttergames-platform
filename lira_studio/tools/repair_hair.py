"""Repair broken hair layers without rewriting face artwork.

The shipped hair_front/hair_back split is a hard partition of hair_full, so the
crown sits in front of the face while the rest sits behind it and gets chopped.
This rebuilds a seamless pair from hair_full and removes leftover cutout dust.
"""

from __future__ import annotations

from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "assets" / "models"
PREVIEWS = ROOT / "tools" / "_mask_review"


def load_rgba(path: Path) -> np.ndarray:
    return np.array(Image.open(path).convert("RGBA"))


def save_rgba(path: Path, arr: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(arr, "RGBA").save(path)


def checker(h: int, w: int) -> np.ndarray:
    yy, xx = np.ogrid[:h, :w]
    cell = ((xx // 32) + (yy // 32)) % 2
    tone = np.where(cell[..., None] == 0, 214, 92).astype(np.uint8)
    return np.repeat(tone, 3, axis=2)


def over(dst: np.ndarray, src: np.ndarray) -> np.ndarray:
    a = src[..., 3:4].astype(np.float32) / 255.0
    out = dst.astype(np.float32) * (1.0 - a) + src[..., :3].astype(np.float32) * a
    return np.clip(out, 0, 255).astype(np.uint8)


def largest_alpha(alpha: np.ndarray, floor: int) -> np.ndarray:
    binary = (alpha >= floor).astype(np.uint8)
    num, labels, stats, _ = cv2.connectedComponentsWithStats(binary, 8)
    if num <= 1:
        return np.zeros(alpha.shape, dtype=bool)
    idx = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    return labels == idx


def despill_hair(hair: np.ndarray) -> np.ndarray:
    rgb = hair[..., :3].astype(np.float32)
    alpha = hair[..., 3].astype(np.float32)
    max_rb = np.maximum(rgb[..., 0], rgb[..., 2])
    spill = np.clip(rgb[..., 1] - max_rb, 0, None)
    luma = rgb.mean(axis=2)
    # Opaque chroma leftover is the visible hairline (alpha 255 was skipped before).
    rgb[..., 1] = np.clip(rgb[..., 1] - spill, 0, 255)
    still = (alpha >= 8) & (rgb[..., 1] > max_rb + 1.0)
    rgb[..., 1] = np.where(still, max_rb, rgb[..., 1])
    edge = (alpha >= 4) & (alpha < 248)
    solid = alpha >= 200
    if solid.any():
        interior = float(np.median(luma[solid]))
        pale = edge & (luma > interior + 28.0) & (alpha < 210)
        rgb[pale] *= 0.42
        alpha = np.where(pale, alpha * 0.22, alpha)
    leftover = edge & (spill > 6)
    alpha = np.where(leftover, alpha * 0.35, alpha)
    out = hair.copy()
    out[..., :3] = rgb.astype(np.uint8)
    out[..., 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return out


def tighten_hair(hair: np.ndarray) -> np.ndarray:
    alpha = hair[..., 3]
    keep = largest_alpha(alpha, 18)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    keep = cv2.morphologyEx(keep.astype(np.uint8), cv2.MORPH_CLOSE, kernel).astype(bool)
    # Fill pinholes inside the hair mass, but never the face opening.
    filled = cv2.morphologyEx(keep.astype(np.uint8), cv2.MORPH_CLOSE, np.ones((3, 3), np.uint8))
    holes = (filled > 0) & (~keep)
    if holes.any():
        ys, xs = np.where(keep)
        if ys.size:
            cy = 0.5 * (ys.min() + ys.max())
            # Ignore the large inner opening around the face.
            inner = holes & (np.arange(keep.shape[0])[:, None] > cy)
            keep |= holes & (~inner)
    out = hair.copy()
    out[..., 3] = np.where(keep, np.maximum(alpha, filled * 8), 0).astype(np.uint8)
    # Soften crunchy 1px fringe.
    a = out[..., 3].astype(np.float32)
    a = cv2.GaussianBlur(a, (0, 0), 0.45)
    a = np.where(keep, np.maximum(a, out[..., 3]), 0)
    out[..., 3] = np.clip(a, 0, 255).astype(np.uint8)
    return out


def recolor_from_interior(hair: np.ndarray, on: np.ndarray, ring: np.ndarray) -> np.ndarray:
    if not ring.any():
        return hair
    interior = on & (~ring) & (hair[..., 3] >= 120)
    if not interior.any():
        return hair
    kernel = np.ones((9, 9), np.float32)
    count = cv2.filter2D(interior.astype(np.float32), -1, kernel)
    rgb = hair[..., :3].astype(np.float32)
    out = hair.copy()
    valid = ring & (count > 4)
    for c in range(3):
        acc = cv2.filter2D(rgb[..., c] * interior.astype(np.float32), -1, kernel)
        mean = np.divide(acc, count, out=np.zeros_like(acc), where=count > 4)
        ch = out[..., c].astype(np.float32)
        ch[valid] = mean[valid]
        out[..., c] = np.clip(ch, 0, 255).astype(np.uint8)
    return out


def _hair_regions(alpha: np.ndarray, floor: int = 14) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    on = alpha >= floor
    pad = np.pad(np.where(on, 0, 1).astype(np.uint8), 1, constant_values=1)
    cv2.floodFill(pad, None, (0, 0), 2)
    flags = pad[1:-1, 1:-1]
    return on, flags == 1, flags == 2


def fill_transparent_rgb(hair: np.ndarray) -> np.ndarray:
    """Bleed interior hair RGB into zero-alpha pixels so bilinear sampling cannot pick chroma."""
    out = hair.copy()
    opaque = hair[..., 3] >= 16
    if not opaque.any():
        return hair
    rgb = out[..., :3].astype(np.float32)
    mask = opaque.astype(np.uint8)
    kernel = np.ones((3, 3), np.uint8)
    for _ in range(10):
        dil = cv2.dilate(mask, kernel)
        ring = (dil > 0) & (mask == 0)
        if not ring.any():
            break
        weight = cv2.dilate(mask.astype(np.float32), kernel)
        for c in range(3):
            acc = cv2.dilate(rgb[..., c] * mask, kernel)
            rgb[..., c][ring] = acc[ring] / np.maximum(weight[ring], 1.0)
        mask = dil
    out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    return out


def fix_inner_fringe(hair: np.ndarray, face: np.ndarray) -> np.ndarray:
    alpha = hair[..., 3]
    on, hole, exterior = _hair_regions(alpha)
    ring = on & cv2.dilate(
        hole.astype(np.uint8), cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9)), iterations=1
    ).astype(bool)
    rgb = hair[..., :3].astype(np.float32)
    luma = rgb.mean(axis=2)
    green = rgb[..., 1] - np.maximum(rgb[..., 0], rgb[..., 2])
    interior = on & (~ring) & (alpha >= 160)
    interior_luma = float(np.median(luma[interior])) if interior.any() else 28.0
    junk = ring & ((green > 3) | (np.abs(luma - interior_luma) > 22.0))
    outer = on & cv2.dilate(exterior.astype(np.uint8), np.ones((3, 3), np.uint8), iterations=1).astype(bool)
    outer_junk = outer & ((green > 4) | (luma > interior_luma + 36.0))
    bad = junk | outer_junk
    out = hair.copy()
    if bad.any():
        # Recolor junk from interior first so inpaint cannot spread chroma.
        out = recolor_from_interior(out, on, bad)
        bgr = cv2.cvtColor(out, cv2.COLOR_RGBA2BGR)
        painted = cv2.inpaint(bgr, bad.astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA)
        out[..., :3] = cv2.cvtColor(painted, cv2.COLOR_BGR2RGB)
    out = recolor_from_interior(out, on, ring)
    rgb2 = out[..., :3].astype(np.float32)
    max_rb = np.maximum(rgb2[..., 0], rgb2[..., 2])
    rgb2[..., 1] = np.minimum(rgb2[..., 1], max_rb)
    luma2 = rgb2.mean(axis=2)
    still_pale = ring & (luma2 > interior_luma + 18.0)
    # Let the face's own hairline show through leftover halo.
    out[..., 3] = np.where(still_pale, (alpha.astype(np.float32) * 0.12).astype(np.uint8), alpha)
    out[..., :3] = np.clip(rgb2, 0, 255).astype(np.uint8)
    return out


def close_hair_face_seam(hair: np.ndarray, face: np.ndarray) -> np.ndarray:
    """Grow hair into the hairline crack so the studio background cannot leak through."""
    hair_a = hair[..., 3]
    face_a = face[..., 3]
    hair_on = hair_a >= 24
    face_on = face_a >= 24
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    grown = cv2.dilate(hair_on.astype(np.uint8), kernel, iterations=1).astype(bool)
    near_face = cv2.dilate(face_on.astype(np.uint8), np.ones((11, 11), np.uint8)).astype(bool)
    fill = grown & (~hair_on) & near_face
    if not fill.any():
        return hair
    out = hair.copy()
    rgb = out[..., :3].astype(np.float32)
    mask = hair_on.astype(np.uint8)
    weight = cv2.dilate(mask.astype(np.float32), kernel)
    for c in range(3):
        acc = cv2.dilate(rgb[..., c] * mask, kernel)
        rgb[..., c][fill] = acc[fill] / np.maximum(weight[fill], 1.0)
    max_rb = np.maximum(rgb[..., 0], rgb[..., 2])
    rgb[..., 1] = np.minimum(rgb[..., 1], max_rb)
    out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    out[..., 3] = np.where(fill, np.maximum(hair_a, 230), hair_a).astype(np.uint8)
    return out


def close_face_gap(face: np.ndarray, hair: np.ndarray) -> np.ndarray:
    """Grow skin a couple of pixels into leftover holes along the hairline."""
    face_a = face[..., 3]
    hair_on = hair[..., 3] >= 24
    face_on = face_a >= 24
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    grown = cv2.dilate(face_on.astype(np.uint8), kernel, iterations=1).astype(bool)
    near_hair = cv2.dilate(hair_on.astype(np.uint8), np.ones((7, 7), np.uint8)).astype(bool)
    fill = grown & (~face_on) & near_hair & (~hair_on)
    if not fill.any():
        return face
    out = face.copy()
    rgb = out[..., :3].astype(np.float32)
    mask = face_on.astype(np.uint8)
    weight = cv2.dilate(mask.astype(np.float32), kernel)
    for c in range(3):
        acc = cv2.dilate(rgb[..., c] * mask, kernel)
        rgb[..., c][fill] = acc[fill] / np.maximum(weight[fill], 1.0)
    out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    out[..., 3] = np.where(fill, 255, face_a).astype(np.uint8)
    return out


def paint_inner_hairline(hair: np.ndarray, face: np.ndarray) -> np.ndarray:
    """Recolor the hair/face contact ring to interior hair and feather it into the skin."""
    alpha = hair[..., 3]
    on = alpha >= 20
    face_on = face[..., 3] >= 80
    if not on.any() or not face_on.any():
        return hair
    near_face = cv2.dilate(
        face_on.astype(np.uint8), cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9)), iterations=1
    ).astype(bool)
    hair_edge = on & cv2.dilate((~on).astype(np.uint8), cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))).astype(bool)
    rgb0 = hair[..., :3].astype(np.float32)
    olive = (
        on
        & near_face
        & (rgb0[..., 1] >= rgb0[..., 0] - 18.0)
        & (rgb0[..., 1] > rgb0[..., 2] + 16.0)
    )
    luma0 = rgb0.mean(axis=2)
    interior_luma_src = on & (~near_face) & (alpha >= 180)
    pale = np.zeros(on.shape, dtype=bool)
    if interior_luma_src.any():
        pale = on & near_face & (luma0 > float(np.median(luma0[interior_luma_src])) + 26.0)
    contact = (hair_edge & near_face) | olive | pale
    interior = on & (~contact) & (alpha >= 180)
    if not interior.any():
        interior = on & (~contact) & (alpha >= 80)
    if not contact.any() or not interior.any():
        return hair
    out = recolor_from_interior(hair, on, contact)
    rgb = out[..., :3].astype(np.float32)
    median = np.median(rgb[interior], axis=0)
    mix = contact.astype(np.float32)[..., None]
    rgb = rgb * (1.0 - mix * 0.88) + median * (mix * 0.88)
    max_rb = np.maximum(rgb[..., 0], rgb[..., 2])
    rgb[..., 1] = np.minimum(rgb[..., 1], max_rb * 0.88)
    out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    dist = cv2.distanceTransform(on.astype(np.uint8), cv2.DIST_L2, 5)
    fade = np.clip(dist / 4.0, 0.0, 1.0)
    a = alpha.astype(np.float32)
    a = np.where(hair_edge & near_face, a * np.clip(0.45 + 0.55 * fade, 0.35, 1.0), a)
    out[..., 3] = np.clip(a, 0, 255).astype(np.uint8)
    return out


def split_hair(hair: np.ndarray, face: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Front is the complete silhouette. Back only shows around the head."""
    front = hair.copy()
    back = hair.copy()
    face_a = face[..., 3]
    # Hide hair that would sit behind opaque skin; keep a halo for flyaways.
    cover = cv2.erode((face_a >= 140).astype(np.uint8), np.ones((9, 9), np.uint8), iterations=1).astype(bool)
    back[cover] = 0
    return back, front


def recover_punched_face(face: np.ndarray, hair: np.ndarray) -> np.ndarray:
    """Restore portrait pixels whose alpha was zeroed but RGB is still intact."""
    rgb = face[..., :3].astype(np.float32)
    alpha = face[..., 3]
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    magenta = (b + 8.0 >= g) & (r > 115.0) & (rgb.mean(axis=2) > 85.0) & (b > 70.0)
    ghost = (alpha < 8) & (rgb.max(axis=2) > 18) & (~magenta)
    recover = ghost & (hair[..., 3] >= 16)
    out = face.copy()
    out[..., 3] = np.where(recover, 255, alpha)
    return out


def clean_face_dust(face: np.ndarray, hair: np.ndarray) -> np.ndarray:
    alpha = face[..., 3]
    binary = (alpha >= 40).astype(np.uint8)
    num, labels, stats, _ = cv2.connectedComponentsWithStats(binary, 8)
    keep = np.zeros(alpha.shape, dtype=bool)
    for i in range(1, num):
        if stats[i, cv2.CC_STAT_AREA] >= 400:
            keep |= labels == i
    keep |= alpha >= 220
    out = face.copy()
    out[..., 3] = np.where(keep, alpha, 0).astype(np.uint8)
    return out


def crop_preview(img: np.ndarray, alpha_src: np.ndarray) -> np.ndarray:
    ys, xs = np.where(alpha_src >= 12)
    pad = 12
    return img[
        max(int(ys.min()) - pad, 0) : min(int(ys.max()) + pad, img.shape[0]),
        max(int(xs.min()) - pad, 0) : min(int(xs.max()) + pad, img.shape[1]),
    ]


def process_model(mid: str) -> None:
    base = MODELS / mid
    face_path = base / f"base/{mid}_face_base_v1.png"
    full_path = base / f"hair/{mid}_hair_full_v1.png"
    back_path = base / f"hair/{mid}_hair_back_v1.png"
    front_path = base / f"hair/{mid}_hair_front_v1.png"
    face = load_rgba(face_path)
    hair = despill_hair(load_rgba(full_path))
    hair = tighten_hair(hair)
    hair = fix_inner_fringe(hair, face)
    hair = despill_hair(hair)
    hair = fill_transparent_rgb(hair)
    hair = close_hair_face_seam(hair, face)
    hair = paint_inner_hairline(hair, face)
    hair = despill_hair(hair)
    face = close_face_gap(face, hair)
    face = clean_face_dust(recover_punched_face(face, hair), hair)
    back, front = split_hair(hair, face)
    back = fill_transparent_rgb(despill_hair(back))
    front = fill_transparent_rgb(despill_hair(front))
    save_rgba(full_path, hair)
    save_rgba(back_path, back)
    save_rgba(front_path, front)
    save_rgba(face_path, face)

    bg = checker(*face.shape[:2])
    game = over(over(over(bg, back), face), front)
    PREVIEWS.mkdir(parents=True, exist_ok=True)
    Image.fromarray(crop_preview(game, np.maximum(face[..., 3], hair[..., 3]))).save(
        PREVIEWS / f"{mid}_hair_fixed.png"
    )
    ys, xs = np.where(hair[..., 3] >= 40)
    if ys.size:
        y_line = int(np.percentile(ys, 22))
        x_mid = int(0.5 * (xs.min() + xs.max()))
        band = game[max(y_line - 40, 0) : y_line + 70, max(x_mid - 160, 0) : x_mid + 160]
        Image.fromarray(band).save(PREVIEWS / f"{mid}_hair_line.png")
    print(
        f"{mid}: hair={int((hair[..., 3] >= 16).sum())} "
        f"front={int((front[..., 3] >= 16).sum())} "
        f"back={int((back[..., 3] >= 16).sum())} "
        f"face={int((face[..., 3] >= 16).sum())}"
    )


def main() -> None:
    for mid in ["model_01", "model_02", "model_03", "model_04"]:
        process_model(mid)


if __name__ == "__main__":
    main()

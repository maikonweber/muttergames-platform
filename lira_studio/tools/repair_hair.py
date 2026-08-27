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
    green = rgb[..., 1] - np.maximum(rgb[..., 0], rgb[..., 2])
    luma = rgb.mean(axis=2)
    edge = (alpha >= 4) & (alpha < 248)
    spill = np.clip(green, 0, None)
    rgb[..., 1] = np.clip(rgb[..., 1] - spill * edge.astype(np.float32), 0, 255)
    # White / studio fringe: bright edge pixels that are not interior hair.
    solid = alpha >= 200
    if solid.any():
        interior = float(np.median(luma[solid]))
        pale = edge & (luma > interior + 28.0) & (alpha < 210)
        rgb[pale] *= 0.42
        alpha = np.where(pale, alpha * 0.22, alpha)
    leftover = edge & (spill > 6)
    alpha = np.where(leftover, alpha * 0.45, alpha)
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


def fix_inner_fringe(hair: np.ndarray, face: np.ndarray) -> np.ndarray:
    alpha = hair[..., 3]
    on = alpha >= 14
    pad = np.pad(np.where(on, 0, 1).astype(np.uint8), 1, constant_values=1)
    cv2.floodFill(pad, None, (0, 0), 2)
    flags = pad[1:-1, 1:-1]
    hole = flags == 1
    exterior = flags == 2
    ring = on & cv2.dilate(hole.astype(np.uint8), np.ones((5, 5), np.uint8), iterations=1).astype(bool)
    rgb = hair[..., :3].astype(np.float32)
    luma = rgb.mean(axis=2)
    green = rgb[..., 1] - np.maximum(rgb[..., 0], rgb[..., 2])
    outer = on & cv2.dilate(exterior.astype(np.uint8), np.ones((3, 3), np.uint8), iterations=1).astype(bool)
    outer_junk = outer & ((luma > 140) | (green > 10))
    bad = ring | outer_junk
    out = hair.copy()
    if bad.any():
        bgr = cv2.cvtColor(hair, cv2.COLOR_RGBA2BGR)
        painted = cv2.inpaint(bgr, bad.astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA)
        out[..., :3] = cv2.cvtColor(painted, cv2.COLOR_BGR2RGB)
        luma2 = out[..., :3].astype(np.float32).mean(axis=2)
        still_pale = ring & (luma2 > 80)
        out[..., 3] = np.where(still_pale, (alpha.astype(np.float32) * 0.18).astype(np.uint8), alpha)
    return recolor_from_interior(out, on, ring)


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
    rgb = face[..., :3]
    alpha = face[..., 3]
    ghost = (alpha < 8) & (rgb.max(axis=2) > 18)
    solid = alpha >= 80
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
    hair = fix_inner_fringe(tighten_hair(despill_hair(load_rgba(full_path))), face)
    face = clean_face_dust(recover_punched_face(face, hair), hair)
    back, front = split_hair(hair, face)
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

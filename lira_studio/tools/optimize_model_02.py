"""Restore model_02 hair and punch leftover studio magenta from the face.

Hair layers are disabled at runtime, so the baked face PNG is what the player
sees. GrabCut left a magenta blob in the puff and punched holes in the crown.
This composites hair_full into junk/holes without covering real skin.
"""

from __future__ import annotations

from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / "assets" / "models" / "model_02"
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


def over_rgb(dst: np.ndarray, src: np.ndarray) -> np.ndarray:
    a = src[..., 3:4].astype(np.float32) / 255.0
    out = dst.astype(np.float32) * (1.0 - a) + src[..., :3].astype(np.float32) * a
    return np.clip(out, 0, 255).astype(np.uint8)


def magenta_mask(arr: np.ndarray) -> np.ndarray:
    rgb = arr[..., :3].astype(np.float32)
    alpha = arr[..., 3]
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    luma = rgb.mean(axis=2)
    return (alpha >= 8) & (b + 8.0 >= g) & (r > 115.0) & (luma > 85.0) & (b > 70.0)


def fill_transparent_rgb(img: np.ndarray) -> np.ndarray:
    out = img.copy()
    opaque = img[..., 3] >= 16
    if not opaque.any():
        return img
    rgb = out[..., :3].astype(np.float32)
    mask = opaque.astype(np.uint8)
    kernel = np.ones((3, 3), np.uint8)
    for _ in range(8):
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


def despill_fringe(img: np.ndarray) -> np.ndarray:
    """Knock down leftover studio-pink along the cutout edge."""
    rgb = img[..., :3].astype(np.float32)
    alpha = img[..., 3].astype(np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    luma = rgb.mean(axis=2)
    on = alpha >= 8
    exterior = ~on
    edge = on & cv2.dilate(exterior.astype(np.uint8), np.ones((5, 5), np.uint8)).astype(bool)
    pale = edge & ((b + 6.0 >= g) | ((luma > 88.0) & (r > 110.0) & (b > 55.0)))
    out = img.copy()
    if pale.any():
        max_rb = np.maximum(r, b)
        rgb[..., 1] = np.minimum(g, max_rb)
        rgb[pale] *= 0.55
        alpha = np.where(pale, alpha * 0.28, alpha)
        out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
        out[..., 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return out


def restore_hair(face: np.ndarray, hair: np.ndarray) -> np.ndarray:
    junk = magenta_mask(face)
    keep_skin = (face[..., 3] >= 16) & (~junk)
    hair_on = hair[..., 3] >= 18
    use_hair = hair_on & (~keep_skin)
    out = face.copy()
    out[use_hair] = hair[use_hair]
    leftover = magenta_mask(out) & (~use_hair)
    out[..., 3] = np.where(leftover, 0, out[..., 3])
    # Close hairline cracks between restored hair and remaining skin.
    hair_now = out[..., 3] >= 18
    face_skin = keep_skin
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
    grown = cv2.dilate(hair_now.astype(np.uint8), kernel, iterations=1).astype(bool)
    near_skin = cv2.dilate(face_skin.astype(np.uint8), np.ones((9, 9), np.uint8)).astype(bool)
    fill = grown & (~hair_now) & near_skin & (~face_skin)
    if fill.any():
        rgb = out[..., :3].astype(np.float32)
        mask = hair_now.astype(np.uint8)
        weight = cv2.dilate(mask.astype(np.float32), kernel)
        for c in range(3):
            acc = cv2.dilate(rgb[..., c] * mask, kernel)
            rgb[..., c][fill] = acc[fill] / np.maximum(weight[fill], 1.0)
        max_rb = np.maximum(rgb[..., 0], rgb[..., 2])
        rgb[..., 1] = np.minimum(rgb[..., 1], max_rb)
        out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
        out[..., 3] = np.where(fill, np.maximum(out[..., 3], 230), out[..., 3])
    return fill_transparent_rgb(despill_fringe(out))


def punch_magenta(img: np.ndarray) -> np.ndarray:
    out = img.copy()
    junk = magenta_mask(out)
    if junk.any():
        alpha = out[..., 3].astype(np.float32)
        dist = cv2.distanceTransform((~junk).astype(np.uint8), cv2.DIST_L2, 5)
        fade = np.clip(dist / 3.0, 0.0, 1.0)
        alpha = np.where(junk, 0.0, alpha * (0.35 + 0.65 * fade))
        # Keep pixels that were never junk.
        alpha = np.where(~junk, out[..., 3], alpha)
        out[..., 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return fill_transparent_rgb(out)


def crop_preview(img: np.ndarray, alpha_src: np.ndarray) -> np.ndarray:
    ys, xs = np.where(alpha_src >= 12)
    pad = 16
    return img[
        max(int(ys.min()) - pad, 0) : min(int(ys.max()) + pad, img.shape[0]),
        max(int(xs.min()) - pad, 0) : min(int(xs.max()) + pad, img.shape[1]),
    ]


def assert_clean(face: np.ndarray, label: str) -> None:
    junk = magenta_mask(face)
    pct = 100.0 * float(junk.mean())
    puff = face[180:320, 430:590]
    puff_on = puff[..., 3] >= 16
    puff_luma = puff[..., :3].mean(axis=2)
    forehead = face[600:680, 470:554]
    forehead_on = forehead[..., 3] >= 16
    forehead_rgb = forehead[..., :3].astype(np.float32)
    if pct >= 1.0:
        raise SystemExit(f"{label}: magenta leftover {pct:.2f}%")
    if puff_on.mean() < 0.55 or (puff_luma[puff_on].mean() if puff_on.any() else 255) > 60:
        raise SystemExit(f"{label}: hair puff still missing or too pale")
    if forehead_on.mean() < 0.85 or forehead_rgb[forehead_on].mean(axis=0)[0] < 90:
        raise SystemExit(f"{label}: forehead skin was overwritten")
    print(
        f"{label}: magenta={pct:.3f}% puff_cover={puff_on.mean():.2f} "
        f"puff_luma={puff_luma[puff_on].mean():.1f} forehead_r={forehead_rgb[forehead_on].mean(axis=0)[0]:.1f}"
    )


def main() -> None:
    face_path = MODEL / "base" / "model_02_face_base_v1.png"
    hair_path = MODEL / "hair" / "model_02_hair_full_v1.png"
    smile_path = MODEL / "expressions" / "model_02_expression_smile_v1.png"
    face = load_rgba(face_path)
    hair = load_rgba(hair_path)
    smile = load_rgba(smile_path)

    PREVIEWS.mkdir(parents=True, exist_ok=True)
    before = over_rgb(checker(*face.shape[:2]), face)
    Image.fromarray(crop_preview(before, np.maximum(face[..., 3], hair[..., 3]))).save(
        PREVIEWS / "model_02_before.png"
    )

    fixed = restore_hair(face, hair)
    assert_clean(fixed, "face")
    save_rgba(face_path, fixed)

    smile_fixed = punch_magenta(smile)
    smile_fixed = restore_hair(smile_fixed, hair)
    assert_clean(smile_fixed, "smile")
    save_rgba(smile_path, smile_fixed)

    after = over_rgb(checker(*fixed.shape[:2]), fixed)
    Image.fromarray(crop_preview(after, fixed[..., 3])).save(PREVIEWS / "model_02_after.png")
    Image.fromarray(crop_preview(over_rgb(checker(*smile_fixed.shape[:2]), smile_fixed), smile_fixed[..., 3])).save(
        PREVIEWS / "model_02_smile_after.png"
    )
    print("wrote", face_path)
    print("wrote", smile_path)


if __name__ == "__main__":
    main()

"""Rebuild eyelid / lash masks from the iris on the face, not the old half-eye overlay."""

from __future__ import annotations

from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "assets" / "models"
PREVIEWS = ROOT / "tools" / "_debug_eyes"

SEARCH_BOXES = {
    "model_01": [(327, 548, 460, 575), (565, 547, 698, 575)],
    "model_02": [(343, 674, 468, 699), (557, 674, 682, 699)],
    "model_03": [(330, 579, 461, 603), (564, 579, 695, 603)],
    "model_04": [(327, 580, 460, 606), (565, 580, 698, 606)],
}

OVERLAY_COLORS = {
    "model_01": np.array([232, 201, 153], dtype=np.float32),
    "model_02": np.array([184, 115, 51], dtype=np.float32),
    "model_03": np.array([180, 128, 70], dtype=np.float32),
    "model_04": np.array([224, 168, 154], dtype=np.float32),
}


def load_rgba(path: Path) -> np.ndarray:
    return np.array(Image.open(path).convert("RGBA"))


def save_rgba(path: Path, arr: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(arr, "RGBA").save(path)


def mask_image(strength: np.ndarray) -> np.ndarray:
    out = np.zeros((*strength.shape, 4), dtype=np.uint8)
    out[..., :3] = 255
    out[..., 3] = np.clip(strength, 0, 255).astype(np.uint8)
    return out


def find_iris(luma: np.ndarray, alpha: np.ndarray, box: tuple[int, int, int, int]) -> np.ndarray:
    x0, y0, x1, y1 = box
    h, w = luma.shape
    sx0, sx1 = max(x0 - 24, 0), min(x1 + 24, w - 1)
    sy0, sy1 = max(y0 - 30, 0), min(y1 + 48, h - 1)
    patch = luma[sy0 : sy1 + 1, sx0 : sx1 + 1].copy()
    patch[alpha[sy0 : sy1 + 1, sx0 : sx1 + 1] < 80] = 255.0
    blur = cv2.GaussianBlur(patch.astype(np.float32), (0, 0), 2.2)
    inner = blur[8:-8, 8:-8]
    yy, xx = np.unravel_index(int(np.argmin(inner)), inner.shape)
    py, px = int(yy + 8 + sy0), int(xx + 8 + sx0)
    thr = float(luma[py, px]) + 58.0
    iris = np.zeros((h, w), dtype=np.uint8)
    y_a, y_b = max(py - 42, 0), min(py + 48, h)
    x_a, x_b = max(px - 72, 0), min(px + 72, w)
    iris[y_a:y_b, x_a:x_b] = (
        (luma[y_a:y_b, x_a:x_b] <= thr) & (alpha[y_a:y_b, x_a:x_b] > 80)
    ).astype(np.uint8)
    iris = cv2.morphologyEx(iris, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5)))
    num, labels, stats, _cents = cv2.connectedComponentsWithStats(iris, 8)
    keep = np.zeros((h, w), dtype=bool)
    if 0 <= py < h and 0 <= px < w:
        idx = int(labels[py, px])
        if idx > 0:
            keep = labels == idx
    if not keep.any() and num > 1:
        biggest = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
        keep = labels == biggest
    # fill small holes so the iris blocks makeup
    keep = cv2.morphologyEx(keep.astype(np.uint8), cv2.MORPH_CLOSE, np.ones((3, 3), np.uint8)).astype(bool)
    return keep


def contour_from_iris(iris: np.ndarray) -> tuple[np.ndarray, int, int, float]:
    h, w = iris.shape
    top = np.full(w, -1, dtype=np.int32)
    if not iris.any():
        return top, 0, 0, 0.0
    xs = np.where(iris.any(axis=0))[0]
    x0, x1 = int(xs.min()), int(xs.max())
    inset = max(int((x1 - x0) * 0.08), 5)
    x0 += inset
    x1 -= inset
    for x in range(x0, x1 + 1):
        col = np.where(iris[:, x])[0]
        if col.size:
            top[x] = int(col.min())
    cx = 0.5 * (x0 + x1)
    return top, x0, x1, cx


def lid_from_iris(face: np.ndarray, iris: np.ndarray, top: np.ndarray, x0: int, x1: int, cx: float) -> np.ndarray:
    h, w = iris.shape
    luma = face[..., :3].astype(np.float32).mean(axis=2)
    alpha = face[..., 3]
    strength = np.zeros((h, w), dtype=np.float32)
    eye_w = max(x1 - x0 + 1, 8)
    lid_h = int(np.clip(eye_w * 0.20, 16, 24))
    blocked = cv2.dilate(iris.astype(np.uint8), np.ones((3, 3), np.uint8), iterations=1).astype(bool)
    for x in range(x0, x1 + 1):
        y_lash = int(top[x])
        if y_lash < 0:
            continue
        nx = (x - cx) / (0.5 * eye_w)
        if abs(nx) >= 1.0:
            continue
        arch = float(np.sqrt(max(1.0 - nx * nx, 0.0)))
        local_h = max(int(lid_h * (0.42 + 0.58 * arch)), 10)
        wing = float(np.exp(-0.5 * (nx / 0.78) ** 2))
        for dy in range(3, local_h + 3):
            y = y_lash - dy
            if y < 0:
                continue
            if blocked[y, x]:
                continue
            if alpha[y, x] < 80:
                continue
            if luma[y, x] < 40:
                continue
            t = (dy - 3) / float(max(local_h - 1, 1))
            bell = float(np.exp(-0.5 * (t / 0.40) ** 2))
            strength[y, x] = max(strength[y, x], 255.0 * wing * bell)
    if strength.max() > 0:
        strength = cv2.GaussianBlur(strength, (0, 0), 0.65)
        strength[blocked] = 0
    return strength


def lash_from_iris(iris: np.ndarray, top: np.ndarray, x0: int, x1: int, cx: float) -> np.ndarray:
    h, w = iris.shape
    out = np.zeros((h, w), dtype=np.float32)
    eye_w = max(x1 - x0 + 1, 8)
    for x in range(x0, x1 + 1):
        y_lash = int(top[x])
        if y_lash < 0:
            continue
        nx = (x - cx) / (0.5 * eye_w)
        if abs(nx) > 1.02:
            continue
        wing = float(np.exp(-0.5 * (nx / 0.84) ** 2))
        for y in range(max(y_lash - 2, 0), min(y_lash + 5, h)):
            t = 1.0 - abs((y - y_lash) / 5.0)
            out[y, x] = max(out[y, x], 220.0 * t * wing)
    if out.max() > 0:
        out = cv2.GaussianBlur(out, (0, 0), 0.45)
    return out


def overlay_from_lid(lid: np.ndarray, color: np.ndarray) -> np.ndarray:
    out = np.zeros((*lid.shape[:2], 4), dtype=np.uint8)
    alpha = lid[..., 3].astype(np.float32)
    if alpha.max() <= 0:
        return out
    fade = alpha / float(alpha.max())
    out[..., 0] = int(color[0])
    out[..., 1] = int(color[1])
    out[..., 2] = int(color[2])
    out[..., 3] = np.clip(fade * 200.0, 0, 255).astype(np.uint8)
    return out


def save_preview(face: np.ndarray, lid_l: np.ndarray, lid_r: np.ndarray, iris: np.ndarray, mid: str) -> None:
    vis = face[..., :3].copy()
    for lid, col in ((lid_l, (255, 40, 170)), (lid_r, (40, 140, 255))):
        a = (lid[..., 3].astype(np.float32) / 255.0) * 0.62
        vis = (vis * (1.0 - a[..., None]) + np.array(col) * a[..., None]).astype(np.uint8)
    im = Image.fromarray(vis)
    dr = ImageDraw.Draw(im)
    num, _labels, stats, _ = cv2.connectedComponentsWithStats(iris.astype(np.uint8), 8)
    for i in range(1, num):
        x, y, bw, bh, area = stats[i]
        if area < 80:
            continue
        dr.rectangle([int(x), int(y), int(x + bw), int(y + bh)], outline=(0, 255, 90), width=2)
    ys, xs = np.where(iris | (lid_l[..., 3] > 16) | (lid_r[..., 3] > 16))
    pad = 50
    crop = im.crop((max(int(xs.min()) - pad, 0), max(int(ys.min()) - pad, 0), min(int(xs.max()) + pad, vis.shape[1]), min(int(ys.max()) + pad, vis.shape[0])))
    crop = crop.resize((crop.size[0] * 2, crop.size[1] * 2), Image.NEAREST)
    PREVIEWS.mkdir(parents=True, exist_ok=True)
    crop.save(PREVIEWS / f"{mid}_lid_zoom.png")


def process_model(mid: str) -> None:
    base = MODELS / mid
    face = load_rgba(base / f"base/{mid}_face_base_v1.png")
    luma = face[..., :3].astype(np.float32).mean(axis=2)
    alpha = face[..., 3]
    iris = np.zeros(luma.shape, dtype=bool)
    lids = []
    lashes = []
    for box in SEARCH_BOXES[mid]:
        eye = find_iris(luma, alpha, box)
        iris |= eye
        top, x0, x1, cx = contour_from_iris(eye)
        lids.append(lid_from_iris(face, eye, top, x0, x1, cx))
        lashes.append(lash_from_iris(eye, top, x0, x1, cx))
    lid_l, lid_r = lids
    lash_l, lash_r = lashes
    masks = base / "masks"
    save_rgba(masks / f"{mid}_eye_l_mask.png", mask_image(lid_l))
    save_rgba(masks / f"{mid}_eye_r_mask.png", mask_image(lid_r))
    save_rgba(masks / f"{mid}_lash_l_mask.png", mask_image(lash_l))
    save_rgba(masks / f"{mid}_lash_r_mask.png", mask_image(lash_r))
    combined = np.maximum(lid_l, lid_r)
    overlay_path = next((base / "makeup/eyeshadow").glob("*overlay*.png"))
    save_rgba(overlay_path, overlay_from_lid(mask_image(combined), OVERLAY_COLORS[mid]))

    lips = load_rgba(masks / f"{mid}_lips_mask.png")
    block = (combined >= 40) | iris | (lips[..., 3] >= 40)
    block = cv2.dilate(
        block.astype(np.uint8),
        cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5)),
        iterations=1,
    ).astype(bool)
    keep = (face[..., 3] >= 96) & (~block)
    save_rgba(masks / f"{mid}_skin_mask.png", mask_image(cv2.GaussianBlur(keep.astype(np.uint8) * 255, (0, 0), 0.8).astype(np.float32)))

    save_preview(face, mask_image(lid_l), mask_image(lid_r), iris, mid)
    rows = int((lid_l >= 32).any(axis=1).sum()) if (lid_l >= 32).any() else 0
    print(f"{mid}: lid_l={(lid_l >= 32).sum()} lid_r={(lid_r >= 32).sum()} iris={int(iris.sum())} lid_h={rows}")


def main() -> None:
    for mid in ["model_01", "model_02", "model_03", "model_04"]:
        process_model(mid)


if __name__ == "__main__":
    main()

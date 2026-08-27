"""Recalibrate makeup masks from catchlights in the face art."""

from __future__ import annotations

from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "assets" / "models"
PREVIEWS = ROOT / "tools" / "_mask_review"

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


def overlay_strength(arr: np.ndarray) -> np.ndarray:
    lum = arr[..., :3].max(axis=2).astype(np.float32)
    alpha = arr[..., 3].astype(np.float32)
    return np.clip(lum * (alpha / 255.0), 0.0, 255.0)


def remap_strength(raw: np.ndarray, floor: float, gamma: float = 0.7) -> np.ndarray:
    strength = np.zeros_like(raw, dtype=np.float32)
    keep = raw >= floor
    if not keep.any():
        return strength
    normalized = (raw[keep] - floor) / max(float(raw[keep].max() - floor), 1.0)
    strength[keep] = np.clip(normalized ** gamma, 0.0, 1.0) * 255.0
    return strength


def largest_component(binary: np.ndarray, seed_xy: tuple[int, int] | None = None) -> np.ndarray:
    num, labels, stats, _ = cv2.connectedComponentsWithStats(binary.astype(np.uint8), 8)
    if num <= 1:
        return np.zeros(binary.shape, dtype=bool)
    if seed_xy is not None:
        sx, sy = seed_xy
        if 0 <= sy < labels.shape[0] and 0 <= sx < labels.shape[1]:
            idx = int(labels[sy, sx])
            if idx > 0:
                return labels == idx
    biggest = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    return labels == biggest


def catchlight_spots(face: np.ndarray) -> list[tuple[int, float, float]]:
    luma = face[..., :3].astype(np.float32).mean(axis=2)
    alpha = face[..., 3]
    h, w = luma.shape
    ys, xs = np.where(alpha > 40)
    fy0, fy1 = int(ys.min()), int(ys.max())
    bright = (luma >= 205) & (alpha > 40)
    bright[: fy0 + int((fy1 - fy0) * 0.16), :] = False
    bright[fy0 + int((fy1 - fy0) * 0.55) :, :] = False
    num, _labels, stats, cents = cv2.connectedComponentsWithStats(bright.astype(np.uint8), 8)
    spots: list[tuple[int, float, float]] = []
    for i in range(1, num):
        _x, _y, bw, bh, area = stats[i]
        if area < 3 or area > 140 or bw > 24 or bh > 24:
            continue
        px, py = float(cents[i][0]), float(cents[i][1])
        y0, y1 = max(int(py) - 18, 0), min(int(py) + 20, h)
        x0, x1 = max(int(px) - 22, 0), min(int(px) + 22, w)
        if luma[y0:y1, x0:x1].min() > 78:
            continue
        spots.append((int(area), px, py))
    spots.sort(reverse=True)
    return spots[:12]


def pick_eye_pair(spots: list[tuple[int, float, float]], width: int) -> tuple[tuple[float, float], tuple[float, float]]:
    best = None
    best_score = -1e9
    for i, (a1, x1, y1) in enumerate(spots):
        for a2, x2, y2 in spots[i + 1 :]:
            xa, ya, xb, yb = x1, y1, x2, y2
            if xa > xb:
                xa, ya, xb, yb = xb, yb, xa, ya
            dx = xb - xa
            dy = abs(yb - ya)
            if dx < 150 or dx > 320 or dy > 20:
                continue
            mid = 0.5 * (xa + xb)
            if abs(mid - width * 0.5) > 100:
                continue
            score = min(a1, a2) * 1.4 - dy * 6.0 - abs(mid - width * 0.5) * 0.25
            if score > best_score:
                best_score = score
                best = ((xa, ya), (xb, yb))
    if best is None:
        raise RuntimeError("could not find a catchlight pair")
    return best


def pupil_from_catch(luma: np.ndarray, cx: float, cy: float) -> tuple[float, float]:
    h, w = luma.shape
    x0, x1 = max(int(cx) - 20, 0), min(int(cx) + 24, w)
    y0, y1 = max(int(cy) - 4, 0), min(int(cy) + 22, h)
    patch = cv2.GaussianBlur(luma[y0:y1, x0:x1], (0, 0), 1.1)
    yy, xx = np.unravel_index(int(np.argmin(patch)), patch.shape)
    return float(xx + x0), float(yy + y0)


def lid_y_from_catch(luma: np.ndarray, chroma: np.ndarray, alpha: np.ndarray, cx: float, cy: float) -> float:
    # Catchlights sit in the upper iris; the lash margin is just above them.
    # Do not walk through dark eyelid skin (breaks on deeper skin tones).
    return float(cy) - 1.0


def is_skin_pixel(rgb: np.ndarray, luma: np.ndarray, alpha: np.ndarray, x: int, y: int) -> bool:
    if alpha[y, x] < 80:
        return False
    red = float(rgb[y, x, 0] - 0.5 * (rgb[y, x, 1] + rgb[y, x, 2]))
    chroma = float(np.std(rgb[y, x]))
    return red > 26.0 and 55.0 < luma[y, x] < 232.0 and chroma > 8.0


def opening_from_pupil(face: np.ndarray, px: float, py: float, ipd: float) -> np.ndarray:
    h, w = face.shape[:2]
    rgb = face[..., :3].astype(np.float32)
    luma = rgb.mean(axis=2)
    chroma = rgb.std(axis=2)
    alpha = face[..., 3]
    ipx, ipy = int(round(px)), int(round(py))
    pupil_l = float(luma[ipy, ipx])

    horiz: list[float] = []
    vert: list[float] = []
    for deg in range(0, 360, 10):
        rad = np.deg2rad(deg)
        c, s = float(np.cos(rad)), float(np.sin(rad))
        last = 10.0
        for r in range(8, 56):
            x = int(round(px + r * c))
            y = int(round(py + r * s))
            if x < 1 or y < 1 or x >= w - 1 or y >= h - 1 or alpha[y, x] < 80:
                last = float(max(r - 2, 8))
                break
            if is_skin_pixel(rgb, luma, alpha, x, y) and r > 14:
                last = float(max(r - 2, 8))
                break
            last = float(r)
        if abs(c) >= abs(s):
            horiz.append(last)
        else:
            vert.append(last)

    ax = float(np.clip(max(np.percentile(horiz, 80) * 1.18, ipd * 0.24), 36.0, 62.0))
    ay = float(np.clip(max(np.percentile(vert, 62) * 0.82, 12.0), 12.0, 20.0))
    yy, xx = np.ogrid[:h, :w]
    ell = ((xx - px) / ax) ** 2 + ((yy - py) / ay) ** 2 <= 1.0
    iris = ell & (alpha > 80) & (luma <= pupil_l + 78.0) & (chroma >= 6.0)
    sclera = ell & (alpha > 80) & (luma > 140.0) & (chroma < 50.0)
    opening = (iris | sclera).astype(np.uint8)
    if opening.sum() < 120:
        opening = ell.astype(np.uint8)
    opening = cv2.morphologyEx(opening, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 3)))
    keep = largest_component(opening, (ipx, ipy))
    keep = cv2.morphologyEx(keep.astype(np.uint8), cv2.MORPH_CLOSE, np.ones((3, 3), np.uint8)).astype(bool)
    # Keep the globe, but don't climb onto the brow.
    keep[: max(ipy - int(ay) - 4, 0), :] = False
    return keep


def smooth_contour(top: np.ndarray, x0: int, x1: int) -> np.ndarray:
    y = top[x0 : x1 + 1].astype(np.float32)
    if y.size < 8:
        return top
    known = y >= 0
    if not known.any():
        return top
    idx = np.arange(y.size)
    y[~known] = np.interp(idx[~known], idx[known], y[known])
    k = 13
    xs = np.arange(k) - k // 2
    kernel = np.exp(-0.5 * (xs / 2.4) ** 2)
    kernel /= kernel.sum()
    pad = np.pad(y, k // 2, mode="edge")
    y2 = np.convolve(pad, kernel, mode="valid")
    out = top.copy()
    out[x0 : x1 + 1] = np.clip(np.round(y2), 0, None).astype(np.int32)
    return out


def contour_from_opening(opening: np.ndarray, face: np.ndarray, px: int, py: int) -> tuple[np.ndarray, int, int, float]:
    h, w = opening.shape
    top = np.full(w, -1, dtype=np.int32)
    if not opening.any():
        return top, 0, 0, 0.0
    xs = np.where(opening.any(axis=0))[0]
    x0, x1 = int(xs.min()), int(xs.max())
    inset = max(int((x1 - x0) * 0.04), 2)
    x0 += inset
    x1 -= inset
    for x in range(x0, x1 + 1):
        col = np.where(opening[:, x])[0]
        top[x] = int(col.min()) if col.size else py
    top = smooth_contour(top, x0, x1)
    return top, x0, x1, 0.5 * (x0 + x1)


def almond_top(width: int, cx: float, y_lash: float, eye_w: float, outer_sign: float) -> tuple[np.ndarray, int, int]:
    top = np.full(width, -1, dtype=np.int32)
    ax = max(eye_w * 0.62, 48.0)
    x0 = int(round(cx - ax))
    x1 = int(round(cx + ax))
    for x in range(max(x0, 0), min(x1, width - 1) + 1):
        t = (x - cx) / ax
        if abs(t) > 1.0:
            continue
        outer = t * outer_sign
        drop = 3.2 * (t * t)
        wing = 2.2 * max(outer, 0.0) ** 1.45
        top[x] = int(round(y_lash + drop + wing - 1.0))
    xs = np.where(top >= 0)[0]
    if xs.size == 0:
        return top, 0, 0
    return top, int(xs.min()), int(xs.max())


def _contour_line(top: np.ndarray, x0: int, x1: int, width: int, extra: int) -> tuple[np.ndarray, int, int]:
    xa = max(x0 - extra, 0)
    xb = min(x1 + extra, width - 1)
    line = np.full(width, np.nan, dtype=np.float32)
    known = [x for x in range(x0, x1 + 1) if top[x] >= 0]
    if not known:
        return line, xa, xb
    ys = np.array([float(top[x]) for x in known], dtype=np.float32)
    xs = np.array(known, dtype=np.float32)
    for x in range(xa, xb + 1):
        line[x] = float(np.interp(x, xs, ys))
    k = 9
    kernel = np.exp(-0.5 * ((np.arange(k) - k // 2) / 1.8) ** 2)
    kernel /= kernel.sum()
    pad = np.pad(line[xa : xb + 1], k // 2, mode="edge")
    line[xa : xb + 1] = np.convolve(pad, kernel, mode="valid")
    return line, xa, xb


def lid_from_opening(
    face: np.ndarray,
    opening: np.ndarray,
    top: np.ndarray,
    x0: int,
    x1: int,
    cx: float,
    outer_sign: float,
    ipd: float,
    pupil_y: float,
) -> np.ndarray:
    h, w = opening.shape
    strength = np.zeros((h, w), dtype=np.float32)
    if x1 <= x0:
        return strength
    extra = max(int((x1 - x0) * 0.14), 10)
    line, xa, xb = _contour_line(top, x0, x1, w, extra)
    if not np.isfinite(line[xa : xb + 1]).any():
        return strength
    span = max(xb - xa, 1)
    ay = float(np.clip(span * 0.16, 12.0, 19.0))
    t = (np.arange(w, dtype=np.float32) - xa) / float(span)
    window_1d = np.clip(1.0 - 0.92 * ((t - 0.5) / 0.5) ** 2, 0.0, 1.0) ** 0.22
    window_1d[:xa] = 0
    window_1d[xb + 1 :] = 0
    globe = cv2.erode(opening.astype(np.uint8), np.ones((5, 5), np.uint8), iterations=1).astype(bool)
    alpha = face[..., 3]
    for x in range(xa, xb + 1):
        if not np.isfinite(line[x]) or window_1d[x] < 0.08:
            continue
        y_m = int(round(float(line[x])))
        lid_h = max(int(round(ay * (0.55 + 0.45 * window_1d[x]))), 7)
        for y in range(max(y_m - lid_h, 0), min(y_m + 2, h)):
            if globe[y, x] or alpha[y, x] < 80:
                continue
            ny = (y_m - y) / float(lid_h)
            fade = float(np.clip(1.0 - ny * ny, 0.0, 1.0))
            strength[y, x] = max(strength[y, x], fade * window_1d[x] * 255.0)
    if strength.max() > 0:
        strength = cv2.GaussianBlur(strength, (0, 0), 0.80)
        strength[globe] = 0
        strength = np.clip(strength / float(strength.max()) * 255.0, 0, 255)
    return strength


def lash_from_opening(
    opening: np.ndarray,
    top: np.ndarray,
    x0: int,
    x1: int,
    pupil_y: float,
    outer_sign: float,
) -> np.ndarray:
    h, w = opening.shape
    out = np.zeros((h, w), dtype=np.float32)
    extra = max(int((x1 - x0) * 0.12), 8)
    line, xa, xb = _contour_line(top, x0, x1, w, extra)
    if not np.isfinite(line[xa : xb + 1]).any():
        return out
    band = np.zeros((h, w), dtype=np.uint8)
    span = max(xb - xa, 1)
    for x in range(xa, xb + 1):
        t = (x - xa) / float(span)
        window = float(np.clip(1.0 - 1.08 * ((t - 0.5) / 0.5) ** 2, 0.0, 1.0) ** 0.28)
        if window < 0.10:
            continue
        y = int(round(float(line[x]) - 0.5))
        y0 = max(y - 2, 0)
        y1b = min(y + 0, h - 1)
        if y1b >= y0:
            band[y0 : y1b + 1, x] = int(round(255 * window))
    out = cv2.GaussianBlur(band.astype(np.float32), (0, 0), 0.40)
    return np.clip(out, 0, 255)


def improve_lips(overlay: np.ndarray, face: np.ndarray) -> np.ndarray:
    raw = overlay_strength(overlay)
    strength = remap_strength(raw, floor=52.0, gamma=0.44)
    rgb = face[..., :3].astype(np.float32)
    red = rgb[..., 0] - 0.5 * (rgb[..., 1] + rgb[..., 2])
    luma = rgb.max(axis=2)
    red_blur = cv2.GaussianBlur(red, (0, 0), 7.0)
    lip_like = (red > red_blur + 4.2) & (face[..., 3] > 80) & (luma > 40)
    strength = np.where(lip_like | (strength >= 80), strength, strength * 0.22)
    binary = (strength >= 48).astype(np.uint8)
    binary = cv2.morphologyEx(binary, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3)))
    binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5)))
    keep = largest_component(binary)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    keep = cv2.erode(keep.astype(np.uint8), kernel, iterations=2)
    keep = cv2.dilate(keep, kernel, iterations=1).astype(bool)
    strength *= keep.astype(np.float32)
    if not np.any(strength >= 40):
        return mask_image(strength)
    ys, xs = np.where(strength >= 40)
    y0, y1, xa, xb = int(ys.min()), int(ys.max()), int(xs.min()), int(xs.max())
    row_luma = []
    for y in range(y0, y1 + 1):
        on = strength[y, xa : xb + 1] >= 40
        row_luma.append(float(luma[y, xa : xb + 1][on].mean()) if on.any() else 255.0)
    crease_y = y0 + int(np.argmin(np.array(row_luma)))
    yy = np.arange(strength.shape[0], dtype=np.float32)[:, None]
    falloff = np.exp(-0.5 * ((yy - crease_y) / 3.0) ** 2)
    strength *= 1.0 - 0.55 * falloff
    strength = cv2.GaussianBlur(strength, (0, 0), 0.65)
    return mask_image(strength)


def blush_from_landmarks(
    face: np.ndarray,
    left: tuple[float, float],
    right: tuple[float, float],
    lips: np.ndarray,
    opening: np.ndarray,
) -> tuple[np.ndarray, np.ndarray]:
    h, w = face.shape[:2]
    rgb = face[..., :3].astype(np.float32)
    luma = rgb.mean(axis=2)
    red = rgb[..., 0] - 0.5 * (rgb[..., 1] + rgb[..., 2])
    alpha = face[..., 3]
    ipd = max(right[0] - left[0], 80.0)
    py = 0.5 * (left[1] + right[1])
    mid_x = 0.5 * (left[0] + right[0])
    lips_y = h
    if lips[..., 3].max() > 20:
        ys = np.where(lips[..., 3] > 24)[0]
        if ys.size:
            lips_y = int(ys.min())
    cy = min(py + ipd * 0.21, lips_y - ipd * 0.28)
    cy = max(cy, py + ipd * 0.16)
    ax = ipd * 0.17
    ay = ipd * 0.16
    yy, xx = np.ogrid[:h, :w]
    out = []
    for side, pupil in enumerate((left, right)):
        outward = -1.0 if side == 0 else 1.0
        cx = pupil[0] + outward * ipd * 0.05
        r2 = ((xx - cx) / ax) ** 2 + ((yy - cy) / ay) ** 2
        pad = np.clip(1.0 - r2, 0.0, 1.0) ** 1.05
        skin = (alpha > 90) & (luma > 42) & (luma < 240)
        strength = pad * 255.0 * skin.astype(np.float32)
        strength *= np.where(np.abs(xx - mid_x) < ipd * 0.12, 0.12, 1.0)
        strength[red < 4] *= 0.45
        block = (lips[..., 3] >= 24) | opening
        block = cv2.dilate(block.astype(np.uint8), cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (17, 17)), iterations=1).astype(bool)
        strength[block] = 0
        if strength.max() > 0:
            strength = cv2.GaussianBlur(strength, (0, 0), 3.2)
            strength[block] = 0
            strength = np.clip(strength / float(strength.max()) * 255.0, 0, 255)
        out.append(mask_image(strength))
    return out[0], out[1]


def improve_skin(face: np.ndarray, lips: np.ndarray, lids: np.ndarray, opening: np.ndarray) -> np.ndarray:
    h, w = face.shape[:2]
    rgb = face[..., :3].astype(np.float32)
    luma = rgb.mean(axis=2)
    keep = face[..., 3] >= 96
    block = (lips[..., 3] >= 32) | (lids >= 28) | opening
    block = cv2.dilate(block.astype(np.uint8), cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7)), iterations=1).astype(bool)
    keep &= ~block
    yy, xx = np.ogrid[:h, :w]
    inner = ((xx - w / 2.0) / (w * 0.16)) ** 2 + ((yy - h * 0.42) / (h * 0.18)) ** 2 <= 1.0
    hair_like = (luma < 58) & (face[..., 3] > 80) & (~inner)
    keep &= ~hair_like
    alpha = cv2.GaussianBlur(keep.astype(np.uint8) * 255, (0, 0), 0.85)
    return mask_image(alpha.astype(np.float32))


def overlay_from_lid(lid: np.ndarray, color: np.ndarray) -> np.ndarray:
    out = np.zeros((*lid.shape[:2], 4), dtype=np.uint8)
    alpha = lid[..., 3].astype(np.float32)
    if alpha.max() <= 0:
        return out
    fade = alpha / float(alpha.max())
    out[..., 0] = int(color[0])
    out[..., 1] = int(color[1])
    out[..., 2] = int(color[2])
    out[..., 3] = np.clip(fade * 190.0, 0, 255).astype(np.uint8)
    return out


def tint(vis: np.ndarray, mask: np.ndarray, color: tuple[float, float, float], amount: float) -> np.ndarray:
    a = (mask[..., 3].astype(np.float32) / 255.0) * amount
    return vis * (1.0 - a[..., None]) + np.array(color) * a[..., None]


def save_preview(face: np.ndarray, lids, lashes, lips, blush, opening: np.ndarray, mid: str) -> np.ndarray:
    vis = face[..., :3].astype(np.float32)
    vis = tint(vis, lids[0], (255, 70, 180), 0.52)
    vis = tint(vis, lids[1], (80, 150, 255), 0.52)
    vis = tint(vis, lashes[0], (40, 255, 230), 0.70)
    vis = tint(vis, lashes[1], (40, 255, 230), 0.70)
    vis = tint(vis, lips, (255, 40, 70), 0.48)
    vis = tint(vis, blush[0], (255, 150, 40), 0.42)
    vis = tint(vis, blush[1], (255, 150, 40), 0.42)
    vis = np.clip(vis, 0, 255).astype(np.uint8)
    ys, xs = np.where(face[..., 3] > 40)
    pad = 24
    crop = vis[
        max(int(ys.min()) - pad, 0) : min(int(ys.max()) + pad, vis.shape[0]),
        max(int(xs.min()) - pad, 0) : min(int(xs.max()) + pad, vis.shape[1]),
    ]
    PREVIEWS.mkdir(parents=True, exist_ok=True)
    Image.fromarray(crop).save(PREVIEWS / f"{mid}_all.png")
    Image.fromarray(vis[int(ys.min()) : int(ys.min() + (ys.max() - ys.min()) * 0.55), int(xs.min()) : int(xs.max())]).save(
        PREVIEWS / f"{mid}_upper.png"
    )
    return vis


def process_model(mid: str) -> None:
    base = MODELS / mid
    face = load_rgba(base / f"base/{mid}_face_base_v1.png")
    luma = face[..., :3].astype(np.float32).mean(axis=2)
    spots = catchlight_spots(face)
    left_c, right_c = pick_eye_pair(spots, face.shape[1])
    left = pupil_from_catch(luma, *left_c)
    right = pupil_from_catch(luma, *right_c)
    rgb = face[..., :3].astype(np.float32)
    chroma = rgb.std(axis=2)
    alpha = face[..., 3]
    y_l = lid_y_from_catch(luma, chroma, alpha, left_c[0], left_c[1])
    y_r = lid_y_from_catch(luma, chroma, alpha, right_c[0], right_c[1])
    print(
        f"{mid}: pupils L=({left[0]:.1f},{left[1]:.1f}) R=({right[0]:.1f},{right[1]:.1f}) "
        f"lash_y={y_l:.1f}/{y_r:.1f} ipd={right[0]-left[0]:.1f}"
    )

    ipd = max(right[0] - left[0], 80.0)
    opening = np.zeros(luma.shape, dtype=bool)
    lids: list[np.ndarray] = []
    lashes: list[np.ndarray] = []
    for i, pupil in enumerate((left, right)):
        y_lash = y_l if i == 0 else y_r
        catch = left_c if i == 0 else right_c
        outer_sign = -1.0 if i == 0 else 1.0
        eye = opening_from_pupil(face, pupil[0], pupil[1], ipd)
        eye_w = max(ipd * 0.46, 88.0)
        top, x0, x1 = almond_top(
            face.shape[1], catch[0] + outer_sign * eye_w * 0.04, y_lash, eye_w, outer_sign
        )
        for x in range(x0, x1 + 1):
            if top[x] >= 0:
                eye[: max(int(top[x]), 0), x] = False
        opening |= eye
        print(
            f"  {mid} eye{i} catch=({catch[0]:.0f},{catch[1]:.0f}) "
            f"line={top[x0:x1+1][top[x0:x1+1]>=0].min()}-{top[x0:x1+1][top[x0:x1+1]>=0].max()} "
            f"x={x0}-{x1}"
        )
        lids.append(lid_from_opening(face, eye, top, x0, x1, catch[0], outer_sign, ipd, y_lash))
        lashes.append(lash_from_opening(eye, top, x0, x1, y_lash, outer_sign))

    lip_ov = load_rgba(next((base / "makeup/lipstick").glob("*overlay*.png")))
    shadow_path = next((base / "makeup/eyeshadow").glob("*overlay*.png"))
    lips = improve_lips(lip_ov, face)
    blush_l, blush_r = blush_from_landmarks(face, left, right, lips, opening)
    lid_combo = np.maximum(lids[0], lids[1])
    skin = improve_skin(face, lips, lid_combo, opening)

    masks = base / "masks"
    save_rgba(masks / f"{mid}_eye_l_mask.png", mask_image(lids[0]))
    save_rgba(masks / f"{mid}_eye_r_mask.png", mask_image(lids[1]))
    save_rgba(masks / f"{mid}_lash_l_mask.png", mask_image(lashes[0]))
    save_rgba(masks / f"{mid}_lash_r_mask.png", mask_image(lashes[1]))
    save_rgba(masks / f"{mid}_lips_mask.png", lips)
    save_rgba(masks / f"{mid}_cheek_l_mask.png", blush_l)
    save_rgba(masks / f"{mid}_cheek_r_mask.png", blush_r)
    save_rgba(masks / f"{mid}_skin_mask.png", skin)
    save_rgba(shadow_path, overlay_from_lid(mask_image(lid_combo), OVERLAY_COLORS[mid]))

    vis = save_preview(
        face,
        (mask_image(lids[0]), mask_image(lids[1])),
        (mask_image(lashes[0]), mask_image(lashes[1])),
        lips,
        (blush_l, blush_r),
        opening,
        mid,
    )
    look = face[..., :3].astype(np.float32)
    look = tint(look, mask_image(lid_combo), (218, 168, 42), 0.70)
    look = tint(look, mask_image(lashes[0]), (18, 10, 8), 0.94)
    look = tint(look, mask_image(lashes[1]), (18, 10, 8), 0.94)
    look = tint(look, blush_l, (226, 96, 110), 0.40)
    look = tint(look, blush_r, (226, 96, 110), 0.40)
    look = np.clip(look, 0, 255).astype(np.uint8)
    for label, catch in (("L", left_c), ("R", right_c)):
        x, y = int(round(catch[0])), int(round(catch[1]))
        box = (max(y - 52, 0), y + 36, max(x - 72, 0), x + 72)
        Image.fromarray(vis[box[0] : box[1], box[2] : box[3]]).save(PREVIEWS / f"{mid}_eye_{label}.png")
        Image.fromarray(look[box[0] : box[1], box[2] : box[3]]).save(PREVIEWS / f"{mid}_look_{label}.png")
        lid_m = lids[0] if label == "L" else lids[1]
        lash_m = lashes[0] if label == "L" else lashes[1]
        col = lid_m[:, x]
        lid_ys = np.where(col >= 40)[0]
        lash_col = lash_m[:, x]
        ridge = int(np.argmax(lash_col)) if lash_col.max() > 20 else -1
        lid_lo = int(lid_ys.max()) if lid_ys.size else -1
        lid_hi = int(lid_ys.min()) if lid_ys.size else -1
        open_ys = np.where(opening[:, x])[0]
        open_top = int(open_ys.min()) if open_ys.size else -1
        print(
            f"    {label} catch_y={y} lid={lid_hi}-{lid_lo} lash_ridge={ridge} "
            f"open_top={open_top} gap={open_top - lid_lo if open_top >= 0 and lid_lo >= 0 else 'n/a'}"
        )
        for tag, xx in (("inner", x + (36 if label == "L" else -36)), ("outer", x + (-40 if label == "L" else 40))):
            col2 = lid_m[:, xx]
            ys2 = np.where(col2 >= 40)[0]
            o2 = np.where(opening[:, xx])[0]
            print(
                f"      {tag}x={xx} lid={int(ys2.min()) if ys2.size else -1}-{int(ys2.max()) if ys2.size else -1} "
                f"open={int(o2.min()) if o2.size else -1} n={int(ys2.size)}"
            )
    ys, xs = np.where(face[..., 3] > 40)
    Image.fromarray(
        look[int(ys.min()) : int(ys.min() + (ys.max() - ys.min()) * 0.62), int(xs.min()) : int(xs.max())]
    ).save(PREVIEWS / f"{mid}_look.png")
    print(
        f"  lid={(lids[0] >= 32).sum()}/{(lids[1] >= 32).sum()} "
        f"lash={(lashes[0] >= 32).sum()}/{(lashes[1] >= 32).sum()} "
        f"lips={(lips[..., 3] >= 32).sum()} "
        f"blush={(blush_l[..., 3] >= 32).sum()}/{(blush_r[..., 3] >= 32).sum()}"
    )
    for tag, arr, pupil in (("blushL", blush_l, left), ("blushR", blush_r, right)):
        ys_b, xs_b = np.where(arr[..., 3] >= 40)
        if ys_b.size:
            print(
                f"    {tag} centroid=({xs_b.mean():.0f},{ys_b.mean():.0f}) "
                f"pupil=({pupil[0]:.0f},{pupil[1]:.0f}) "
                f"d=({xs_b.mean()-pupil[0]:+.0f},{ys_b.mean()-pupil[1]:+.0f})"
            )


def main() -> None:
    for mid in ["model_01", "model_02", "model_03", "model_04"]:
        process_model(mid)


if __name__ == "__main__":
    main()

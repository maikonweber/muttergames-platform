"""Rebuild face cutouts and region masks for the Lira prototype."""

from __future__ import annotations

from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "assets" / "models"
PREVIEWS = ROOT / "tools" / "_previews"


def load_rgba(path: Path) -> np.ndarray:
    return np.array(Image.open(path).convert("RGBA"))


def save_rgba(path: Path, arr: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(arr, "RGBA").save(path)


def overlay_strength(arr: np.ndarray) -> np.ndarray:
    lum = arr[..., :3].max(axis=2).astype(np.float32)
    alpha = arr[..., 3].astype(np.float32)
    return np.clip(lum * (alpha / 255.0), 0.0, 255.0)


def mask_image(strength: np.ndarray) -> np.ndarray:
    out = np.zeros((*strength.shape, 4), dtype=np.uint8)
    out[..., :3] = 255
    out[..., 3] = np.clip(strength, 0, 255).astype(np.uint8)
    return out


def remap_strength(raw: np.ndarray, floor: float, gamma: float = 0.7) -> np.ndarray:
    strength = np.zeros_like(raw, dtype=np.float32)
    keep = raw >= floor
    if not keep.any():
        return strength
    normalized = (raw[keep] - floor) / max(float(raw[keep].max() - floor), 1.0)
    strength[keep] = np.clip(normalized ** gamma, 0.0, 1.0) * 255.0
    return strength


def split_lr(strength: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    mid = strength.shape[1] // 2
    left = strength.copy()
    right = strength.copy()
    left[:, mid:] = 0
    right[:, :mid] = 0
    return left, right


def studio_bg_color(face: np.ndarray) -> np.ndarray:
    rgb = face[..., :3]
    h, w = rgb.shape[:2]
    border = np.concatenate(
        [
            rgb[:28, :].reshape(-1, 3),
            rgb[: int(h * 0.28), :16].reshape(-1, 3),
            rgb[: int(h * 0.28), -16:].reshape(-1, 3),
        ],
        axis=0,
    )
    return np.median(border.astype(np.float32), axis=0)


def restore_hair_front(full: np.ndarray, back: np.ndarray) -> np.ndarray:
    out = full.copy()
    out[back[..., 3] >= 16] = 0
    return out


def grabcut_face(face: np.ndarray, hair: np.ndarray) -> np.ndarray:
    h, w = face.shape[:2]
    bgr = cv2.cvtColor(face, cv2.COLOR_RGBA2BGR)
    mask = np.full((h, w), cv2.GC_PR_BGD, np.uint8)
    mask[:36, :] = cv2.GC_BGD
    mask[:, :28] = cv2.GC_BGD
    mask[:, -28:] = cv2.GC_BGD
    mask[:48, :48] = cv2.GC_BGD
    mask[:48, -48:] = cv2.GC_BGD
    mask[-40:, :40] = cv2.GC_BGD
    mask[-40:, -40:] = cv2.GC_BGD
    hair_on = hair[..., 3] >= 20
    mask[hair_on] = cv2.GC_PR_FGD
    cv2.ellipse(
        mask,
        (w // 2, int(h * 0.44)),
        (int(w * 0.20), int(h * 0.26)),
        0,
        0,
        360,
        int(cv2.GC_FGD),
        -1,
    )
    cv2.rectangle(
        mask,
        (int(w * 0.28), int(h * 0.52)),
        (int(w * 0.72), int(h * 0.90)),
        int(cv2.GC_PR_FGD),
        -1,
    )
    bgd = np.zeros((1, 65), np.float64)
    fgd = np.zeros((1, 65), np.float64)
    cv2.grabCut(bgr, mask, None, bgd, fgd, 4, cv2.GC_INIT_WITH_MASK)
    fg = ((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD)).astype(np.uint8) * 255
    fg[hair_on] = 255
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
    fg = cv2.morphologyEx(fg, cv2.MORPH_CLOSE, kernel)
    alpha = cv2.GaussianBlur(fg, (0, 0), 0.7)
    out = face.copy()
    out[..., 3] = alpha
    return punch_studio(out, studio_bg_color(face), hair), studio_bg_color(face)


def punch_studio(face: np.ndarray, bg: np.ndarray, hair: np.ndarray, limit: float = 34.0) -> np.ndarray:
    rgb = face[..., :3].astype(np.float32)
    dist = np.linalg.norm(rgb - bg.reshape(1, 1, 3), axis=2)
    luma = rgb.max(axis=2)
    h, w = rgb.shape[:2]
    yy, xx = np.ogrid[:h, :w]
    inner_face = ((xx - w / 2.0) / (w * 0.17)) ** 2 + ((yy - h * 0.42) / (h * 0.20)) ** 2 <= 1.0
    studio = (dist < limit) & (luma > 70.0) & (~inner_face)
    alpha = face[..., 3].astype(np.float32)
    fade = np.clip(dist / limit, 0.0, 1.0)
    alpha = np.where(studio, np.minimum(alpha, fade * fade * 40.0), alpha)
    # Keep dark hair even if the studio color leaked around strands.
    dark_hair = (hair[..., 3] >= 24) & (luma < 70.0)
    alpha = np.where(dark_hair, np.maximum(alpha, hair[..., 3].astype(np.float32)), alpha)
    out = face.copy()
    out[..., 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return chroma_despill(out, bg, limit)


def chroma_despill(img: np.ndarray, bg: np.ndarray, limit: float) -> np.ndarray:
    rgb = img[..., :3].astype(np.float32)
    dist = np.linalg.norm(rgb - bg.reshape(1, 1, 3), axis=2)
    close = np.clip(1.0 - dist / max(limit, 1.0), 0.0, 1.0)
    alpha = img[..., 3].astype(np.float32)
    # Only eat leftover studio color; keep strong opaque paint.
    edge = close * (1.0 - np.clip((alpha - 140.0) / 115.0, 0.0, 1.0))
    rgb = rgb - (bg.reshape(1, 1, 3) - rgb) * edge[..., None] * 0.35
    rgb = np.clip(rgb, 0, 255)
    alpha = alpha * (1.0 - edge * 0.92)
    out = img.copy()
    out[..., :3] = rgb.astype(np.uint8)
    out[..., 3] = np.clip(alpha, 0, 255).astype(np.uint8)
    return out


def lip_mask_from_overlay(overlay: np.ndarray, face: np.ndarray) -> np.ndarray:
    raw = overlay_strength(overlay)
    strength = remap_strength(raw, floor=58.0, gamma=0.5)
    if not np.any(strength >= 24):
        return mask_image(strength)
    rgb = face[..., :3].astype(np.float32)
    red_score = rgb[..., 0] - 0.5 * (rgb[..., 1] + rgb[..., 2])
    lum = rgb.max(axis=2)
    skin_like = (red_score < 16.0) & (strength < 170.0)
    strength = np.where(skin_like, strength * 0.08, strength)
    ys, xs = np.where(strength >= 48)
    y0, y1, x0, x1 = int(ys.min()), int(ys.max()), int(xs.min()), int(xs.max())
    row_luma = []
    for y in range(y0, y1 + 1):
        on = strength[y, x0 : x1 + 1] >= 48
        row_luma.append(float(lum[y, x0 : x1 + 1][on].mean()) if on.any() else 255.0)
    crease_y = y0 + int(np.argmin(np.array(row_luma)))
    yy = np.arange(strength.shape[0], dtype=np.float32)[:, None]
    falloff = np.exp(-0.5 * ((yy - crease_y) / 3.8) ** 2)
    strength *= 1.0 - 0.42 * falloff
    if strength.max() > 0:
        strength = cv2.GaussianBlur(strength, (0, 0), 0.45)
    return mask_image(strength)


def lid_masks_from_overlay(overlay: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    raw = overlay_strength(overlay)
    strength = remap_strength(raw, floor=28.0, gamma=0.7)
    if strength.max() > 0:
        strength = cv2.GaussianBlur(strength, (0, 0), 0.35)
    left, right = split_lr(strength)
    return mask_image(left), mask_image(right)


def lash_from_lid(lid: np.ndarray, below: int = 5, above: int = 1) -> np.ndarray:
    alpha = lid[..., 3]
    h, w = alpha.shape
    out = np.zeros((h, w), dtype=np.float32)
    cols = np.where(alpha.max(axis=0) >= 28)[0]
    for x in cols:
        ys = np.where(alpha[:, x] >= 28)[0]
        if ys.size == 0:
            continue
        y_bottom = int(ys.max())
        y0 = max(int(ys.min()), y_bottom - above)
        y1 = min(h - 1, y_bottom + below)
        span = max(y1 - y0, 1)
        for y in range(y0, y1 + 1):
            t = 1.0 - abs((y - y_bottom) / float(span))
            out[y, x] = max(out[y, x], 220.0 * t)
    if out.max() > 0:
        out = cv2.GaussianBlur(out, (0, 0), 0.45)
    return mask_image(out)


def blush_masks(overlay: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    raw = overlay_strength(overlay)
    strength = remap_strength(raw, floor=22.0, gamma=0.85)
    left, right = split_lr(strength)
    return mask_image(left), mask_image(right)


def skin_mask(face: np.ndarray, hair: np.ndarray, lips: np.ndarray, lids: np.ndarray) -> np.ndarray:
    keep = (face[..., 3] >= 96) & (hair[..., 3] < 40)
    block = (lips[..., 3] >= 36) | (lids[..., 3] >= 36)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9))
    block = cv2.dilate(block.astype(np.uint8), kernel, iterations=1).astype(bool)
    keep &= ~block
    alpha = cv2.GaussianBlur(keep.astype(np.uint8) * 255, (0, 0), 0.9)
    return mask_image(alpha.astype(np.float32))


def patch_import_files() -> int:
    count = 0
    for path in MODELS.rglob("*.import"):
        text = path.read_text(encoding="utf-8")
        updated = text.replace("process/fix_alpha_border=true", "process/fix_alpha_border=false")
        updated = updated.replace("detect_3d/compress_to=1", "detect_3d/compress_to=0")
        if updated != text:
            path.write_text(updated, encoding="utf-8")
            count += 1
    return count


def preview_composite(face: np.ndarray, hair: np.ndarray) -> np.ndarray:
    h, w = face.shape[:2]
    canvas = np.zeros((h, w, 3), dtype=np.float32)
    canvas[:] = (18, 18, 22)
    canvas[::32, :] = (48, 48, 58)
    canvas[:, ::32] = (48, 48, 58)

    def over(dst: np.ndarray, src: np.ndarray) -> np.ndarray:
        a = src[..., 3:4].astype(np.float32) / 255.0
        return src[..., :3].astype(np.float32) * a + dst * (1.0 - a)

    canvas = over(canvas, face)
    canvas = over(canvas, hair)
    return np.clip(canvas, 0, 255).astype(np.uint8)


def already_cut_out(face: np.ndarray) -> bool:
    return int((face[..., 3] < 12).sum()) > 80_000


def process_model(mid: str) -> None:
    base = MODELS / mid
    face_path = base / f"base/{mid}_face_base_v1.png"
    hair_full_path = base / f"hair/{mid}_hair_full_v1.png"
    hair_back_path = base / f"hair/{mid}_hair_back_v1.png"
    hair_front_path = base / f"hair/{mid}_hair_front_v1.png"
    face = load_rgba(face_path)
    hair_full = load_rgba(hair_full_path)
    hair_back = load_rgba(hair_back_path)
    save_rgba(hair_front_path, restore_hair_front(hair_full, hair_back))

    bg = studio_bg_color(face)
    if mid != "model_01":
        face, bg = grabcut_face(face, hair_full)
        save_rgba(face_path, face)
        print(f"  {mid}: recorte alpha>8={int((face[..., 3] > 8).sum())} bg={tuple(int(v) for v in bg)}")
        hair_display = hair_full
    else:
        hair_display = hair_full
        print(f"  {mid}: manteve recorte existente bg={tuple(int(v) for v in bg)}")

    lip_ov = load_rgba(next((base / "makeup/lipstick").glob("*overlay*.png")))
    eye_ov = load_rgba(next((base / "makeup/eyeshadow").glob("*overlay*.png")))
    blush_ov = load_rgba(next((base / "makeup/blush").glob("*overlay*.png")))
    lips = lip_mask_from_overlay(lip_ov, face)
    eye_l, eye_r = lid_masks_from_overlay(eye_ov)
    lash_l = lash_from_lid(eye_l)
    lash_r = lash_from_lid(eye_r)
    cheek_l, cheek_r = blush_masks(blush_ov)
    lids = eye_l.copy()
    lids[..., 3] = np.maximum(eye_l[..., 3], eye_r[..., 3])
    skin = skin_mask(face, hair_display, lips, lids)
    masks = base / "masks"
    save_rgba(masks / f"{mid}_lips_mask.png", lips)
    save_rgba(masks / f"{mid}_eye_l_mask.png", eye_l)
    save_rgba(masks / f"{mid}_eye_r_mask.png", eye_r)
    save_rgba(masks / f"{mid}_lash_l_mask.png", lash_l)
    save_rgba(masks / f"{mid}_lash_r_mask.png", lash_r)
    save_rgba(masks / f"{mid}_cheek_l_mask.png", cheek_l)
    save_rgba(masks / f"{mid}_cheek_r_mask.png", cheek_r)
    save_rgba(masks / f"{mid}_skin_mask.png", skin)
    PREVIEWS.mkdir(parents=True, exist_ok=True)
    Image.fromarray(preview_composite(face, hair_display), "RGB").save(
        PREVIEWS / f"{mid}_composite.jpg", quality=90
    )
    print(
        f"  {mid}: lips={(lips[..., 3] >= 32).sum()} eye_l={(eye_l[..., 3] >= 32).sum()} "
        f"lash_l={(lash_l[..., 3] >= 32).sum()} skin={(skin[..., 3] >= 32).sum()}"
    )


def main() -> None:
    for mid in ["model_01", "model_02", "model_03", "model_04"]:
        print(f"==== {mid}")
        process_model(mid)
    print(f"imports atualizados: {patch_import_files()}")


if __name__ == "__main__":
    main()

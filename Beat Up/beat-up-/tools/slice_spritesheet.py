"""Slice the isometric city spritesheet into individual transparent PNGs."""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

SHEET = Path(r"c:\Users\plugify\Documents\beat-up-\watermarked_img_15465769839442953856.jpg")
OUT_DIR = Path(r"c:\Users\plugify\Documents\beat-up-\assets\sprites")

NAMES = [
	"police_car",
	"sedan",
	"pickup",
	"van",
	"motorcycle",
	"barrier",
	"traffic_cone",
	"stop_sign",
	"road_crosswalk",
	"hydrant_a",
	"hydrant_b",
	"trash_can",
	"mailbox",
	"tree",
	"hedge",
]


def foreground_mask(arr: np.ndarray) -> np.ndarray:
	rgb = arr.astype(np.int16)
	r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
	chroma = np.maximum(np.maximum(r, g), b) - np.minimum(np.minimum(r, g), b)
	sat = chroma > 22
	dark = (r + g + b) < 140
	near_white = (r > 235) & (g > 235) & (b > 235)
	# Dark asphalt / sidewalk on road tile (not checkerboard ~190+)
	asphalt = (r > 40) & (r < 165) & (g > 40) & (g < 165) & (b > 40) & (b < 165) & (chroma < 22)
	return (sat | dark | asphalt) & ~near_white


def connected_components(mask: np.ndarray, min_pixels: int = 1000) -> list[tuple[int, int, int, int]]:
	h, w = mask.shape
	visited = np.zeros_like(mask, dtype=bool)
	boxes: list[tuple[int, int, int, int]] = []

	for y in range(h):
		for x in range(w):
			if not mask[y, x] or visited[y, x]:
				continue
			stack = [(x, y)]
			visited[y, x] = True
			min_x = max_x = x
			min_y = max_y = y
			count = 0
			while stack:
				cx, cy = stack.pop()
				count += 1
				min_x = min(min_x, cx)
				max_x = max(max_x, cx)
				min_y = min(min_y, cy)
				max_y = max(max_y, cy)
				for nx, ny in (
					(cx - 1, cy),
					(cx + 1, cy),
					(cx, cy - 1),
					(cx, cy + 1),
					(cx - 1, cy - 1),
					(cx + 1, cy - 1),
					(cx - 1, cy + 1),
					(cx + 1, cy + 1),
				):
					if 0 <= nx < w and 0 <= ny < h and mask[ny, nx] and not visited[ny, nx]:
						visited[ny, nx] = True
						stack.append((nx, ny))
			if count >= min_pixels:
				boxes.append((min_x, min_y, max_x + 1, max_y + 1))
	return boxes


def main() -> None:
	# Clean previous exports
	OUT_DIR.mkdir(parents=True, exist_ok=True)
	for old in OUT_DIR.glob("*.png"):
		old.unlink()

	img = Image.open(SHEET).convert("RGB")
	arr = np.asarray(img)
	fg = foreground_mask(arr)
	boxes = connected_components(fg, min_pixels=1000)
	boxes.sort(key=lambda b: (((b[1] + b[3]) // 2) // 130, (b[0] + b[2]) // 2))

	print(f"Found {len(boxes)} sprites")
	if len(boxes) != len(NAMES):
		print(f"WARNING: expected {len(NAMES)}, got {len(boxes)}")

	for i, box in enumerate(boxes):
		x0, y0, x1, y1 = box
		pad = 2
		x0 = max(0, x0 - pad)
		y0 = max(0, y0 - pad)
		x1 = min(arr.shape[1], x1 + pad)
		y1 = min(arr.shape[0], y1 + pad)

		crop_rgb = arr[y0:y1, x0:x1]
		crop_fg = fg[y0:y1, x0:x1]
		rgba = np.zeros((crop_rgb.shape[0], crop_rgb.shape[1], 4), dtype=np.uint8)
		rgba[..., :3] = crop_rgb
		rgba[..., 3] = np.where(crop_fg, 255, 0).astype(np.uint8)

		name = NAMES[i] if i < len(NAMES) else f"sprite_{i:02d}"
		out = OUT_DIR / f"{name}.png"
		Image.fromarray(rgba, "RGBA").save(out)
		print(f"  {name}: {x1 - x0}x{y1 - y0}")


if __name__ == "__main__":
	main()

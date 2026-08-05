# Beat Up — Meshy Asset Microservice

Proxy + CLI around the [Meshy API](https://docs.meshy.ai/en/api) to generate 3D asset packs for the game. API keys stay server-side (never in Godot / browser).

## Setup

```powershell
cd services\meshy
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

Edit `.env` and set:

```
MESHY_API_KEY=msy_...
```

**Security:** if a key was pasted in chat, revoke it at Meshy settings and create a new one.

Downloads go to `assets/generated/<preset_id>/` (repo root). Meshy keeps cloud files ~3 days — local copies are permanent.

## 2D pack (Text to Image) — primary for Beat Up iso sprites

```powershell
python -m app.cli presets-2d

# Full game pack (tiles + vehicles + props + ui) — ~3 credits/image with nano-banana
python -m app.cli pack-2d --core

# By group
python -m app.cli pack-2d --group tiles
python -m app.cli pack-2d --group vehicles --max-assets 4

# Single sprite
python -m app.cli generate-2d sprite_player_car
```

Output: `assets/generated/2d/<preset_id>/*.png` (+ `.json` meta).

HTTP: `GET /presets/2d`, `POST /generate/text-to-image`, `POST /generate/preset-2d`, `POST /generate/pack-2d` with `{ "core_pack": true }`.

## 3D pack (Text to 3D / GLB)

```powershell
# List Beat Up presets
python -m app.cli presets

# Credit balance
python -m app.cli balance

# One asset (preview + refine — uses credits)
python -m app.cli generate player_car

# Cheaper: preview only
python -m app.cli generate player_car --preview-only

# Small pack (default max 3)
python -m app.cli pack --tag vehicle --max-assets 2 --preview-only
```

## HTTP API

```powershell
python -m app.cli serve
# http://127.0.0.1:8787/docs
```

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Status + output dir |
| GET | `/balance` | Meshy credits |
| GET | `/presets` | Beat Up preset list |
| POST | `/generate/text-to-3d` | Custom prompt |
| POST | `/generate/image-to-3d` | From image URL |
| POST | `/generate/preset` | `{ "preset_id": "player_car" }` |
| POST | `/generate/pack` | Batch presets (capped) |

Example:

```powershell
curl http://127.0.0.1:8787/generate/preset -H "Content-Type: application/json" -d "{\"preset_id\":\"player_car\",\"refine\":false}"
```

## Notes for Beat Up

- Game is **2D isometric** today. Meshy outputs **GLB** — use as references or later render to sprites.
- Start with `--preview-only` / `"refine": false` to save credits.
- Priority presets: `player_car`, `police_car`, `tree_city`, `npc_taxi`.

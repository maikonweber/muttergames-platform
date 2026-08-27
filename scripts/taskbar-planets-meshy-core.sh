#!/usr/bin/env bash
# Pack mínimo (ROI) — Oceanico, Rochoso, Vulcanico, asteroid, sun
# Retoma assets já baixados.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${ROOT}/scripts/bin:${PATH}"
OUT="${ROOT}/TaskBarPlanetsForger/task-bar-planet-forger/assets/meshy"
M="${ROOT}/scripts/meshy-asset.sh"
mkdir -p "$OUT"

gen() {
  local id="$1" prompt="$2"
  if [[ -f "${OUT}/${id}.glb" && -f "${OUT}/${id}.preview.png" ]]; then
    echo "=== ${id} (já existe, skip) ==="
    return 0
  fi
  echo "=== ${id} ==="
  bash "$M" text-to-3d \
    --prompt "$prompt" \
    --out "${OUT}/${id}" \
    --model-type lowpoly \
    --ai-model latest \
    --format glb \
    --polycount 8000 \
    --meta \
    --thumbnail
}

gen Oceanico "low poly stylized oceanic planet globe for a 2D idle game, cyan blue oceans, soft white clouds, small green continents, clean sphere, game asset, no text, no stand"
gen Rochoso "low poly stylized rocky planet globe, dusty ochre and rust craters, dry surface, clean sphere, 2D idle game asset, no text"
gen Vulcanico "low poly stylized volcanic planet globe, charcoal rock with glowing orange lava cracks, emissive fissures, clean sphere, game asset, no text"
gen asteroid "low poly stylized asteroid rock chunk, irregular craggy stone, gray brown, floating space rock for idle game, no planet, no text"
gen sun "low poly stylized sun star sphere, bright solar gold and warm yellow glow, clean sphere icon for orbital map, game asset, no text"

bash "$M" balance
echo DONE_CORE_PACK

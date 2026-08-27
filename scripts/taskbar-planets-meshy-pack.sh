#!/usr/bin/env bash
# Gera o pack Meshy de arquétipos/props do Taskbar Planets Forger.
# Uso: set -a; source .env; set +a; scripts/taskbar-planets-meshy-pack.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${ROOT}/scripts/bin:${PATH}"
OUT_DIR="${ROOT}/TaskBarPlanetsForger/task-bar-planet-forger/assets/meshy"
MESHY="${ROOT}/scripts/meshy-asset.sh"

die() { echo "erro: $*" >&2; exit 1; }
[[ -n "${MESHY_API:-${MESHY_API_KEY:-}}" ]] || die "defina MESHY_API no .env"
command -v jq >/dev/null || die "jq não encontrado (scripts/bin/jq.exe)"

mkdir -p "$OUT_DIR"

generate() {
  local id="$1" prompt="$2" model_type="${3:-lowpoly}"
  echo "=== Gerando ${id} ==="
  bash "$MESHY" text-to-3d \
    --prompt "$prompt" \
    --out "${OUT_DIR}/${id}" \
    --model-type "$model_type" \
    --ai-model latest \
    --format glb \
    --polycount 8000 \
    --meta \
    --thumbnail
}

# Arquétipos alinhados a docs/design-system.md §6
generate "Oceanico" \
  "low poly stylized oceanic planet globe for a 2D idle game, cyan blue oceans, soft white clouds, small green continents, clean sphere, game asset, no text, no stand"
generate "Rochoso" \
  "low poly stylized rocky planet globe, dusty ochre and rust craters, dry surface, clean sphere, 2D idle game asset, no text"
generate "Vulcanico" \
  "low poly stylized volcanic planet globe, charcoal rock with glowing orange lava cracks, emissive fissures, clean sphere, game asset, no text"
generate "Desertico" \
  "low poly stylized desert planet globe, amber sand dunes, violet shadows, dusty bands, clean sphere, game asset, no text"
generate "Congelado" \
  "low poly stylized frozen ice planet globe, pale blue ice, white polar caps, subtle aurora tint, clean sphere, game asset, no text"
generate "Gasoso" \
  "low poly stylized gas giant globe, indigo and rose bands, one large storm spot, clean sphere, game asset, no text"
generate "asteroid" \
  "low poly stylized asteroid rock chunk, irregular craggy stone, gray brown, floating space rock for idle game, no planet, no text"
generate "sun" \
  "low poly stylized sun star sphere, bright solar gold and warm yellow glow, clean sphere icon for orbital map, no flares clutter, game asset, no text"

# Catálogo consumido pelo Godot (offline)
catalog="${OUT_DIR}/catalog.json"
jq -n \
  --arg generator "meshy-asset" \
  --argjson archetypes "$(jq -n '{
    Oceanico: {preview: "res://assets/meshy/Oceanico.preview.png", model: "res://assets/meshy/Oceanico.glb"},
    Rochoso: {preview: "res://assets/meshy/Rochoso.preview.png", model: "res://assets/meshy/Rochoso.glb"},
    Vulcanico: {preview: "res://assets/meshy/Vulcanico.preview.png", model: "res://assets/meshy/Vulcanico.glb"},
    Desertico: {preview: "res://assets/meshy/Desertico.preview.png", model: "res://assets/meshy/Desertico.glb"},
    Congelado: {preview: "res://assets/meshy/Congelado.preview.png", model: "res://assets/meshy/Congelado.glb"},
    Gasoso: {preview: "res://assets/meshy/Gasoso.preview.png", model: "res://assets/meshy/Gasoso.glb"},
    Vivo: {preview: "res://assets/meshy/Oceanico.preview.png", model: "res://assets/meshy/Oceanico.glb"},
    Maquina: {preview: "res://assets/meshy/Rochoso.preview.png", model: "res://assets/meshy/Rochoso.glb"}
  }')" \
  --argjson props "$(jq -n '{
    asteroid: {preview: "res://assets/meshy/asteroid.preview.png", model: "res://assets/meshy/asteroid.glb"},
    sun: {preview: "res://assets/meshy/sun.preview.png", model: "res://assets/meshy/sun.glb"}
  }')" \
  '{
    generator: $generator,
    version: 1,
    note: "Previews are offline Meshy thumbnails. Runtime stays offline; pack is optional art.",
    archetypes: $archetypes,
    props: $props
  }' > "$catalog"

echo "catálogo: $catalog"
bash "$MESHY" balance
echo "Pack Taskbar Planets Meshy concluído."

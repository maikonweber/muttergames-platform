#!/usr/bin/env bash
# CLI unificada para os fluxos 2D, 3D, áudio, narrativa e MCP da MutterGames.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLENDER_BIN="${BLENDER_BIN:-blender}"
die() { echo "erro: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Mutter Forge — CLI de criação de jogos

Uso: scripts/mutter-forge.sh <grupo> <comando> [argumentos]

Grupos:
  doctor                                  Diagnóstico de dependências.
  2d <comando...>                         Encaminha a mutter-creative (crop, VFX, SFX, sheets).
  game <comando...>                       Encaminha a mutter-gamekit (dados, localização, Godot).
  ai-image <comando...>                   Encaminha a OpenRouter Image.
  ai-game <comando...>                    Encaminha OpenRouter Game (texto, briefs, TTS).
  3d primitive <cube|sphere|cylinder> <nome> <saida.glb> [cor-hex]
  3d render <arquivo.blend> <saida.png> [frame]
  mcp init [mcp.json]                     Cria configuração de servidor MCP local.

Exemplos:
  scripts/mutter-forge.sh 2d vfx forge assets/vfx/forge 256 12
  scripts/mutter-forge.sh game component health scripts/components/health.gd
  scripts/mutter-forge.sh 3d primitive sphere planet assets/3d/planet.glb 2EAFD7
  scripts/mutter-forge.sh ai-game text --model <modelo> --kind lore --prompt "..." --out docs/lore.md
EOF
}

doctor() {
  echo "Mutter Forge — ${ROOT_DIR}"
  for tool in bash node curl jq magick ffmpeg "$BLENDER_BIN"; do
    if command -v "$tool" >/dev/null 2>&1; then echo "[ok] $tool"; else echo "[--] $tool"; fi
  done
  [[ -n "${OPEN_ROUTER:-}" ]] && echo "[ok] OPEN_ROUTER configurado" || echo "[--] OPEN_ROUTER não configurado"
}

primitive() {
  [[ $# -ge 3 ]] || die "uso: 3d primitive <cube|sphere|cylinder> <nome> <saida.glb> [cor-hex]"
  command -v "$BLENDER_BIN" >/dev/null 2>&1 || die "Blender não encontrado. Defina BLENDER_BIN se necessário."
  local shape="$1" name="$2" output="$3" color="${4:-55D9FF}"
  [[ "$shape" =~ ^(cube|sphere|cylinder)$ ]] || die "primitive inválido"
  mkdir -p "$(dirname "$output")"
  "$BLENDER_BIN" --background --python-exit-code 1 --python "${ROOT_DIR}/scripts/blender/create_primitive.py" -- --shape "$shape" --name "$name" --output "$output" --color "$color"
  echo "modelo 3D criado: $output"
}

render() {
  [[ $# -ge 2 ]] || die "uso: 3d render <arquivo.blend> <saida.png> [frame]"
  command -v "$BLENDER_BIN" >/dev/null 2>&1 || die "Blender não encontrado. Defina BLENDER_BIN se necessário."
  local blend="$1" output="$2" frame="${3:-1}"
  [[ -f "$blend" ]] || die "arquivo não encontrado: $blend"
  mkdir -p "$(dirname "$output")"
  "$BLENDER_BIN" --background "$blend" --render-output "$output" --render-frame "$frame"
  echo "render criado: $output"
}

mcp_init() {
  local output="${1:-${ROOT_DIR}/mcp.json}"
  mkdir -p "$(dirname "$output")"
  cat > "$output" <<EOF
{
  "servers": {
    "mutter-forge": {
      "type": "stdio",
      "command": "node",
      "args": ["${ROOT_DIR//\\/\\\\}/tools/mutter-forge-mcp.mjs"],
      "env": {
        "MUTTER_FORGE_ROOT": "${ROOT_DIR//\\/\\\\}"
      }
    }
  }
}
EOF
  echo "configuração MCP criada: $output"
}

group="${1:-help}"; shift || true
case "$group" in
  doctor) doctor "$@" ;;
  2d) bash "${ROOT_DIR}/scripts/mutter-creative.sh" "$@" ;;
  game) bash "${ROOT_DIR}/scripts/mutter-gamekit.sh" "$@" ;;
  ai-image) bash "${ROOT_DIR}/scripts/openrouter-image.sh" "$@" ;;
  ai-game) bash "${ROOT_DIR}/scripts/openrouter-game.sh" "$@" ;;
  3d) command="${1:-}"; shift || true; case "$command" in primitive) primitive "$@" ;; render) render "$@" ;; *) die "3d aceita primitive ou render" ;; esac ;;
  mcp) [[ "${1:-}" == "init" ]] || die "mcp aceita init"; shift; mcp_init "$@" ;;
  help|-h|--help) usage ;;
  *) usage; die "grupo inválido: $group" ;;
esac

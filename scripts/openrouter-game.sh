#!/usr/bin/env bash
# Ferramentas de conteúdo de jogo via OpenRouter. Chave: OPEN_ROUTER.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_BASE="https://openrouter.ai/api/v1"
TITLE="MutterGames Game Tools"
die() { echo "erro: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "'$1' não encontrado"; }
api_key() { printf '%s' "${OPEN_ROUTER:-${OPENROUTER_API_KEY:-}}"; }
need_key() { [[ -n "$(api_key)" ]] || die "defina OPEN_ROUTER no ambiente"; }
mkdir_for() { mkdir -p "$(dirname "$1")"; }

usage() {
  cat <<'EOF'
OpenRouter Game Tools — MutterGames

Uso:
  openrouter-game.sh text --model <modelo> --kind <dialogue|quest|lore|item|npc> --prompt <texto> --out <arquivo.md> [--language pt-BR]
  openrouter-game.sh brief --model <modelo> --kind <image|vfx|sfx|music> --prompt <texto> --out <arquivo.md>
  openrouter-game.sh voice --model <modelo-tts> --voice <voz> --text <texto> --out <arquivo.mp3> [--format mp3|pcm] [--speed 1]
  openrouter-game.sh audio-models [arquivo.json]
  openrouter-game.sh remove-bg <entrada.png> <saída.png> [#ff00ff]
EOF
}

chat_request() {
  local model="$1" system="$2" prompt="$3" output="$4"
  need curl; need jq; need_key; mkdir_for "$output"
  local payload response
  payload=$(jq -n --arg model "$model" --arg system "$system" --arg prompt "$prompt" '{model:$model,messages:[{role:"system",content:$system},{role:"user",content:$prompt}],temperature:0.75}')
  response=$(mktemp); trap 'rm -f "$response"' RETURN
  if ! curl --fail-with-body --silent --show-error -X POST "${API_BASE}/chat/completions" -H "Authorization: Bearer $(api_key)" -H "Content-Type: application/json" -H "X-Title: ${TITLE}" --data "$payload" -o "$response"; then
    jq -r '.error.message // .message // "Falha sem mensagem da API"' "$response" 2>/dev/null || true; exit 1
  fi
  jq -r '.choices[0].message.content // empty' "$response" > "$output"
  [[ -s "$output" ]] || die "o modelo não retornou texto"
  jq '{id,model,usage}' "$response" > "${output}.meta.json"
  echo "conteúdo criado: $output"
}

text() {
  local model="" kind="" prompt="" output="" language="pt-BR"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model|--kind|--prompt|--out|--language) [[ $# -ge 2 ]] || die "valor ausente para $1"; case "$1" in --model) model="$2";; --kind) kind="$2";; --prompt) prompt="$2";; --out) output="$2";; --language) language="$2";; esac; shift 2 ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ "$kind" =~ ^(dialogue|quest|lore|item|npc)$ ]] || die "--kind inválido"
  [[ -n "$model" && -n "$prompt" && -n "$output" ]] || die "--model, --prompt e --out são obrigatórios"
  chat_request "$model" "Você é roteirista de jogos da MutterGames. Escreva em ${language}. Entregue Markdown conciso, original e apropriado para jogo. O tipo é ${kind}. Inclua nome, texto jogável e notas de implementação. Não copie obras existentes." "$prompt" "$output"
}

brief() {
  local model="" kind="" prompt="" output=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model|--kind|--prompt|--out) [[ $# -ge 2 ]] || die "valor ausente para $1"; case "$1" in --model) model="$2";; --kind) kind="$2";; --prompt) prompt="$2";; --out) output="$2";; esac; shift 2 ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ "$kind" =~ ^(image|vfx|sfx|music)$ ]] || die "--kind inválido"
  [[ -n "$model" && -n "$prompt" && -n "$output" ]] || die "--model, --prompt e --out são obrigatórios"
  chat_request "$model" "Você é diretor de arte e som da MutterGames. Crie um brief técnico em português para ${kind}, com: Objetivo, Prompt/Descrição, Paleta ou Timbre, Duração/Dimensões, Loop/Animação, Restrições e Nome de Arquivo. Seja conciso, original e não use marcas de terceiros." "$prompt" "$output"
}

voice() {
  need curl; need jq; need_key
  local model="" voice="" input="" output="" format="mp3" speed="1"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model|--voice|--text|--out|--format|--speed) [[ $# -ge 2 ]] || die "valor ausente para $1"; case "$1" in --model) model="$2";; --voice) voice="$2";; --text) input="$2";; --out) output="$2";; --format) format="$2";; --speed) speed="$2";; esac; shift 2 ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ -n "$model" && -n "$voice" && -n "$input" && -n "$output" ]] || die "--model, --voice, --text e --out são obrigatórios"
  [[ "$format" =~ ^(mp3|pcm)$ ]] || die "--format deve ser mp3 ou pcm"
  mkdir_for "$output"
  local payload; payload=$(jq -n --arg model "$model" --arg voice "$voice" --arg input "$input" --arg format "$format" --arg speed "$speed" '{model:$model,voice:$voice,input:$input,response_format:$format,speed:($speed|tonumber)}')
  curl --fail-with-body --silent --show-error -X POST "${API_BASE}/audio/speech" -H "Authorization: Bearer $(api_key)" -H "Content-Type: application/json" -H "X-Title: ${TITLE}" --data "$payload" -o "$output"
  [[ -s "$output" ]] || die "a API não devolveu áudio"; echo "voz criada: $output"
}

audio_models() { need curl; local output="${1:-}"; if [[ -n "$output" ]]; then mkdir_for "$output"; curl --fail --silent --show-error "${API_BASE}/models?output_modalities=speech" -o "$output"; echo "modelos TTS salvos em: $output"; else curl --fail --silent --show-error "${API_BASE}/models?output_modalities=speech"; fi; }
remove_bg() { [[ $# -ge 2 ]] || die "uso: remove-bg <entrada.png> <saída.png> [#ff00ff]"; bash "${ROOT_DIR}/scripts/mutter-creative.sh" cutout "$@"; }

command="${1:-help}"; shift || true
case "$command" in
  text) text "$@";; brief) brief "$@";; voice) voice "$@";; audio-models) audio_models "$@";; remove-bg) remove_bg "$@";; help|-h|--help) usage;; *) usage; die "comando inválido: $command";;
esac

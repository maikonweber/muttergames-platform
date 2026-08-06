#!/usr/bin/env bash
# Cliente da API dedicada de imagens da OpenRouter.
# Nunca persiste OPEN_ROUTER em arquivos ou logs.
set -euo pipefail

API_BASE="https://openrouter.ai/api/v1"
TITLE="MutterGames Creative Tools"

die() { echo "erro: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "'$1' não encontrado"; }
api_key() { printf '%s' "${OPEN_ROUTER:-${OPENROUTER_API_KEY:-}}"; }
need_key() { [[ -n "$(api_key)" ]] || die "defina OPEN_ROUTER no ambiente; não grave a chave no repositório"; }
mkdir_for() { mkdir -p "$(dirname "$1")"; }

usage() {
  cat <<'EOF'
OpenRouter Image Tools — MutterGames

Uso:
  scripts/openrouter-image.sh models [arquivo.json]
  scripts/openrouter-image.sh generate --model <modelo> --prompt <texto> --out <prefixo> [opções]

Opções de generate:
  --size <512|1K|2K|2048x2048>  --aspect-ratio <1:1|16:9|...>
  --quality <auto|low|medium|high>  --format <png|jpeg|webp|svg>
  --background <auto|transparent|opaque>  --seed <inteiro>  --n <1-10>
  --reference <URL-ou-arquivo> (repetível)

Exemplos:
  scripts/openrouter-image.sh models tmp/openrouter-image-models.json
  scripts/openrouter-image.sh generate \
    --model openai/gpt-image-2 --prompt "sprite de planeta oceânico" \
    --out assets/planets/oceanic --size 1K --aspect-ratio 1:1 \
    --format png --background transparent --seed 428771
EOF
}

base64_decode() {
  if base64 --help 2>&1 | grep -q -- '--decode'; then base64 --decode; else base64 -D; fi
}

mime_for() {
  case "${1##*.}" in
    png|PNG) echo "image/png" ;;
    jpg|JPG|jpeg|JPEG) echo "image/jpeg" ;;
    webp|WEBP) echo "image/webp" ;;
    svg|SVG) echo "image/svg+xml" ;;
    *) die "referência local sem MIME conhecido: $1" ;;
  esac
}

extension_for() {
  case "$1" in
    image/png|"" ) echo "png" ;;
    image/jpeg) echo "jpeg" ;;
    image/webp) echo "webp" ;;
    image/svg+xml) echo "svg" ;;
    *) echo "bin" ;;
  esac
}

models() {
  need curl
  local output="${1:-}"
  if [[ -n "$output" ]]; then
    mkdir_for "$output"
    curl --fail --silent --show-error "${API_BASE}/images/models" -o "$output"
    echo "modelos salvos em: $output"
  else
    curl --fail --silent --show-error "${API_BASE}/images/models"
  fi
}

generate() {
  need curl; need jq; need base64; need_key
  local model="" prompt="" out="" size="" aspect_ratio="" quality="" format="png" background="auto" seed="" count=1
  local -a reference_inputs=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model|--prompt|--out|--size|--aspect-ratio|--quality|--format|--background|--seed|--n)
        [[ $# -ge 2 ]] || die "valor ausente para $1"
        case "$1" in
          --model) model="$2" ;; --prompt) prompt="$2" ;; --out) out="$2" ;;
          --size) size="$2" ;; --aspect-ratio) aspect_ratio="$2" ;; --quality) quality="$2" ;;
          --format) format="$2" ;; --background) background="$2" ;; --seed) seed="$2" ;; --n) count="$2" ;;
        esac
        shift 2 ;;
      --reference)
        [[ $# -ge 2 ]] || die "valor ausente para --reference"
        reference_inputs+=("$2"); shift 2 ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ -n "$model" && -n "$prompt" && -n "$out" ]] || die "--model, --prompt e --out são obrigatórios"
  [[ "$count" =~ ^([1-9]|10)$ ]] || die "--n deve estar entre 1 e 10"
  [[ "$format" =~ ^(png|jpeg|webp|svg)$ ]] || die "--format inválido"
  [[ "$background" =~ ^(auto|transparent|opaque)$ ]] || die "--background inválido"
  [[ "$background" != "transparent" || "$format" == "png" || "$format" == "webp" ]] || die "transparência requer png ou webp"

  local references='[]' ref mime encoded url
  for ref in "${reference_inputs[@]}"; do
    if [[ "$ref" =~ ^https?:// ]]; then
      url="$ref"
    else
      [[ -f "$ref" ]] || die "referência não encontrada: $ref"
      mime=$(mime_for "$ref")
      encoded=$(base64 < "$ref" | tr -d '\n')
      url="data:${mime};base64,${encoded}"
    fi
    references=$(jq --arg url "$url" '. + [{"type":"image_url","image_url":{"url":$url}}]' <<< "$references")
  done

  local payload response_file index media_type extension b64
  payload=$(jq -n \
    --arg model "$model" --arg prompt "$prompt" --arg size "$size" --arg ratio "$aspect_ratio" \
    --arg quality "$quality" --arg format "$format" --arg background "$background" --arg seed "$seed" \
    --argjson n "$count" --argjson refs "$references" '
      {model:$model, prompt:$prompt, n:$n, output_format:$format, background:$background}
      + (if $size != "" then {size:$size} else {} end)
      + (if $ratio != "" then {aspect_ratio:$ratio} else {} end)
      + (if $quality != "" then {quality:$quality} else {} end)
      + (if $seed != "" then {seed:($seed|tonumber)} else {} end)
      + (if ($refs|length) > 0 then {input_references:$refs} else {} end)')
  response_file=$(mktemp)
  trap 'rm -f "$response_file"' RETURN
  if ! curl --fail-with-body --silent --show-error -X POST "${API_BASE}/images" \
    -H "Authorization: Bearer $(api_key)" \
    -H "Content-Type: application/json" \
    -H "X-Title: ${TITLE}" \
    --data "$payload" -o "$response_file"; then
    jq -r '.error.message // .message // "Falha sem mensagem da API"' "$response_file" 2>/dev/null || true
    exit 1
  fi
  [[ "$(jq '.data | length' "$response_file")" -gt 0 ]] || die "a API não devolveu imagens"
  mkdir_for "$out"
  for ((index=0; index<count; index++)); do
    media_type=$(jq -r ".data[$index].media_type // \"image/${format}\"" "$response_file")
    extension=$(extension_for "$media_type")
    b64=$(jq -r ".data[$index].b64_json" "$response_file")
    [[ "$b64" != "null" ]] || die "imagem $index não possui b64_json"
    printf '%s' "$b64" | base64_decode > "${out}-$(printf '%02d' $((index + 1))).${extension}"
  done
  echo "gerado: ${out}-01.<formato>"
  jq '{model, created, usage}' "$response_file"
}

command="${1:-help}"
shift || true
case "$command" in
  models) models "$@" ;;
  generate) generate "$@" ;;
  help|-h|--help) usage ;;
  *) usage; die "comando inválido: $command" ;;
esac

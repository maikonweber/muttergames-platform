#!/usr/bin/env bash
# Adaptador Meshy API — gera assets 3D (texto/imagem) e grava GLB locais.
# Nunca persiste MESHY_API / MESHY_API_KEY em arquivos ou logs.
# Docs: https://docs.meshy.ai/en/api/quick-start
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# jq portátil do monorepo (Windows): scripts/bin/jq.exe
export PATH="${SCRIPT_DIR}/bin:${PATH}"

API_BASE="https://api.meshy.ai/openapi"
POLL_INTERVAL_SEC="${MESHY_POLL_INTERVAL:-5}"
DEFAULT_FORMAT="glb"

die() { echo "erro: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "'$1' não encontrado"; }
# Preferência do monorepo: MESHY_API (.env); MESHY_API_KEY fica como alias.
api_key() { printf '%s' "${MESHY_API:-${MESHY_API_KEY:-}}"; }
need_key() { [[ -n "$(api_key)" ]] || die "defina MESHY_API (ou MESHY_API_KEY) no ambiente; não grave a chave no repositório"; }
mkdir_for() { mkdir -p "$(dirname "$1")"; }
auth_header() { printf 'Authorization: Bearer %s' "$(api_key)"; }

usage() {
  cat <<'EOF'
Meshy Asset Tools — MutterGames

Uso:
  scripts/meshy-asset.sh balance
  scripts/meshy-asset.sh text-to-3d --prompt <texto> --out <prefixo> [opções]
  scripts/meshy-asset.sh image-to-3d --image <URL|arquivo> --out <prefixo> [opções]
  scripts/meshy-asset.sh status --kind <text|image> --id <task_id>
  scripts/meshy-asset.sh download --kind <text|image> --id <task_id> --out <arquivo>

Opções comuns:
  --ai-model <latest|meshy-6|meshy-5>   (default: latest)
  --model-type <standard|lowpoly>       (default: standard; image também: smart-topology)
  --format <glb|fbx|obj|stl|usdz|3mf>   (default: glb)
  --polycount <N>                       target_polycount
  --pose <a-pose|t-pose>
  --pbr                                 enable_pbr=true
  --no-wait                             só cria a tarefa e imprime o id
  --poll <segundos>                     intervalo de polling (default: 5)
  --meta                                grava sidecar .meta.json junto ao modelo
  --thumbnail                           baixa thumbnail_url como <out>.preview.png

text-to-3d:
  --preview-only                        não roda refine (sem textura)
  --texture-prompt <texto>              guia de textura no refine
  --no-remesh                           should_remesh=false

image-to-3d:
  --texture-prompt <texto>
  --no-texture                          should_texture=false
  --no-remesh

Exemplos:
  export MESHY_API='msy_…'   # ou MESHY_API_KEY
  scripts/meshy-asset.sh balance
  scripts/meshy-asset.sh text-to-3d \
    --prompt "low-poly fantasy sword, game ready" \
    --out tmp/assets/sword --model-type lowpoly --meta
  scripts/meshy-asset.sh image-to-3d \
    --image assets/concepts/hero.png \
    --out tmp/assets/hero --format glb --pbr
EOF
}

# --- HTTP helpers -----------------------------------------------------------

api_post() {
  # api_post <path> <payload_json> <out_file>
  local path="$1" payload="$2" out="$3"
  local http_code
  http_code=$(curl --silent --show-error -o "$out" -w '%{http_code}' \
    -X POST "${API_BASE}${path}" \
    -H "$(auth_header)" \
    -H "Content-Type: application/json" \
    --data "$payload") || true
  if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
    echo "erro HTTP ${http_code} em POST ${path}:" >&2
    jq -r '.message // .error.message // .task_error.message // .' "$out" 2>/dev/null >&2 || cat "$out" >&2
    exit 1
  fi
}

api_get() {
  # api_get <path> <out_file>
  local path="$1" out="$2"
  local http_code
  http_code=$(curl --silent --show-error -o "$out" -w '%{http_code}' \
    "${API_BASE}${path}" \
    -H "$(auth_header)") || true
  if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
    echo "erro HTTP ${http_code} em GET ${path}:" >&2
    jq -r '.message // .error.message // .' "$out" 2>/dev/null >&2 || cat "$out" >&2
    exit 1
  fi
}

task_endpoint() {
  case "$1" in
    text) echo "/v2/text-to-3d" ;;
    image) echo "/v1/image-to-3d" ;;
    *) die "kind inválido: $1 (use text|image)" ;;
  esac
}

# --- image encoding ---------------------------------------------------------

mime_for() {
  case "${1##*.}" in
    png|PNG) echo "image/png" ;;
    jpg|JPG|jpeg|JPEG) echo "image/jpeg" ;;
    webp|WEBP) echo "image/webp" ;;
    *) die "imagem local sem MIME suportado (png/jpg/jpeg): $1" ;;
  esac
}

image_to_url() {
  local src="$1" mime encoded
  if [[ "$src" =~ ^https?:// ]] || [[ "$src" =~ ^data: ]]; then
    printf '%s' "$src"
    return
  fi
  [[ -f "$src" ]] || die "imagem não encontrada: $src"
  mime=$(mime_for "$src")
  encoded=$(base64 < "$src" | tr -d '\n')
  printf 'data:%s;base64,%s' "$mime" "$encoded"
}

# --- polling / download -----------------------------------------------------

poll_task() {
  # poll_task <kind> <task_id> <poll_sec> — imprime JSON final em stdout
  local kind="$1" id="$2" poll="$3" endpoint status progress tmp
  endpoint=$(task_endpoint "$kind")
  tmp=$(mktemp)
  while true; do
    api_get "${endpoint}/${id}" "$tmp"
    status=$(jq -r '.status // empty' "$tmp")
    progress=$(jq -r '.progress // 0' "$tmp")
    echo "status: ${status} (${progress}%) id=${id}" >&2
    case "$status" in
      SUCCEEDED|FAILED|CANCELED)
        cat "$tmp"
        rm -f "$tmp"
        return 0
        ;;
      PENDING|IN_PROGRESS|"") ;;
      *)
        rm -f "$tmp"
        die "status inesperado: ${status}"
        ;;
    esac
    sleep "$poll"
  done
}

download_model_url() {
  # download_model_url <url> <outfile>
  local url="$1" outfile="$2"
  mkdir_for "$outfile"
  curl --fail --silent --show-error -L "$url" -o "$outfile"
}

maybe_download_thumbnail() {
  # maybe_download_thumbnail <task_json> <out_prefix> <enabled true|false>
  local file="$1" out="$2" enabled="$3" url
  [[ "$enabled" == "true" ]] || return 0
  url=$(jq -r '.thumbnail_url // .alpha_thumbnail_url // empty' "$file")
  [[ -n "$url" ]] || { echo "aviso: thumbnail ausente na resposta" >&2; return 0; }
  download_model_url "$url" "${out}.preview.png"
  echo "thumbnail: ${out}.preview.png"
}

extract_model_url() {
  # extract_model_url <task_json> <format>
  local file="$1" format="$2" url
  url=$(jq -r --arg f "$format" '.model_urls[$f] // empty' "$file")
  [[ -n "$url" ]] || die "model_urls.${format} ausente na resposta"
  printf '%s' "$url"
}

write_meta() {
  # write_meta <meta_path> <kind> <task_json> <extra_json>
  local meta_path="$1" kind="$2" task_json="$3" extra="${4:-{}}"
  local extra_file
  mkdir_for "$meta_path"
  extra_file=$(mktemp)
  # Compacta para evitar quebras de linha que o jq.exe do Windows rejeita em --argjson.
  printf '%s' "$extra" | jq -c '.' > "$extra_file" || { rm -f "$extra_file"; return 1; }
  jq -n \
    --arg generator "meshy-asset" \
    --arg kind "$kind" \
    --slurpfile task "$task_json" \
    --slurpfile extra "$extra_file" '
      ($task[0]) as $t |
      {
        generator: $generator,
        kind: $kind,
        task_id: $t.id,
        status: $t.status,
        progress: $t.progress,
        model_urls: ($t.model_urls // {}),
        thumbnail_url: ($t.thumbnail_url // null),
        consumed_credits: ($t.consumed_credits // null),
        created_at: (now | todateiso8601)
      } + $extra[0]' > "$meta_path"
  local rc=$?
  rm -f "$extra_file"
  return $rc
}

# --- commands ---------------------------------------------------------------

cmd_balance() {
  need curl; need jq; need_key
  local tmp
  tmp=$(mktemp)
  api_get "/v1/balance" "$tmp"
  jq '.' "$tmp"
  rm -f "$tmp"
}

cmd_status() {
  need curl; need jq; need_key
  local kind="" id=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --kind) [[ $# -ge 2 ]] || die "valor ausente para $1"; kind="$2"; shift 2 ;;
      --id) [[ $# -ge 2 ]] || die "valor ausente para $1"; id="$2"; shift 2 ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ -n "$kind" && -n "$id" ]] || die "--kind e --id são obrigatórios"
  local endpoint tmp
  endpoint=$(task_endpoint "$kind")
  tmp=$(mktemp)
  api_get "${endpoint}/${id}" "$tmp"
  jq '{id, status, progress, model_urls, thumbnail_url, consumed_credits, task_error}' "$tmp"
  rm -f "$tmp"
}

cmd_download() {
  need curl; need jq; need_key
  local kind="" id="" out="" format="$DEFAULT_FORMAT"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --kind) kind="$2"; shift 2 ;;
      --id) id="$2"; shift 2 ;;
      --out) out="$2"; shift 2 ;;
      --format) format="$2"; shift 2 ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ -n "$kind" && -n "$id" && -n "$out" ]] || die "--kind, --id e --out são obrigatórios"
  local endpoint tmp url
  endpoint=$(task_endpoint "$kind")
  tmp=$(mktemp)
  api_get "${endpoint}/${id}" "$tmp"
  [[ "$(jq -r '.status' "$tmp")" == "SUCCEEDED" ]] || { rm -f "$tmp"; die "tarefa não está SUCCEEDED"; }
  url=$(extract_model_url "$tmp" "$format")
  download_model_url "$url" "$out"
  rm -f "$tmp"
  echo "baixado: $out"
}

cmd_text_to_3d() {
  need curl; need jq; need_key
  local prompt="" out="" ai_model="latest" model_type="standard" format="$DEFAULT_FORMAT"
  local polycount="" pose="" enable_pbr="false" preview_only="false" no_wait="false"
  local poll="$POLL_INTERVAL_SEC" write_meta_flag="false" want_thumbnail="false" texture_prompt="" should_remesh=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --prompt) prompt="$2"; shift 2 ;;
      --out) out="$2"; shift 2 ;;
      --ai-model) ai_model="$2"; shift 2 ;;
      --model-type) model_type="$2"; shift 2 ;;
      --format) format="$2"; shift 2 ;;
      --polycount) polycount="$2"; shift 2 ;;
      --pose) pose="$2"; shift 2 ;;
      --texture-prompt) texture_prompt="$2"; shift 2 ;;
      --poll) poll="$2"; shift 2 ;;
      --pbr) enable_pbr="true"; shift ;;
      --preview-only) preview_only="true"; shift ;;
      --no-wait) no_wait="true"; shift ;;
      --meta) write_meta_flag="true"; shift ;;
      --thumbnail) want_thumbnail="true"; shift ;;
      --no-remesh) should_remesh="false"; shift ;;
      --remesh) should_remesh="true"; shift ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ -n "$prompt" && -n "$out" ]] || die "--prompt e --out são obrigatórios"
  [[ ${#prompt} -le 600 ]] || die "prompt excede 600 caracteres"
  [[ "$format" =~ ^(glb|fbx|obj|stl|usdz|3mf)$ ]] || die "--format inválido"
  [[ "$model_type" =~ ^(standard|lowpoly)$ ]] || die "--model-type inválido para text-to-3d"

  local payload preview_id refine_id task_file model_path meta_path url extra
  payload=$(jq -n \
    --arg prompt "$prompt" \
    --arg ai_model "$ai_model" \
    --arg model_type "$model_type" \
    --arg format "$format" \
    --arg polycount "$polycount" \
    --arg pose "$pose" \
    --arg remesh "$should_remesh" '
      {
        mode: "preview",
        prompt: $prompt,
        ai_model: $ai_model,
        model_type: $model_type,
        target_formats: [$format]
      }
      + (if $polycount != "" then {target_polycount: ($polycount|tonumber)} else {} end)
      + (if $pose != "" then {pose_mode: $pose} else {} end)
      + (if $remesh != "" then {should_remesh: ($remesh == "true")} else {} end)')

  task_file=$(mktemp)
  api_post "/v2/text-to-3d" "$payload" "$task_file"
  preview_id=$(jq -r '.result // .id // empty' "$task_file")
  [[ -n "$preview_id" ]] || { rm -f "$task_file"; die "API não devolveu task id no preview"; }
  echo "preview task: $preview_id" >&2

  if [[ "$no_wait" == "true" ]]; then
    jq -n --arg id "$preview_id" --arg mode "preview" '{id: $id, mode: $mode, status: "PENDING"}'
    rm -f "$task_file"
    return 0
  fi

  poll_task text "$preview_id" "$poll" > "$task_file"
  [[ "$(jq -r '.status' "$task_file")" == "SUCCEEDED" ]] || \
    { msg=$(jq -r '.task_error.message // "sem mensagem"' "$task_file"); rm -f "$task_file"; die "preview falhou: $msg"; }

  if [[ "$preview_only" == "true" ]]; then
    model_path="${out}.${format}"
    url=$(extract_model_url "$task_file" "$format")
    download_model_url "$url" "$model_path"
    echo "modelo (preview): $model_path"
    maybe_download_thumbnail "$task_file" "$out" "$want_thumbnail"
    if [[ "$write_meta_flag" == "true" ]]; then
      meta_path="${out}.meta.json"
      extra=$(jq -n --arg prompt "$prompt" --arg mode "preview" \
        --arg ai_model "$ai_model" --arg model_type "$model_type" \
        '{prompt:$prompt, mode:$mode, ai_model:$ai_model, model_type:$model_type}')
      write_meta "$meta_path" text "$task_file" "$extra" || echo "aviso: meta não gravado" >&2
      echo "meta: $meta_path"
    fi
    jq '{id, status, progress, model_urls, consumed_credits}' "$task_file"
    rm -f "$task_file"
    return 0
  fi

  payload=$(jq -n \
    --arg preview_id "$preview_id" \
    --arg ai_model "$ai_model" \
    --arg format "$format" \
    --arg texture_prompt "$texture_prompt" \
    --argjson pbr "$enable_pbr" '
      {
        mode: "refine",
        preview_task_id: $preview_id,
        ai_model: $ai_model,
        enable_pbr: $pbr,
        target_formats: [$format]
      }
      + (if $texture_prompt != "" then {texture_prompt: $texture_prompt} else {} end)')

  api_post "/v2/text-to-3d" "$payload" "$task_file"
  refine_id=$(jq -r '.result // .id // empty' "$task_file")
  [[ -n "$refine_id" ]] || { rm -f "$task_file"; die "API não devolveu task id no refine"; }
  echo "refine task: $refine_id" >&2

  poll_task text "$refine_id" "$poll" > "$task_file"
  [[ "$(jq -r '.status' "$task_file")" == "SUCCEEDED" ]] || \
    { msg=$(jq -r '.task_error.message // "sem mensagem"' "$task_file"); rm -f "$task_file"; die "refine falhou: $msg"; }

  model_path="${out}.${format}"
  url=$(extract_model_url "$task_file" "$format")
  download_model_url "$url" "$model_path"
  echo "modelo: $model_path"
  maybe_download_thumbnail "$task_file" "$out" "$want_thumbnail"

  if [[ "$write_meta_flag" == "true" ]]; then
    meta_path="${out}.meta.json"
    extra=$(jq -n \
      --arg prompt "$prompt" \
      --arg preview_id "$preview_id" \
      --arg refine_id "$refine_id" \
      --arg ai_model "$ai_model" \
      --arg model_type "$model_type" \
      --arg texture_prompt "$texture_prompt" \
      '{
        prompt: $prompt,
        mode: "refine",
        preview_task_id: $preview_id,
        refine_task_id: $refine_id,
        ai_model: $ai_model,
        model_type: $model_type
      }
      + (if $texture_prompt != "" then {texture_prompt: $texture_prompt} else {} end)')
    write_meta "$meta_path" text "$task_file" "$extra" || echo "aviso: meta não gravado" >&2
    echo "meta: $meta_path"
  fi
  jq '{id, status, progress, model_urls, thumbnail_url, consumed_credits}' "$task_file"
  rm -f "$task_file"
}

cmd_image_to_3d() {
  need curl; need jq; need_key; need base64
  local image="" out="" ai_model="latest" model_type="standard" format="$DEFAULT_FORMAT"
  local polycount="" pose="" enable_pbr="false" no_wait="false" poll="$POLL_INTERVAL_SEC"
  local write_meta_flag="false" want_thumbnail="false" texture_prompt="" should_texture="true" should_remesh=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --image) image="$2"; shift 2 ;;
      --out) out="$2"; shift 2 ;;
      --ai-model) ai_model="$2"; shift 2 ;;
      --model-type) model_type="$2"; shift 2 ;;
      --format) format="$2"; shift 2 ;;
      --polycount) polycount="$2"; shift 2 ;;
      --pose) pose="$2"; shift 2 ;;
      --texture-prompt) texture_prompt="$2"; shift 2 ;;
      --poll) poll="$2"; shift 2 ;;
      --pbr) enable_pbr="true"; shift ;;
      --no-wait) no_wait="true"; shift ;;
      --meta) write_meta_flag="true"; shift ;;
      --thumbnail) want_thumbnail="true"; shift ;;
      --no-texture) should_texture="false"; shift ;;
      --no-remesh) should_remesh="false"; shift ;;
      --remesh) should_remesh="true"; shift ;;
      *) die "opção desconhecida: $1" ;;
    esac
  done
  [[ -n "$image" && -n "$out" ]] || die "--image e --out são obrigatórios"
  [[ "$format" =~ ^(glb|fbx|obj|stl|usdz|3mf)$ ]] || die "--format inválido"
  [[ "$model_type" =~ ^(standard|lowpoly|smart-topology)$ ]] || die "--model-type inválido"

  local image_url task_id task_file model_path meta_path url payload extra
  image_url=$(image_to_url "$image")

  payload=$(jq -n \
    --arg image_url "$image_url" \
    --arg ai_model "$ai_model" \
    --arg model_type "$model_type" \
    --arg format "$format" \
    --arg polycount "$polycount" \
    --arg pose "$pose" \
    --arg texture_prompt "$texture_prompt" \
    --arg remesh "$should_remesh" \
    --argjson pbr "$enable_pbr" \
    --argjson texture "$should_texture" '
      {
        image_url: $image_url,
        ai_model: $ai_model,
        model_type: $model_type,
        enable_pbr: $pbr,
        should_texture: $texture,
        target_formats: [$format]
      }
      + (if $polycount != "" then {target_polycount: ($polycount|tonumber)} else {} end)
      + (if $pose != "" then {pose_mode: $pose} else {} end)
      + (if $texture_prompt != "" then {texture_prompt: $texture_prompt} else {} end)
      + (if $remesh != "" then {should_remesh: ($remesh == "true")} else {} end)')

  task_file=$(mktemp)
  api_post "/v1/image-to-3d" "$payload" "$task_file"
  task_id=$(jq -r '.result // .id // empty' "$task_file")
  [[ -n "$task_id" ]] || { rm -f "$task_file"; die "API não devolveu task id"; }
  echo "image-to-3d task: $task_id" >&2

  if [[ "$no_wait" == "true" ]]; then
    jq -n --arg id "$task_id" '{id: $id, kind: "image", status: "PENDING"}'
    rm -f "$task_file"
    return 0
  fi

  poll_task image "$task_id" "$poll" > "$task_file"
  [[ "$(jq -r '.status' "$task_file")" == "SUCCEEDED" ]] || \
    { msg=$(jq -r '.task_error.message // "sem mensagem"' "$task_file"); rm -f "$task_file"; die "image-to-3d falhou: $msg"; }

  model_path="${out}.${format}"
  url=$(extract_model_url "$task_file" "$format")
  download_model_url "$url" "$model_path"
  echo "modelo: $model_path"
  maybe_download_thumbnail "$task_file" "$out" "$want_thumbnail"

  if [[ "$write_meta_flag" == "true" ]]; then
    meta_path="${out}.meta.json"
    extra=$(jq -n \
      --arg image "$image" \
      --arg ai_model "$ai_model" \
      --arg model_type "$model_type" \
      --arg texture_prompt "$texture_prompt" \
      '{
        image_source: $image,
        ai_model: $ai_model,
        model_type: $model_type
      }
      + (if $texture_prompt != "" then {texture_prompt: $texture_prompt} else {} end)')
    write_meta "$meta_path" image "$task_file" "$extra" || echo "aviso: meta não gravado" >&2
    echo "meta: $meta_path"
  fi
  jq '{id, status, progress, model_urls, thumbnail_url, consumed_credits}' "$task_file"
  rm -f "$task_file"
}

# --- entrypoint -------------------------------------------------------------

command="${1:-help}"
shift || true
case "$command" in
  balance) cmd_balance "$@" ;;
  text-to-3d) cmd_text_to_3d "$@" ;;
  image-to-3d) cmd_image_to_3d "$@" ;;
  status) cmd_status "$@" ;;
  download) cmd_download "$@" ;;
  help|-h|--help) usage ;;
  *) usage; die "comando inválido: $command" ;;
esac

#!/usr/bin/env bash
# MutterGames Creative Tools — utilitários portáveis para assets de jogos.
# Dependências opcionais: ImageMagick (magick) e FFmpeg (ffmpeg).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() { echo "erro: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "'$1' não encontrado. Veja scripts/creative-tools/README.md"; }
mkdir_for() { mkdir -p "$(dirname "$1")"; }

usage() {
  cat <<'EOF'
MutterGames Creative Tools

Uso: scripts/mutter-creative.sh <comando> [opções]

Comandos:
  doctor                                      Verifica dependências opcionais.
  crop <entrada> <saída> <LxA> [gravidade]   Recorta (center, north, south, east, west).
  cutout <entrada> <saída> [cor]              Remove fundo de cor sólida (padrão #ff00ff).
  sheet <pasta-frames> <saída> <colunas>     Cria spritesheet a partir de PNGs ordenados.
  vfx <forge|nova|collect> <pasta> [tamanho] [frames]
                                              Cria frames PNG de VFX procedural.
  sfx <forge|collect|error|nova> <saída.wav> [segundos]
                                              Cria efeito sonoro WAV procedural.
  music <ambient|tension|victory> <saída.wav> [segundos]
                                              Cria loop musical WAV procedural.
  prompt <asset|vfx|music> <arquivo.md> <texto>
                                              Cria um brief pronto para geração assistida por IA.
  spriteframes <texture> <saída.tres> <L> <A> <colunas> <linhas> [fps]
                                              Cria um recurso SpriteFrames do Godot a partir de atlas.
  manifest <pasta-assets> <saída.json>        Cria catálogo JSON de PNG, WAV e OGG.
  validate <pasta-assets>                     Valida tamanhos de imagem e áudio quando houver ferramentas.
  scaffold <hud|pickup|vfx> <saída.gd>        Cria script Godot reutilizável.

Exemplos:
  scripts/mutter-creative.sh crop art.png assets/icon.png 256x256 center
  scripts/mutter-creative.sh cutout planet-key.png assets/planet.png '#ff00ff'
  scripts/mutter-creative.sh vfx forge assets/vfx/forge 256 12
  scripts/mutter-creative.sh sfx forge assets/audio/forge.wav 0.6
  scripts/mutter-creative.sh music ambient assets/music/space-loop.wav 24
  scripts/mutter-creative.sh spriteframes res://assets/vfx/forge-sheet.png assets/vfx/forge.tres 256 256 4 3 12
EOF
}

doctor() {
  echo "MutterGames Creative Tools"
  for tool in magick ffmpeg; do
    if command -v "$tool" >/dev/null 2>&1; then echo "[ok] $tool"; else echo "[--] $tool (opcional)"; fi
  done
  echo "Diretório do workspace: $ROOT_DIR"
}

crop() {
  [[ $# -ge 3 ]] || die "uso: crop <entrada> <saída> <LxA> [gravidade]"
  need magick
  local input="$1" output="$2" dimensions="$3" gravity="${4:-center}"
  [[ -f "$input" ]] || die "arquivo não encontrado: $input"
  mkdir_for "$output"
  magick "$input" -gravity "$gravity" -resize "${dimensions}^" -crop "$dimensions+0+0" +repage "$output"
  echo "recorte criado: $output"
}

cutout() {
  [[ $# -ge 2 ]] || die "uso: cutout <entrada> <saída> [cor]"
  need magick
  local input="$1" output="$2" key="${3:-#ff00ff}"
  [[ -f "$input" ]] || die "arquivo não encontrado: $input"
  mkdir_for "$output"
  magick "$input" -alpha on -fuzz 10% -transparent "$key" "$output"
  echo "fundo removido: $output"
}

sheet() {
  [[ $# -eq 3 ]] || die "uso: sheet <pasta-frames> <saída> <colunas>"
  need magick
  local frames_dir="$1" output="$2" columns="$3"
  [[ -d "$frames_dir" ]] || die "pasta não encontrada: $frames_dir"
  local -a frames=()
  while IFS= read -r -d '' frame; do frames+=("$frame"); done < <(find "$frames_dir" -maxdepth 1 -type f -name '*.png' -print0 | sort -z)
  [[ ${#frames[@]} -gt 0 ]] || die "nenhum PNG em: $frames_dir"
  mkdir_for "$output"
  magick montage "${frames[@]}" -background none -tile "${columns}x" -geometry +0+0 "$output"
  echo "spritesheet criado: $output"
}

vfx_svg() {
  local kind="$1" output="$2" size="$3" progress="$4"
  local primary="#55D9FF" secondary="#FFC857"
  [[ "$kind" == "nova" ]] && { primary="#FF5D79"; secondary="#FF875C"; }
  [[ "$kind" == "collect" ]] && { primary="#62E6A7"; secondary="#55D9FF"; }
  local radius core opacity
  radius=$(awk "BEGIN { printf \"%.2f\", $size * (0.14 + 0.42 * $progress) }")
  core=$(awk "BEGIN { printf \"%.2f\", $size * (0.20 * (1 - $progress) + 0.03) }")
  opacity=$(awk "BEGIN { printf \"%.2f\", 1 - $progress * 0.75 }")
  cat > "$output" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 $size $size">
  <defs><radialGradient id="g"><stop stop-color="#ffffff"/><stop offset=".25" stop-color="$secondary"/><stop offset="1" stop-color="$primary" stop-opacity="0"/></radialGradient></defs>
  <g transform="translate($((size / 2)) $((size / 2)))" opacity="$opacity">
    <circle r="$radius" fill="none" stroke="$primary" stroke-width="$((size / 48 + 1))" opacity=".82"/>
    <circle r="$core" fill="url(#g)"/>
    <g fill="$secondary">
      <path d="M0 -$((size / 2 - 8)) l5 22 h-10z"/><path d="M0 $((size / 2 - 8)) l5 -22 h-10z"/>
      <path d="M-$((size / 2 - 8)) 0 l22 5 v-10z"/><path d="M$((size / 2 - 8)) 0 l-22 5 v-10z"/>
    </g>
  </g>
</svg>
EOF
}

vfx() {
  [[ $# -ge 2 ]] || die "uso: vfx <forge|nova|collect> <pasta> [tamanho] [frames]"
  need magick
  local kind="$1" output_dir="$2" size="${3:-256}" frames="${4:-12}"
  [[ "$kind" =~ ^(forge|nova|collect)$ ]] || die "VFX inválido: $kind"
  [[ "$frames" -ge 2 ]] || die "o VFX precisa de pelo menos 2 frames"
  mkdir -p "$output_dir"
  local index tmp_svg progress
  for ((index=0; index<frames; index++)); do
    progress=$(awk "BEGIN { printf \"%.4f\", $index / ($frames - 1) }")
    tmp_svg="${output_dir}/.frame-${index}.svg"
    vfx_svg "$kind" "$tmp_svg" "$size" "$progress"
    magick -background none "$tmp_svg" "${output_dir}/$(printf 'frame-%02d.png' "$index")"
    rm -f "$tmp_svg"
  done
  echo "VFX criado: $output_dir ($frames frames)"
}

sfx() {
  [[ $# -ge 2 ]] || die "uso: sfx <forge|collect|error|nova> <saída.wav> [segundos]"
  need ffmpeg
  local kind="$1" output="$2" duration="${3:-0.6}" expression
  case "$kind" in
    forge) expression='0.34*sin(2*PI*(150+1250*t)*t)*exp(-5*t)+0.10*random(0)*exp(-16*t)' ;;
    collect) expression='0.25*sin(2*PI*(520+640*t)*t)*exp(-7*t)' ;;
    error) expression='0.22*sin(2*PI*(210-85*t)*t)*exp(-8*t)' ;;
    nova) expression='0.42*sin(2*PI*(62+90*t)*t)*exp(-2.3*t)+0.20*random(0)*exp(-4*t)' ;;
    *) die "SFX inválido: $kind" ;;
  esac
  mkdir_for "$output"
  ffmpeg -y -hide_banner -loglevel error -f lavfi -i "aevalsrc=${expression}:s=48000:d=${duration}" -af 'alimiter=limit=0.9' -c:a pcm_s16le "$output"
  echo "SFX criado: $output"
}

music() {
  [[ $# -ge 2 ]] || die "uso: music <ambient|tension|victory> <saída.wav> [segundos]"
  need ffmpeg
  local kind="$1" output="$2" duration="${3:-24}" expression fade_start
  case "$kind" in
    ambient) expression='0.10*sin(2*PI*110*t)+0.06*sin(2*PI*164.81*t)+0.035*sin(2*PI*220*t)*(0.5+0.5*sin(2*PI*0.125*t))' ;;
    tension) expression='0.08*sin(2*PI*92.5*t)+0.06*sin(2*PI*138.59*t)+0.035*sin(2*PI*196*t)*(0.5+0.5*sin(2*PI*0.35*t))' ;;
    victory) expression='0.075*sin(2*PI*261.63*t)+0.06*sin(2*PI*329.63*t)+0.05*sin(2*PI*392*t)*(0.5+0.5*sin(2*PI*0.5*t))' ;;
    *) die "música inválida: $kind" ;;
  esac
  mkdir_for "$output"
  fade_start=$(awk "BEGIN { print ($duration > 1.6 ? $duration - 0.8 : 0) }")
  ffmpeg -y -hide_banner -loglevel error -f lavfi -i "aevalsrc=${expression}:s=48000:d=${duration}" -af "afade=t=in:st=0:d=0.8,afade=t=out:st=${fade_start}:d=0.8,alimiter=limit=0.75" -c:a pcm_s16le "$output"
  echo "loop musical criado: $output"
}

prompt() {
  [[ $# -ge 3 ]] || die "uso: prompt <asset|vfx|music> <arquivo.md> <texto>"
  local category="$1" output="$2" brief="$3"
  [[ "$category" =~ ^(asset|vfx|music)$ ]] || die "categoria inválida: $category"
  mkdir_for "$output"
  cat > "$output" <<EOF
# Brief de geração — MutterGames

- Categoria: $category
- Pedido: $brief
- Uso: jogo desktop/mobile, asset isolado e reutilizável
- Linguagem: pixel-art contemporânea, leitura clara em tamanhos pequenos, sem texto nem watermark
- Paleta: fundo espaço profundo, ciano cósmico, violeta nebulosa, dourado solar e verde de vida quando apropriado
- Entrega: PNG quadrado com fundo cromakey #FF00FF, sujeito centralizado, margens generosas e sem sombra no chão
- Recorte posterior: `scripts/mutter-creative.sh cutout <entrada> <saída> '#ff00ff'`
EOF
  echo "brief criado: $output"
}

spriteframes() {
  [[ $# -ge 6 ]] || die "uso: spriteframes <texture> <saída.tres> <L> <A> <colunas> <linhas> [fps]"
  local texture="$1" output="$2" frame_width="$3" frame_height="$4" columns="$5" rows="$6" fps="${7:-12}"
  [[ "$texture" == res://* ]] || die "a textura precisa usar caminho Godot res://"
  [[ "$frame_width" -gt 0 && "$frame_height" -gt 0 && "$columns" -gt 0 && "$rows" -gt 0 ]] || die "dimensões e grade devem ser positivas"
  mkdir_for "$output"
  local total=$((columns * rows)) index x y
  {
    printf '[gd_resource type="SpriteFrames" load_steps=%d format=3]\n' "$((total + 2))"
    echo
    printf '[ext_resource type="Texture2D" path="%s" id="1_texture"]\n' "$texture"
    echo
    for ((index=0; index<total; index++)); do
      x=$(((index % columns) * frame_width))
      y=$(((index / columns) * frame_height))
      printf '[sub_resource type="AtlasTexture" id="AtlasTexture_%d"]\n' "$index"
      echo 'atlas = ExtResource("1_texture")'
      printf 'region = Rect2(%d, %d, %d, %d)\n\n' "$x" "$y" "$frame_width" "$frame_height"
    done
    echo '[resource]'
    echo 'animations = [{'
    echo '"frames": ['
    for ((index=0; index<total; index++)); do
      printf '{"duration": 1.0, "texture": SubResource("AtlasTexture_%d")}%s\n' "$index" ","
    done
    echo '],'
    echo '"loop": true,'
    echo '"name": &"default",'
    printf '"speed": %s\n' "$fps"
    echo '}]'
  } > "$output"
  echo "SpriteFrames criado: $output ($total frames @ ${fps} fps)"
}

manifest() {
  [[ $# -eq 2 ]] || die "uso: manifest <pasta-assets> <saída.json>"
  local asset_dir="$1" output="$2" first=1 file relative extension
  [[ -d "$asset_dir" ]] || die "pasta não encontrada: $asset_dir"
  mkdir_for "$output"
  {
    echo '{'
    echo '  "generator": "mutter-creative",'
    echo '  "assets": ['
    while IFS= read -r -d '' file; do
      relative="${file#"$asset_dir"/}"
      extension="${file##*.}"
      [[ $first -eq 1 ]] || echo ','
      first=0
      printf '    {"path":"%s","extension":"%s"}' "$relative" "$extension"
    done < <(find "$asset_dir" -type f \( -iname '*.png' -o -iname '*.wav' -o -iname '*.ogg' -o -iname '*.svg' \) -print0 | sort -z)
    echo
    echo '  ]'
    echo '}'
  } > "$output"
  echo "manifesto criado: $output"
}

validate() {
  [[ $# -eq 1 ]] || die "uso: validate <pasta-assets>"
  local asset_dir="$1" file bad=0
  [[ -d "$asset_dir" ]] || die "pasta não encontrada: $asset_dir"
  if command -v magick >/dev/null 2>&1; then
    while IFS= read -r -d '' file; do
      local dimensions
      dimensions=$(magick identify -format '%w %h' "$file") || { echo "[erro] PNG inválido: $file"; bad=1; continue; }
      echo "[imagem] ${file#$asset_dir/} — ${dimensions}px"
    done < <(find "$asset_dir" -type f -iname '*.png' -print0 | sort -z)
  else
    echo "[pular] ImageMagick ausente: imagens não foram inspecionadas."
  fi
  if command -v ffprobe >/dev/null 2>&1; then
    while IFS= read -r -d '' file; do
      local details
      details=$(ffprobe -v error -show_entries stream=codec_name,sample_rate,channels -of default=noprint_wrappers=1 "$file") || { echo "[erro] áudio inválido: $file"; bad=1; continue; }
      echo "[áudio] ${file#$asset_dir/} — ${details//$'\n'/, }"
    done < <(find "$asset_dir" -type f \( -iname '*.wav' -o -iname '*.ogg' \) -print0 | sort -z)
  else
    echo "[pular] FFprobe ausente: áudio não foi inspecionado."
  fi
  [[ $bad -eq 0 ]] || exit 1
  echo "validação concluída."
}

scaffold() {
  [[ $# -eq 2 ]] || die "uso: scaffold <hud|pickup|vfx> <saída.gd>"
  local kind="$1" output="$2"
  mkdir_for "$output"
  case "$kind" in
    hud)
      cat > "$output" <<'EOF'
class_name GameHud
extends Control

signal pause_requested

func set_resource(resource_name: String, amount: float, rate := 0.0) -> void:
	var label := get_node_or_null("Resources/%s" % resource_name) as Label
	if label != null:
		label.text = "%s: %d (%+.1f/min)" % [resource_name, amount, rate]

func _on_pause_pressed() -> void:
	pause_requested.emit()
EOF
      ;;
    pickup)
      cat > "$output" <<'EOF'
class_name ResourcePickup
extends Area2D

@export var resource_type := "Materia"
@export var amount := 1.0
signal collected(resource_type: String, amount: float)

func _on_body_entered(_body: Node2D) -> void:
	collected.emit(resource_type, amount)
	queue_free()
EOF
      ;;
    vfx)
      cat > "$output" <<'EOF'
class_name OneShotVfx
extends AnimatedSprite2D

@export var lifetime := 0.6

func play_at(world_position: Vector2) -> void:
	global_position = world_position
	visible = true
	play()
	await get_tree().create_timer(lifetime).timeout
	queue_free()
EOF
      ;;
    *) die "scaffold inválido: $kind" ;;
  esac
  echo "scaffold criado: $output"
}

command="${1:-help}"
shift || true
case "$command" in
  doctor) doctor "$@" ;;
  crop) crop "$@" ;;
  cutout) cutout "$@" ;;
  sheet) sheet "$@" ;;
  vfx) vfx "$@" ;;
  sfx) sfx "$@" ;;
  music) music "$@" ;;
  prompt) prompt "$@" ;;
  spriteframes) spriteframes "$@" ;;
  manifest) manifest "$@" ;;
  validate) validate "$@" ;;
  scaffold) scaffold "$@" ;;
  help|-h|--help) usage ;;
  *) usage; die "comando inválido: $command" ;;
esac

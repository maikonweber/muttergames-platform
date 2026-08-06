#!/usr/bin/env bash
# Scaffolds e validações simples, sem dependências, para jogos MutterGames.
set -euo pipefail

die() { echo "erro: $*" >&2; exit 1; }
mkdir_for() { mkdir -p "$(dirname "$1")"; }

usage() {
  cat <<'EOF'
MutterGames Game Kit

Uso: scripts/mutter-gamekit.sh <comando> [opções]

Comandos:
  data <item|quest|dialogue|npc|resource> <saída.json>   Cria schema de dados inicial.
  locale <saída.csv> [pt-BR,en-US,es-ES]                 Cria catálogo CSV de localização.
  locale-check <arquivo.csv>                             Falha se existir chave/texto ausente.
  component <health|state-machine|save-data> <saída.gd>  Cria componente Godot.
  release-notes <versão> <saída.md>                      Cria notas de release editáveis.
  loop <nome-jogo> <saída.md>                            Cria canvas de loop de jogo.
EOF
}

data() {
  [[ $# -eq 2 ]] || die "uso: data <item|quest|dialogue|npc|resource> <saída.json>"
  local kind="$1" output="$2"; mkdir_for "$output"
  case "$kind" in
    item) printf '%s\n' '{"id":"item.example","name_key":"item.example.name","description_key":"item.example.description","rarity":"common","stack_limit":99,"tags":[],"effects":[]}' > "$output" ;;
    quest) printf '%s\n' '{"id":"quest.example","title_key":"quest.example.title","summary_key":"quest.example.summary","objectives":[{"id":"objective.01","kind":"collect","target":"resource.example","amount":1}],"rewards":[],"prerequisites":[]}' > "$output" ;;
    dialogue) printf '%s\n' '{"id":"dialogue.example","speaker_id":"npc.example","nodes":[{"id":"start","text_key":"dialogue.example.start","choices":[]}]}' > "$output" ;;
    npc) printf '%s\n' '{"id":"npc.example","name_key":"npc.example.name","role":"guide","dialogue_ids":[],"tags":[]}' > "$output" ;;
    resource) printf '%s\n' '{"id":"resource.example","name_key":"resource.example.name","icon":"res://assets/icons/resource.png","initial":0,"minimum":0,"maximum":999,"format":"integer"}' > "$output" ;;
    *) die "tipo inválido: $kind" ;;
  esac
  echo "schema criado: $output"
}

locale() {
  [[ $# -ge 1 ]] || die "uso: locale <saída.csv> [pt-BR,en-US,es-ES]"
  local output="$1" languages="${2:-pt-BR,en-US,es-ES}" language play settings; mkdir_for "$output"
  printf 'key,%s,context\n' "$languages" > "$output"
  play=""; settings=""
  IFS=',' read -r -a locale_languages <<< "$languages"
  for language in "${locale_languages[@]}"; do
    case "$language" in
      pt-BR) play+="Jogar,"; settings+="Configurações," ;;
      en-US) play+="Play,"; settings+="Settings," ;;
      es-ES) play+="Jugar,"; settings+="Ajustes," ;;
      *) play+="TODO,"; settings+="TODO," ;;
    esac
  done
  printf 'ui.play,%sbotão principal\n' "$play" >> "$output"
  printf 'ui.settings,%sbotão de menu\n' "$settings" >> "$output"
  echo "catálogo criado: $output"
}

locale_check() {
  [[ $# -eq 1 ]] || die "uso: locale-check <arquivo.csv>"
  local file="$1"; [[ -f "$file" ]] || die "arquivo não encontrado: $file"
  awk -F',' '
    NR == 1 { expected = NF; next }
    NF != expected || $1 == "" { printf "linha inválida %d\n", NR; invalid = 1; next }
    { for (i = 2; i < NF; i++) if ($i == "") { printf "tradução ausente na linha %d, coluna %d\n", NR, i; invalid = 1 } }
    END { exit invalid }
  ' "$file"
  echo "localização válida: $file"
}

component() {
  [[ $# -eq 2 ]] || die "uso: component <health|state-machine|save-data> <saída.gd>"
  local kind="$1" output="$2"; mkdir_for "$output"
  case "$kind" in
    health) cat > "$output" <<'EOF'
class_name HealthComponent
extends Node

signal changed(current: float, maximum: float)
signal depleted
@export var maximum := 100.0
var current := maximum

func apply_damage(amount: float) -> void:
	current = maxf(0.0, current - maxf(0.0, amount))
	changed.emit(current, maximum)
	if current <= 0.0: depleted.emit()

func heal(amount: float) -> void:
	current = minf(maximum, current + maxf(0.0, amount))
	changed.emit(current, maximum)
EOF
    ;;
    state-machine) cat > "$output" <<'EOF'
class_name StateMachineComponent
extends Node

signal state_changed(previous: StringName, current: StringName)
var current_state: StringName = &"idle"

func transition(next_state: StringName) -> void:
	if next_state == current_state: return
	var previous := current_state
	current_state = next_state
	state_changed.emit(previous, current_state)
EOF
    ;;
    save-data) cat > "$output" <<'EOF'
class_name SaveDataComponent
extends RefCounted

func serialize() -> Dictionary:
	return {}

func deserialize(_data: Dictionary) -> void:
	pass
EOF
    ;;
    *) die "componente inválido: $kind" ;;
  esac
  echo "componente criado: $output"
}

release_notes() {
  [[ $# -eq 2 ]] || die "uso: release-notes <versão> <saída.md>"
  local version="$1" output="$2"; mkdir_for "$output"
  cat > "$output" <<EOF
# Release $version

## Destaques

- [ ] Descreva a principal novidade para jogadores.

## Adicionado

- [ ]

## Corrigido

- [ ]

## Conhecido

- [ ] Limitações conhecidas e workaround.

## Verificação

- [ ] Save carregado e atualizado quando necessário.
- [ ] Fluxo principal testado em build de release.
- [ ] Acessibilidade e controles revisados.
EOF
  echo "notas criadas: $output"
}

loop_canvas() {
  [[ $# -eq 2 ]] || die "uso: loop <nome-jogo> <saída.md>"
  local game="$1" output="$2"; mkdir_for "$output"
  cat > "$output" <<EOF
# Loop de jogo — $game

## Fantasia do jogador

- [ ] O que o jogador faz e por que isso é prazeroso?

## Loop de 30 segundos

1. [ ] Ação do jogador
2. [ ] Feedback imediato
3. [ ] Recompensa/recurso
4. [ ] Próxima decisão

## Loop de sessão

- Entrada → objetivo curto → escolha → marco → motivo para retornar.

## Riscos de design

- [ ] Grind sem decisão
- [ ] Recompensa sem feedback
- [ ] Complexidade apresentada cedo demais
EOF
  echo "canvas criado: $output"
}

command="${1:-help}"; shift || true
case "$command" in
  data) data "$@";; locale) locale "$@";; locale-check) locale_check "$@";; component) component "$@";; release-notes) release_notes "$@";; loop) loop_canvas "$@";; help|-h|--help) usage;; *) usage; die "comando inválido: $command";;
esac

# Project Fallen Tactics

RPG Roguelike **Tactical Deckbuilder** — Vertical Slice (Godot 4).

## High Concept

**Um só modo:** combate tático iso em **campo amplo com fog of war**, party de **3 heróis** e decks por personagem.

**Main scene:** `scenes/combat/combat_scene.tscn`

## Como abrir

1. Godot 4.3+ (testado com 4.7)
2. Importar pasta `project-fallen-tactics`
3. F5 / Play

Ou pela linha de comando:

```text
Godot_v4.7-stable_win64.exe --path "C:\Users\plugify\Documents\project-fallen-tactics"
```

## Controles

| Input | Ação |
|--------|------|
| Clique na carta | Seleciona |
| Clique no grid | Alvo (tile / inimigo) |
| Espaço | Fim do turno |
| Esc | Cancela alvo |

## Vertical Slice

- 1 classe: **Espadachim**
- 15+ cartas data-driven (`CardLibrary`)
- 3 inimigos com personalidade (Goblin flanqueia, Orc avança, Arqueiro busca elevação)
- Boss **Capitão** com fases (mapa + reforços + timeline)
- Grid 8×6, terreno (água, muro, pit, elevação)
- Timeline dinâmica, energia, posturas, block, flanco/costas
- Progressão entre 3 combates + recompensa de carta

## Estrutura

```text
scripts/
  autoload/game_state.gd   # run state
  combat/                  # grid, unit, effects, AI, manager
  data/                    # CardDef, CardLibrary
  ui/combat_ui.gd
scenes/combat/combat_scene.tscn
```

## Pilares (filtro de design)

1. Toda carta = escolha
2. Posicionamento importa
3. Terreno importa
4. Equipamentos mudam cartas (próximo passo)
5. Cada classe joga diferente
6. Toda run é única

## Documentação

Índice completo: [`docs/README.md`](docs/README.md)

| Doc | Assunto |
|-----|---------|
| [`docs/GAME_OVERVIEW.md`](docs/GAME_OVERVIEW.md) | Documento do jogo (visão, pilares, loops) |
| [`docs/STATE_PROMPT.md`](docs/STATE_PROMPT.md) | Estado atual do protótipo (contexto para agentes) |
| [`docs/ROADMAP_3V3_WORLD.md`](docs/ROADMAP_3V3_WORLD.md) | Roadmap 3v3 + zona + XP + atividades |
| [`docs/ASSETS_AND_ANIMATIONS.md`](docs/ASSETS_AND_ANIMATIONS.md) | Assets, animações, VFX e UI de arte |
| [`docs/ASSET_INSTRUCTIONS.md`](docs/ASSET_INSTRUCTIONS.md) | Instruções detalhadas por cada asset |
| [`docs/P1_PRODUCTION_CHECKLIST.md`](docs/P1_PRODUCTION_CHECKLIST.md) | Checklist de produção P1 |
| [`docs/P1_production_sheet.csv`](docs/P1_production_sheet.csv) | Planilha de assets (status todo/ingame) |
| [`docs/MULTIPLAYER.md`](docs/MULTIPLAYER.md) | Multiplayer (co-op, versus, autoridade) |
| [`docs/PORTABILITY.md`](docs/PORTABILITY.md) | Portabilidade (PC, Deck, Web, mobile) |
| [`docs/NETWORKING_SERVERS.md`](docs/NETWORKING_SERVERS.md) | Servidores WebSocket e UDP |

Atualize esses arquivos quando o estado do jogo ou o plano mudar de forma relevante.

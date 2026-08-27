# PRJ-05 — Fallen Tactics

**Pasta canônica:** `Fallen Tactics/project-fallen-tactics/`  
**Engine:** Godot 4.7 (Forward+)  
**Status:** Vertical slice jogável + **PVP Online 1v1** (lobby + arena + fallen-gs)  
**Owner:** Game Director / Eng do jogo

## 1. High concept

RPG + deckbuilding + tática em grid isométrico. Cartas são escolhas (posição, timing, terreno) — nunca só “+dano”.

## 2. Estado técnico

| Item | Valor |
|---|---|
| Main scene | `res://scenes/ui/main_menu.tscn` |
| Autoloads | `GameState`, `AudioBus`, `NetClient`, `MultiplayerSession` |
| Resolução | 1280×720 |
| Loop | Menu → mapa de nós / combate; **PVP Online** → lobby → arena |
| Legado | `project-fallen-tactics-(4.3)/` — não evoluir |

Contexto vivo para agentes: [`docs/STATE_PROMPT.md`](../../Fallen%20Tactics/project-fallen-tactics/docs/STATE_PROMPT.md).

## 3. Requisitos de produto (resumo)

| ID | Requisito | Status |
|---|---|---|
| FT-RF-01 | Combate tático party 3 + FOW | **OK** — run: Espadachim → Companheiro → Trio; FOW |
| FT-RF-02 | Deckbuilding com decisões espaciais | Implementado (VS) |
| FT-RF-03 | Zona / exploração | Mapa de nós P2; zona grid legado mantida |
| FT-RF-04 | PVP 1v1 autoritativo | **OK** — lobby menu + arena + `apps/fallen-game-server` |
| FT-RF-05 | Dados em Resources/JSON (`data/`) | Catálogos JSON + libraries; combate lê `data/` |
| FT-RF-06 | Cosméticos via MutterGames | Spec integração; SDK pendente |

## 4. Documentação local (fonte de design)

Índice: [`Fallen Tactics/project-fallen-tactics/docs/README.md`](../../Fallen%20Tactics/project-fallen-tactics/docs/README.md)

| Doc | Uso |
|---|---|
| `GAME_OVERVIEW.md` | Visão e pilares |
| `STATE_PROMPT.md` | Estado real do código |
| `ROADMAP_3V3_WORLD.md` | Roadmap single-player |
| `MULTIPLAYER.md` / `NETWORKING_SERVERS.md` / `PVP_*` | Online |
| `ASSETS_*` / `P1_*` | Produção de arte |
| `PORTABILITY.md` | Plataformas |

## 5. Integração plataforma

- [`../game-integrations/fallen-tactics.md`](../game-integrations/fallen-tactics.md)
- Game server: [04-fallen-game-server.md](04-fallen-game-server.md)
- Assets: Creative Tools [`../tools/02-creative-tools-spec.md`](../tools/02-creative-tools-spec.md)

## 6. Como rodar

```text
Godot --path "Fallen Tactics/project-fallen-tactics"
```

## 7. Critérios de aceite da vertical slice

1. Menu inicia e leva a combate/zona jogável.  
2. Turno, cartas e FOW funcionam sem crash.  
3. `STATE_PROMPT` reflete main scene e autoloads reais.  
4. PVP documentado e testável com PRJ-04 local.

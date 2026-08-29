# Catálogo de projetos — MutterGames

**Versão:** 1.0.0  
**Data:** 2026-08-05  
**Status:** índice canônico de specs por projeto do monorepo

Cada entrada resume escopo, maturidade, stack e aponta para docs locais e specs detalhadas. Specs de ferramentas ficam em [`../tools/`](../tools/README.md). Specs de economia/blockchain ficam nos demais pacotes de `Ecosystem/`.

## Índice

| ID | Projeto | Pasta | Spec |
|---|---|---|---|
| PRJ-01 | Portal Web | `apps/web` | [01-web.md](01-web.md) |
| PRJ-02 | API Central | `apps/api` | [02-api.md](02-api.md) |
| PRJ-03 | Launcher Windows | `apps/launcher` | [03-launcher.md](03-launcher.md) |
| PRJ-04 | Fallen Game Server | `apps/fallen-game-server` | [04-fallen-game-server.md](04-fallen-game-server.md) |
| PRJ-05 | Fallen Tactics | `Fallen Tactics/project-fallen-tactics` | [05-fallen-tactics.md](05-fallen-tactics.md) |
| PRJ-06 | Beat Up | `Beat Up/beat-up-` | [06-beat-up.md](06-beat-up.md) |
| PRJ-07 | Taskbar Planets Forger | `TaskBarPlanetsForger` | [07-taskbar-planets.md](07-taskbar-planets.md) |
| PRJ-08 | Forge of Champions | `ForgeOfChampions` | [08-forge-of-champions.md](08-forge-of-champions.md) |
| PRJ-09 | MutterCoin Solana | `Blockchain/MutterCoinSolana` | [09-muttercoin-solana.md](09-muttercoin-solana.md) |
| PRJ-10 | Observabilidade local | `infra` | [10-infra.md](10-infra.md) |
| PRJ-11 | Web legada (referência) | `muttergames-web` | [11-muttergames-web-legacy.md](11-muttergames-web-legacy.md) |
| PRJ-12 | Conexões do Destino | `game-narrativo` | [12-conexoes-do-destino.md](12-conexoes-do-destino.md) |

## Fora do catálogo de produto

| Pasta | Tratamento |
|---|---|
| `Fallen Tactics/project-fallen-tactics-(4.3)/` | Snapshot legado — não evoluir |
| `Revisar/` | Pasta vazia; sem escopo |
| `outputs/` | Docs consolidados para stakeholders |
| `scripts/` | Toolchain — ver [tools](../tools/) |
| `Ecosystem/` | Specs transversais (este pacote incluso) |

## Maturidade (resumo)

```text
MVP / vertical slice:  Fallen Tactics, Taskbar Planets, Web, API, Launcher, Fallen GS
Protótipo jogável:     Beat Up (sem loop de entregas ainda)
Sandbox:               MutterCoin Solana
Conceito:              Forge of Champions, Conexões do Destino
Legado / referência:   muttergames-web, FT 4.3
```

## Ordem de leitura sugerida

1. Este índice  
2. Spec do projeto em que se vai trabalhar  
3. Integração em [`../game-integrations/`](../game-integrations/) se houver  
4. [`../../outputs/MutterGames-Project-Review.md`](../../outputs/MutterGames-Project-Review.md) para gaps

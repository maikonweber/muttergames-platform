# MutterGames — Revisão de Projetos

**Versão:** 1.1  
**Data:** 2026-08-05  
**Escopo:** inventário do monorepo, maturidade e mapa de documentação  
**Status:** revisão interna

## 1. Veredito

Plataforma (web/API/launcher/fallen-gs), três jogos Godot ativos, Forge em conceito, blockchain em sandbox. Documentação canônica por projeto em [`Ecosystem/projects/`](../Ecosystem/projects/README.md); ferramentas em [`Ecosystem/tools/`](../Ecosystem/tools/README.md).

## 2. Inventário → specs

| Projeto | Spec | Docs locais |
|---|---|---|
| `apps/web` | [PRJ-01](../Ecosystem/projects/01-web.md) | `apps/web/README.md` + `outputs/MutterGames-Web-*` |
| `apps/api` | [PRJ-02](../Ecosystem/projects/02-api.md) | `apps/api/README.md` + OpenAPI |
| `apps/launcher` | [PRJ-03](../Ecosystem/projects/03-launcher.md) | README + tools/03 |
| `apps/fallen-game-server` | [PRJ-04](../Ecosystem/projects/04-fallen-game-server.md) | README + docs FT PVP |
| Fallen Tactics 4.7 | [PRJ-05](../Ecosystem/projects/05-fallen-tactics.md) | `project-fallen-tactics/docs/` |
| Beat Up | [PRJ-06](../Ecosystem/projects/06-beat-up.md) | `beat-up-/docs/` + STATE_PROMPT |
| Taskbar Planets | [PRJ-07](../Ecosystem/projects/07-taskbar-planets.md) | `TaskBarPlanetsForger/docs/` |
| Forge of Champions | [PRJ-08](../Ecosystem/projects/08-forge-of-champions.md) | `ForgeOfChampions/docs/` |
| MutterCoin Solana | [PRJ-09](../Ecosystem/projects/09-muttercoin-solana.md) | `Blockchain/MutterCoinSolana/docs/` |
| `infra/` | [PRJ-10](../Ecosystem/projects/10-infra.md) | `infra/README.md` + SRE guide |
| `muttergames-web` | [PRJ-11](../Ecosystem/projects/11-muttergames-web-legacy.md) | legado |
| FT 4.3 / `Revisar/` | — | legado / vazia (README de política) |

## 3. Gaps restantes

| Pri | Item |
|---|---|
| P1 | Export completo do GDD Forge DOCX → Markdown |
| P1 | Portar `slice_spritesheet.py` para paths relativos |
| P2 | Unificar env `OPEN_ROUTER` vs `OPENROUTER_API_KEY` |
| P2 | ADR deprecando `muttergames-web` e pasta `Revisar/` |
| P2 | SDK Godot `MutterGamesClient` (roadmap plataforma) |

## 4. Navegação

1. [`Ecosystem/projects/README.md`](../Ecosystem/projects/README.md)  
2. [`Ecosystem/tools/README.md`](../Ecosystem/tools/README.md)  
3. [`outputs/README.md`](README.md)  
4. Docs do jogo/app em questão

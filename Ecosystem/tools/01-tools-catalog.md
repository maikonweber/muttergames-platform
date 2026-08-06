# Catálogo de ferramentas — MutterGames

**Versão:** 1.0  
**Data:** 2026-08-05

## 1. Escopo

Ferramentas usadas por engenharia, arte e QA **dentro do monorepo**. Exclui IDEs genéricas (Godot Editor, VS Code) e serviços cloud de terceiros, exceto quando houver wrapper local versionado.

## 2. Inventário

| ID | Ferramenta | Tipo | Audience | Entrada | Spec / guia | Status |
|---|---|---|---|---|---|---|
| TOOL-01 | Creative Tools | CLI assets | Arte, eng | `scripts/mutter-creative.sh` | [02-creative-tools-spec](02-creative-tools-spec.md) | Produção interna |
| TOOL-02 | MutterGames Launcher | Desktop Win | Jogadores, QA | `apps/launcher` | [03-launcher-spec](03-launcher-spec.md) | MVP |
| TOOL-03 | Seed Lab | Cena Godot | Arte, design | `TaskBarPlanetsForger/.../seed_lab.tscn` | [04-seed-lab-spec](04-seed-lab-spec.md) | MVP |
| TOOL-04 | Local Dev Toolchain | Scripts Bash | Eng | `scripts/init-all.sh`, `run-*.sh` | [05-local-dev-toolchain-spec](05-local-dev-toolchain-spec.md) | MVP |
| TOOL-05 | Fallen Game Server | Serviço local/dev | Eng multiplayer | `apps/fallen-game-server` | README do app | Protótipo |
| TOOL-06 | Meshy helper | Microserviço opcional | Arte Beat Up | `Beat Up/beat-up-/services/meshy` | README do serviço | Opcional |
| TOOL-07 | Observabilidade local | Infra Compose | Eng/SRE | `infra/` + Compose | `outputs/MutterGames-SRE-Infrastructure-Guide.md` | Local only |
| TOOL-08 | Solana sandbox scripts | CLI TS | Blockchain | `Blockchain/MutterCoinSolana/scripts` | docs do token | Sandbox |
| TOOL-09 | OpenRouter Image | CLI geração IA | Arte, eng | `scripts/openrouter-image.sh` | [06-openrouter-image-spec](06-openrouter-image-spec.md) | Opcional (chave) |
| TOOL-10 | Beat Up sheet slicer | Script Python | Arte Beat Up | `Beat Up/beat-up-/tools/slice_spritesheet.py` | Docstring do script; paths hardcoded | Legado / frágil |
| TOOL-11 | OpenRouter Game | CLI texto/voz | Design, arte | `scripts/openrouter-game.sh` | [08-openrouter-game-spec](08-openrouter-game-spec.md) | Opcional (chave) |
| TOOL-12 | Game Kit | CLI scaffold | Eng jogos | `scripts/mutter-gamekit.sh` | [09-gamekit-spec](09-gamekit-spec.md) | Produção interna |
| TOOL-13 | Mutter Forge | CLI + MCP + Blender | Arte, design, eng | `scripts/mutter-forge.sh` | [10-mutter-forge-spec](10-mutter-forge-spec.md) | Produção interna |

## 3. Matriz de dependências

| Ferramenta | Deps obrigatórias | Deps opcionais |
|---|---|---|
| TOOL-01 | Bash (WSL/Git Bash no Windows) | ImageMagick 7, FFmpeg/ffprobe |
| TOOL-02 | .NET SDK 8 (build), Windows (runtime) | API MutterGames com URLs/SHA |
| TOOL-03 | Godot 4.7+ | — |
| TOOL-04 | Node 22, pnpm 11, Docker | Solana CLI |
| TOOL-05 | pnpm / Node | Cliente Fallen Tactics |
| TOOL-06 | Python 3.10+ | API Meshy / chave |
| TOOL-07 | Docker Compose | — |
| TOOL-08 | Node/TS, Solana tooling | Rede local |
| TOOL-09 | Bash, curl, jq, base64, `OPEN_ROUTER` | Modelos pagos OpenRouter |
| TOOL-10 | Python 3, Pillow, NumPy | Paths absolutos locais |
| TOOL-11 | Bash, curl, jq; `OPEN_ROUTER` | ImageMagick (`remove-bg`), modelos TTS |
| TOOL-13 | Bash, Node.js | Blender, ImageMagick, FFmpeg, OpenRouter |
| TOOL-12 | Bash, awk | — |

## 4. Owners sugeridos

| ID | Owner funcional | Owner técnico |
|---|---|---|
| TOOL-01 | Produção de arte | Eng de ferramentas |
| TOOL-02 | Produto plataforma | Eng desktop |
| TOOL-03 | Design Taskbar Planets | Eng Godot do jogo |
| TOOL-04 | Eng plataforma | Eng plataforma |
| TOOL-05 | Eng Fallen Tactics | Eng networking |
| TOOL-06 | Arte Beat Up | Eng Beat Up |
| TOOL-07 | SRE | Eng plataforma |
| TOOL-08 | Blockchain | Eng Solana |
| TOOL-09 | Produção de arte | Eng de ferramentas |
| TOOL-10 | Arte Beat Up | Eng Beat Up |
| TOOL-11 | Narrativa e áudio | Eng de ferramentas |
| TOOL-13 | Produção transversal | Eng de ferramentas |
| TOOL-12 | Design e engenharia | Eng de ferramentas |

## 5. Critérios para adicionar uma ferramenta ao catálogo

1. Tem ponto de entrada versionado no monorepo.  
2. Tem audience e status claros (MVP / opcional / sandbox / deprecated).  
3. Tem spec ou README mínimo com dependências, uso e limites.  
4. Não duplica outra ferramenta sem ADR.

## 6. Roadmap de tooling (não implementado)

| Item | Fase | Nota |
|---|---|---|
| SDK Godot `MutterGamesClient` | P1 plataforma | Previsto nas integrações de jogo |
| Creator tools / launchpad | Fase 8 roadmap eng | `outputs/MutterGames-Engineering-Roadmap.md` |
| Wrapper PowerShell nativo do Creative Tools | P2 | Hoje exige WSL/Git Bash |
| CI `mutter-creative validate` em packs | P1 | Gate de qualidade de assets |
| Integração Seed Lab → `mutter-creative manifest` | P2 | Pack compartilhado entre jogos |

## 7. Fora de catálogo (proposital)

- `ForgeOfChampions/` — sem ferramenta ou pipeline.
- `Revisar/` — pasta vazia.
- `muttergames-web/` — cópia de referência, não toolchain.

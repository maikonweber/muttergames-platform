# Scripts — MutterGames

Atalhos de bootstrap, creative tooling e geração de imagens. No Windows use **WSL** ou **Git Bash**.

## Índice

| Script | Função | Spec / guia |
|---|---|---|
| `init-all.sh` | `.env`, `pnpm install`, sobe Postgres + observabilidade | [TOOL-04](../Ecosystem/tools/05-local-dev-toolchain-spec.md) |
| `run-local-stack.sh` | Orquestra stack local | idem |
| `run-api.sh` | API NestJS | idem |
| `run-web.sh` | Web Next.js (`apps/web`) | idem |
| `run-solana-local.sh` | Sandbox Solana (opcional) | idem |
| `mutter-creative.sh` | Crop, cutout, VFX, SFX, spriteframes, validate… | [TOOL-01](../Ecosystem/tools/02-creative-tools-spec.md) · [creative-tools/README.md](creative-tools/README.md) |
| `openrouter-image.sh` | Geração de imagem via OpenRouter | [TOOL-09](../Ecosystem/tools/06-openrouter-image-spec.md) · [openrouter-image.md](creative-tools/openrouter-image.md) |
| `openrouter-game.sh` | Texto, briefs e voz TTS via OpenRouter | [TOOL-11](../Ecosystem/tools/08-openrouter-game-spec.md) · [openrouter-game.md](creative-tools/openrouter-game.md) |
| `mutter-gamekit.sh` | Dados, localização, componentes e release | [TOOL-12](../Ecosystem/tools/09-gamekit-spec.md) · [gamekit.md](creative-tools/gamekit.md) |
| `mutter-forge.sh` | CLI unificada 2D, 3D, Blender, IA e MCP | [TOOL-13](../Ecosystem/tools/10-mutter-forge-spec.md) · [mutter-forge.md](creative-tools/mutter-forge.md) |
| `meshy-asset.sh` | Geração 3D via Meshy (texto/imagem) | [TOOL-06](../Ecosystem/tools/11-meshy-asset-spec.md) · [meshy-asset.md](creative-tools/meshy-asset.md) |
| `taskbar-planets-meshy-pack.sh` | Pack de arquétipos Meshy do Taskbar Planets | `assets/meshy/README.md` no protótipo |
| `taskbar-planets-ui-assets.py` / `.sh` | Pack 2D UI + planetas + VFX (catalog + install) | [taskbar-planets-ui-assets.md](creative-tools/taskbar-planets-ui-assets.md) |

Catálogo completo (launcher, seed lab, Meshy, etc.): [`Ecosystem/tools/`](../Ecosystem/tools/README.md).

## Bootstrap rápido

```bash
scripts/init-all.sh
# em outros terminais:
scripts/run-api.sh
scripts/run-web.sh
```

Ou stack Docker completa (ver README da raiz):

```powershell
Copy-Item .env.example .env
docker compose up --build
```

## Creative pipeline

```bash
scripts/mutter-creative.sh doctor
scripts/mutter-creative.sh prompt asset tmp/brief.md "sprite de planeta"
# opcional: OpenRouter (requer OPEN_ROUTER na sessão)
scripts/openrouter-image.sh generate --model <modelo> --prompt "..." --out assets/planets/x
# opcional: Meshy 3D (requer MESHY_API_KEY na sessão)
scripts/meshy-asset.sh text-to-3d --prompt "..." --out tmp/assets/item --meta
scripts/mutter-creative.sh cutout in.png out.png '#ff00ff'
scripts/mutter-creative.sh validate assets
```

## Ferramentas fora desta pasta

| Path | Nota |
|---|---|
| `apps/launcher` | Instalador Windows |
| `TaskBarPlanetsForger/.../seed_lab.tscn` | Lab de seeds in-engine |
| `Beat Up/beat-up-/tools/slice_spritesheet.py` | Slice local Beat Up (paths hardcoded — legado) |
| `scripts/meshy-asset.sh` | Adaptador Meshy canônico (substitui helper Beat Up planejado) |

## Glossário “forge”

Ver [`Ecosystem/tools/07-forge-glossary.md`](../Ecosystem/tools/07-forge-glossary.md) — o kind `forge` do creative kit **não** é o jogo Forge of Champions.

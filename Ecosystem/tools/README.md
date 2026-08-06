# MutterGames — Ferramentas

**Versão:** 1.0.0-draft  
**Data:** 2026-08-05  
**Status:** especificação e catálogo operacional

Pacote de documentação das **ferramentas internas** do monorepo: criação de assets, publicação via launcher, laboratório procedural e bootstrap de desenvolvimento. Não substitui as specs de produto/blockchain em `Ecosystem/`; complementa o fluxo de produção e operação local.

## Decisões principais

- Creative Tools são CLI portáveis (Bash + ImageMagick/FFmpeg), não um editor Godot.
- OpenRouter Image/Game são adaptadores opcionais; chaves nunca vão para o repositório.
- Game Kit gera scaffolds locais sem rede.
- O Launcher é o único caminho suportado de instalação Windows para releases oficiais.
- Seed Lab pertence ao Taskbar Planets Forger; a saída pode alimentar packs compartilhados via Creative Tools.
- Scripts `run-*.sh` / `init-all.sh` são o caminho canônico de bootstrap local; Docker Compose permanece a stack completa.

## Navegação

| Documento | Conteúdo |
|---|---|
| [01-tools-catalog.md](01-tools-catalog.md) | Inventário TOOL-01…12 |
| [02-creative-tools-spec.md](02-creative-tools-spec.md) | `mutter-creative.sh` |
| [03-launcher-spec.md](03-launcher-spec.md) | Launcher Windows |
| [04-seed-lab-spec.md](04-seed-lab-spec.md) | Seed Lab |
| [05-local-dev-toolchain-spec.md](05-local-dev-toolchain-spec.md) | Bootstrap local |
| [06-openrouter-image-spec.md](06-openrouter-image-spec.md) | OpenRouter Image |
| [07-forge-glossary.md](07-forge-glossary.md) | Glossário “forge” |
| [08-openrouter-game-spec.md](08-openrouter-game-spec.md) | OpenRouter Game (texto/voz) |
| [09-gamekit-spec.md](09-gamekit-spec.md) | Game Kit |
| [10-mutter-forge-spec.md](10-mutter-forge-spec.md) | CLI unificada com Blender e MCP |

## Relacionados

- Projetos: [`../projects/README.md`](../projects/README.md)
- Scripts: [`scripts/README.md`](../../scripts/README.md)
- Guias: [`creative-tools/`](../../scripts/creative-tools/)
- Revisão: [`outputs/MutterGames-Project-Review.md`](../../outputs/MutterGames-Project-Review.md)
- Integrações: [`../game-integrations/`](../game-integrations/)

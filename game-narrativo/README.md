# Conexões do Destino

Visual novel episódica de romance, escolhas e investigação. A protagonista enxerga fios entre pessoas destinadas a mudar umas às outras e descobre que essas conexões estão ligadas ao desaparecimento de Íris Valença.

**Fonte canônica:** `Conexoes_do_Destino_GDD (1).docx` v1.0 — agosto de 2026.  
**Status:** conceito e pré-produção.  
**Engine alvo:** Godot 4.x · Android / iOS / PC · 13+

> Algumas conexões aproximam. Outras destroem.

## O que está nesta pasta

| Pasta | Uso |
| --- | --- |
| [docs/](docs/README.md) | Roadmap, sprites, locais, cenas, sistemas, testes e backlog |
| [personagens/](personagens/README.md) | Personalidade, voz, limites e flags de cada personagem |
| [narrativa/](narrativa/README.md) | Lore, temporada 1, textos extraídos e roteiro jogável do EP01 |
| [data/](data/README.md) | Schemas e JSON prontos para o `NarrativeManager` |

## Começar a implementar

1. Ler [docs/08-implementar-historia.md](docs/08-implementar-historia.md) — contrato de nós, IDs e flags.
2. Carregar [data/episodes/ep01/nodes.json](data/episodes/ep01/nodes.json) no Godot.
3. Consultar a ficha do personagem em `personagens/` antes de escrever falas novas.
4. Seguir [docs/01-roadmap-implementacao.md](docs/01-roadmap-implementacao.md) e [docs/09-plano-de-testes.md](docs/09-plano-de-testes.md).

## Recorte do MVP

Episódios 1–3 (60–90 min). Theo, Gael, Noah e Luna com afinidade/confiança. Dante só narrativo. 12 cenários, 20 retratos-base, 6 expressões por principal, 4 CGs. Português brasileiro.

# PRJ-08 — Forge of Champions

**Pasta:** `ForgeOfChampions/`  
**Status:** Conceito / pré-código  
**Owner:** TBD (design)

## 1. Objetivo (working)

Jogo de cartas competitivo (conceito). Existe GDD Word e demos visuais de cartas; **não há** projeto Godot/engine no monorepo.

## 2. Artefatos atuais

| Path | Conteúdo |
|---|---|
| `GDD_Forge_of_Champions.docx` | Game design document |
| `card_design_demo/` | PDF/PNG de cartas demo |
| `README.md` | Status e próximos passos |

## 3. Requisitos (placeholder até GDD MD)

| ID | Requisito | Status |
|---|---|---|
| FC-RF-01 | Publicar GDD em Markdown versionado | Pendente |
| FC-RF-02 | Definir engine (preferência Godot 4.7) | Pendente |
| FC-RF-03 | Vertical slice jogável | Não iniciado |
| FC-RF-04 | Integração Ecosystem / launcher | Após build |

## 4. Ambiguidade de nome

Não confundir com:

- preset `forge` do Creative Tools  
- mecânica de forja do Taskbar Planets  

Ver [`../tools/07-forge-glossary.md`](../tools/07-forge-glossary.md).

## 5. Integração

- Stub: [`../game-integrations/forge-of-champions.md`](../game-integrations/forge-of-champions.md)
- Docs locais: [`docs/`](../../ForgeOfChampions/docs/README.md)

## 6. Gates para virar projeto ativo

1. GDD MD aprovado.  
2. Repo Godot (ou outra engine) com cena main.  
3. Entrada em `Ecosystem/projects` promovida de “conceito” para “protótipo”.  
4. Catalog entry no launcher quando houver export Windows.

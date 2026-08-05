# Documentação — Project Fallen Tactics

Índice dos docs de design, produto e arquitetura.

| Documento | Conteúdo |
|-----------|----------|
| [`GAME_OVERVIEW.md`](GAME_OVERVIEW.md) | O jogo: high concept, pilares, loops, classes, visão |
| [`STATE_PROMPT.md`](STATE_PROMPT.md) | Estado atual do protótipo (contexto para agentes) |
| [`ROADMAP_3V3_WORLD.md`](ROADMAP_3V3_WORLD.md) | Roadmap 3v3, zona maior, XP, atividades no mapa |
| [`ASSETS_AND_ANIMATIONS.md`](ASSETS_AND_ANIMATIONS.md) | Assets, sprites, animações, VFX, UI, prioridade de arte |
| [`ASSET_INSTRUCTIONS.md`](ASSET_INSTRUCTIONS.md) | **Instruções detalhadas por asset** (brief de produção) |
| [`P1_PRODUCTION_CHECKLIST.md`](P1_PRODUCTION_CHECKLIST.md) | Checklist P1 (VS apresentável) |
| [`P1_production_sheet.csv`](P1_production_sheet.csv) | Planilha rastreável de assets P0/P1 |
| [`MULTIPLAYER.md`](MULTIPLAYER.md) | Co-op, versus, autoridade, fases de multiplayer |
| [`PORTABILITY.md`](PORTABILITY.md) | PC, Deck, Web, mobile, input, saves, builds |
| [`NETWORKING_SERVERS.md`](NETWORKING_SERVERS.md) | WebSocket, UDP, protocolo, serviços, segurança |

## Ordem de leitura sugerida

1. **GAME_OVERVIEW** — o que o jogo é  
2. **STATE_PROMPT** — o que já existe no código  
3. **ROADMAP_3V3_WORLD** — para onde o single-player vai  
4. **ASSETS_AND_ANIMATIONS** — o que produzir de arte/anim  
5. **MULTIPLAYER** + **NETWORKING_SERVERS** — camada online  
6. **PORTABILITY** — como chega em cada plataforma  

## Regra

Documentos de visão podem adiantar o código.  
**STATE_PROMPT** deve refletir o que está **realmente** implementado.

# AGENT PROMPT — BEAT UP (ESTADO ATUAL)

> Contexto vivo do protótipo. Atualize quando o estado do código mudar.
> Use como contexto ao retomar o projeto em qualquer sessão ou agente.

Continue a partir do estado real do repositório — não implemente o GDD inteiro de uma vez.

---

## Identidade

**Nome:** Beat Up  
**Gênero:** Direção isométrica 2,5D + (alvo) entregas  
**Engine:** Godot 4.7  
**Path monorepo:** `Beat Up/beat-up-/`  
**Main scene:** `res://scenes/main.tscn`  
**Autoloads:** `GameManager`, `DebugManager`, `RadioManager`

## Pilares (filtro)

1. Direção responsiva e legível  
2. Escolha de rota com consequências  
3. Missões claras e curtas (visão)  
4. Progresso tangível em MutterCoins (visão)  
5. Cidade viva que influencia o play  

## Implementado AGORA

- Controle de carro (`scripts/vehicle/`)
- Cidade procedural (`scripts/world/`)
- Trânsito NPC + polícia (`scripts/ai/`)
- Rádio (`scripts/audio/`)
- HUD + score / game over (`scripts/ui/`, `game_manager.gd`)
- Debug overlays e regeneração de cidade
- Testes headless (ver `tests/`)

## NÃO implementado (docs de produto)

- Loop de entregas (coleta/destino/prazo)
- MutterCoins / EconomyManager
- Sistema wanted formal / menu meta de progressão
- Garagem / loja de veículos
- Integração MutterGames SDK

Próximo recorte: `docs/direcao-tecnica.md` (uma entrega local).

## Como rodar

```text
Godot --path "Beat Up/beat-up-"
Godot --path "Beat Up/beat-up-" --editor
```

## Controles (resumo)

| Ação | Tecla |
|---|---|
| Acelerar / frear / virar | W/S/A/D ou setas |
| Rádio | M, `[` `]`, 1–5 |
| Debug | F1–F6, R regenera cidade, P pausa |

## Docs

- Índice: `docs/README.md`
- Spec Ecosystem: `Ecosystem/projects/06-beat-up.md`
- Integração: `Ecosystem/game-integrations/beat-up.md`

## Regra

Documentos de visão podem adiantar o código.  
**Este STATE_PROMPT** deve refletir só o que está **realmente** jogável.

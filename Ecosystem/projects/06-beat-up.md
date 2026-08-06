# PRJ-06 — Beat Up

**Pasta:** `Beat Up/beat-up-/`  
**Engine:** Godot 4.7  
**Status:** Protótipo jogável de direção; entregas = visão de produto  
**Owner:** Design / Eng Beat Up

## 1. High concept

Direção isométrica 2,5D em cidade procedural. Fantasia-alvo: entregador que escolhe rotas, gerencia risco e ganha MutterCoins — o loop de entregas ainda **não** está no build jogável.

## 2. Estado técnico

| Item | Valor |
|---|---|
| Main scene | `res://scenes/main.tscn` |
| Autoloads | `GameManager`, `DebugManager`, `RadioManager` |
| Implementado | Carro, cidade procedural, trânsito, polícia, rádio, HUD, score/sessão, testes headless |
| Não implementado | Entregas, MutterCoins/EconomyManager, wanted formal, menu meta, loja/garagem |
| Tools | `tools/slice_spritesheet.py` (legado), `services/meshy/` |

## 3. Requisitos

| ID | Pri | Requisito | Aceite |
|---|---|---|---|
| BU-RF-01 | P0 | Direção responsiva na cidade | Controles W/A/S/D; cena main estável |
| BU-RF-02 | P0 | Cidade procedural regenerável | Seed/debug R sem crash |
| BU-RF-03 | P0 | Trânsito + polícia | IA presente no protótipo |
| BU-RF-04 | P1 | Vertical slice de entrega | Coleta → destino → pagamento local (ver `direcao-tecnica.md`) |
| BU-RF-05 | P1 | Economia MutterCoins local | Saldo só muda após entrega concluída |
| BU-RF-06 | P2 | Integração MutterGames | Adapter + antifraude de score |

## 4. Docs locais

Índice: [`Beat Up/beat-up-/docs/README.md`](../../Beat%20Up/beat-up-/docs/README.md)

| Doc | Conteúdo |
|---|---|
| `GDD.md` | Design completo alvo |
| `visao-do-jogo.md` | Pilares |
| `gameplay-entregas.md` | Regras de missão |
| `economia-muttercoins.md` | Economia |
| `direcao-tecnica.md` | Recorte implementável |
| `STATE_PROMPT.md` | Estado real do código (agentes) |

## 5. Integração

- [`../game-integrations/beat-up.md`](../game-integrations/beat-up.md)
- Soft currency off-chain; skins/decals como cosméticos futuros.

## 6. Como rodar

```text
Godot --path "Beat Up/beat-up-"
# F5 → scenes/main.tscn
```

## 7. Próximo milestone

Vertical slice de **uma** entrega (coleta, destino, prazo, pagamento local) sem quebrar testes headless existentes — critérios em `direcao-tecnica.md`.

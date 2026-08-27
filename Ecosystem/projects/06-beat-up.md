# PRJ-06 — Beat Up

**Pasta:** `Beat Up/beat-up-/`  
**Engine:** Godot 4.7  
**Status:** Protótipo jogável — direção + entregas + wanted/game over  
**Owner:** Design / Eng Beat Up

## 1. High concept

Direção isométrica 2,5D em cidade procedural. Fantasia-alvo: entregador que escolhe rotas, gerencia risco (tráfego/polícia) e ganha MutterCoins locais.

## 2. Estado técnico

| Item | Valor |
|---|---|
| Main scene | `res://scenes/main.tscn` |
| Autoloads | `GameManager`, `DebugManager`, `RadioManager`, `DeliveryManager` |
| Implementado | Carro, cidade procedural, trânsito, polícia, rádio, HUD, menu, score, entregas, MutterCoins locais, wanted/heat, game over, testes headless |
| Não implementado | Catálogo rico de contratos, loja/garagem, persistência, SDK MutterGames |
| Tools | `services/meshy` pack-2d; monorepo `scripts/meshy-asset.sh` (TOOL-06); `scripts/mutter-forge.sh` |

## 3. Requisitos

| ID | Pri | Requisito | Aceite |
|---|---|---|---|
| BU-RF-01 | P0 | Direção responsiva na cidade | Controles W/A/S/D; cena main estável |
| BU-RF-02 | P0 | Cidade procedural regenerável | Seed/debug R sem crash |
| BU-RF-03 | P0 | Trânsito + polícia | IA presente; captura → game over |
| BU-RF-04 | P1 | Vertical slice de entrega | Coleta → destino → pagamento local |
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
# Enter/Espaço → começar; WASD dirigir; N entrega; fuja da polícia
```

## 7. Próximo milestone

Contratos com variação (prazo/pagamento) + sink simples de MutterCoins (upgrade de carro ou reparo) sem quebrar testes headless.

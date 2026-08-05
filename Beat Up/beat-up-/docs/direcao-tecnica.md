# Direção técnica

## Base atual

O projeto utiliza Godot 4.7 e já possui os blocos principais para o protótipo de direção:

- `scenes/main.tscn`: cena principal e criação do carro/HUD.
- `scripts/vehicle/`: controle e matemática do carro.
- `scripts/world/`: geração procedural da cidade.
- `scripts/ai/`: trânsito e polícia.
- `scripts/ui/game_hud.gd`: HUD atual.
- `scripts/game_manager.gd`: estado de sessão e score.

## Próximo recorte implementável

O primeiro vertical slice de entregas deve incluir apenas:

1. Um ponto de coleta e um destino visíveis na cidade.
2. Uma única carga padrão com prazo simples.
3. Um painel de missão no HUD.
4. Pagamento local em MutterCoins ao concluir.
5. Reinício seguro da missão em caso de falha.

Isso valida o loop central antes de adicionar catálogo de veículos, vários contratos, persistência ou integração externa.

## Componentes sugeridos

| Componente | Responsabilidade |
|---|---|
| `DeliveryManager` (autoload) | ciclo da missão, contrato ativo e sinais de progresso |
| `DeliveryContract` (Resource) | parâmetros de cada contrato: coleta, destino, prazo e pagamento |
| `Wallet` ou `EconomyManager` (autoload) | saldo local de MutterCoins e eventos de atualização |
| `MissionHUD` | destino, tempo, carga e recompensa |
| pontos de coleta/entrega | áreas de interação no mapa |

## Ordem recomendada

```text
Contrato padrão → UI de missão → pagamento local → avaliação por tempo/dano → persistência → novos contratos → loja/garagem
```

## Critérios de aceite do vertical slice

- O jogador consegue iniciar, completar e repetir uma entrega sem reiniciar o jogo.
- O destino e o prazo permanecem claros durante a direção.
- A recompensa em MutterCoins muda somente após a entrega concluída.
- A cidade pode ser regenerada sem deixar uma missão ativa em estado inconsistente.
- O fluxo funciona com a cena principal atual e não quebra os testes existentes.

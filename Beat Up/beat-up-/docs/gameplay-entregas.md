# Gameplay de entregas

## Estrutura de uma missão

1. O jogador escolhe um contrato no ponto de serviço, rádio ou mapa.
2. Um marcador leva ao ponto de coleta; a carga é vinculada ao carro ao chegar.
3. O HUD mostra destino, tempo restante, estado da carga e recompensa-base.
4. Ao estacionar na área de entrega, o jogo calcula a avaliação e paga as MutterCoins.

## Tipos de contrato

| Contrato | Regra principal | Recompensa |
|---|---|---|
| Padrão | Chegar dentro do prazo | Base |
| Expresso | Prazo curto | Base alta |
| Frágil | Evitar colisões fortes | Bônus por integridade |
| Valioso | Evitar polícia e danos | Bônus de risco |
| Entrega em lote | Vários destinos em uma rota | Bônus por eficiência |

## Avaliação

A recompensa final deve ser simples de entender:

```text
pagamento final = valor-base + bônus de tempo + bônus de integridade + bônus de risco − penalidades
```

Penalidades podem ser aplicadas por atraso, colisões, perda da carga ou abandono do contrato. A missão pode continuar após um dano leve para evitar frustração; falha total deve ficar reservada para carga destruída, prazo muito excedido ou veículo inutilizado.

## Risco e polícia

Dirigir de maneira imprudente — bater, atravessar áreas restritas ou chamar atenção perto de viaturas — pode elevar o nível de procura. Com carga valiosa, a polícia torna rotas seguras mais atraentes e abre espaço para fugas recompensadoras.

A polícia é um tempero de risco, não uma punição constante: contratos comuns devem ser possíveis de concluir sem perseguição.

## Progressão de trabalhos

Os primeiros contratos devem ensinar direção, coleta e entrega. Depois, o jogador libera prazos menores, cargas especiais, bairros distantes e contratos com múltiplas paradas. A dificuldade deve crescer pelo contexto da missão, não apenas pelo aumento artificial de tráfego.

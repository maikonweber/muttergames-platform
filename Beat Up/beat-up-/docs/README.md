# Beat Up - Documentacao

Beat Up e um jogo de direcao isometrico em 2,5D ambientado em uma cidade viva e procedural. O jogador trabalha como entregador: aceita servicos, atravessa a cidade com rapidez e cuidado e recebe **MutterCoins** por cada entrega concluida.

## Indice

- [GDD - Game Design Document](./GDD.md): visao completa, cenario, missoes e integracao tecnica.
- [Visao do jogo](./visao-do-jogo.md): fantasia, publico, pilares e loop principal.
- [Gameplay de entregas](./gameplay-entregas.md): regras de missao, avaliacao e falhas.
- [Economia e MutterCoins](./economia-muttercoins.md): fontes, gastos e progressao.
- [Direcao tecnica](./direcao-tecnica.md): como o conceito se encaixa no prototipo Godot atual.

## Estado do projeto

O repositorio ja contem um prototipo jogavel de direcao isometrica com geracao procedural de cidade, transito, policia, radio e HUD. O sistema de entregas e a economia em MutterCoins descritos aqui sao a direcao de produto para as proximas etapas; eles ainda nao fazem parte da versao jogavel.

## Principio de design

Cada entrega deve criar uma decisao interessante: qual rota seguir, quanto risco aceitar e se vale a pena buscar uma recompensa maior. Dirigir bem, conhecer a cidade e cuidar do veiculo devem ser mais importantes do que apenas acelerar ate o destino.

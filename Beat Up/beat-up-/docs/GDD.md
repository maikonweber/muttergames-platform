# GDD - Beat Up

Versao: 0.1
Genero: direcao isometrica 2,5D com foco em entregas
Plataforma alvo: PC
Motor: Godot 4.7

## Visao geral

Beat Up e um jogo de carros isometrico em 2,5D ambientado em uma cidade viva e procedural. O jogador assume o papel de um entregador que aceita missoes, coleta cargas, atravessa a cidade e conclui entregas para ganhar MutterCoins.

A experiencia foi desenhada para transformar cada viagem em uma pequena historia de risco e decisao. O jogador precisa ler o mapa, escolher rotas, evitar danos ao veiculo, lidar com trafego e responder a eventos do mundo como chuva, bloqueios, policia e congestionamentos.

## Fantasia do jogador

Ser o melhor entregador da cidade: rapido quando necessario, cuidadoso quando a carga pede estabilidade e esperto o suficiente para encontrar caminhos alternativos antes dos concorrentes.

## Pilares de design

1. Direcao responsiva e legivel.
2. Escolha de rota com consequencias reais.
3. Missoes claras, curtas e variaveis.
4. Progresso tangivel em MutterCoins.
5. Cidade que parece viva e que influencia o jeito de jogar.

## Loop principal

1. Aceitar uma missao.
2. Ir ate o ponto de coleta.
3. Carregar a encomenda.
4. Planejar o trajeto.
5. Fazer a entrega dentro do prazo e com boa integridade.
6. Receber pagamento e avaliacao.
7. Gastar MutterCoins em melhorias ou desbloqueios.

Cada ciclo deve durar poucos minutos, mas com variacoes suficientes para gerar tensao e re-jogabilidade.

## Estrutura de missoes

O sistema de missoes e a espinha dorsal do jogo. Toda entrega deve ter:

- origem de coleta;
- destino final;
- prazo;
- valor base;
- bonus por tempo, integridade ou risco;
- penalidade por atraso, dano ou cancelamento;
- tipo de carga;
- nivel de perigo.

### Estados da missao

- Disponivel
- Aceita
- Indo para coleta
- Em entrega
- Concluida
- Falhou
- Cancelada

### Tipos de missao

| Tipo | Caracteristica | Risco |
| --- | --- | --- |
| Padrao | Entrega comum, previsivel | Baixo |
| Expressa | Prazo apertado | Medio |
| Fragil | Penaliza impactos e manobras bruscas | Alto |
| Discreta | Exige evitar policia e rotas expostas | Medio |
| Multipla | Mais de um ponto de coleta ou entrega | Alto |

### Regras de avaliacao

O pagamento final deve considerar:

- tempo restante;
- danos no veiculo e na carga;
- numero de colisiones;
- eventuais infrações ou perseguicao policial;
- sucesso em rotas opcionais ou atalhos.

O objetivo e fazer o jogador sentir que boa direcao importa mais do que apenas apertar o acelerador.

## Integracao com o prototipo

O conceito de missoes precisa se conectar ao que o prototipo atual ja possui, sem quebrar o fluxo existente.

### Componentes principais

- `Main`: inicia o ciclo geral e conecta geracao, missao e HUD.
- `CityGenerator`: fornece posicoes validas para coleta, destino e eventos de rua.
- `CarController`: controla posicao, velocidade, colisoes e dano.
- `GameManager`: cuida de pausa, estado global e game over.
- `GameHUD`: mostra velocidade, rota, objetivo e status da entrega.
- `DeliveryManager`: gerencia a missao ativa, o estado e o encerramento.
- `DeliveryPoint`: representa areas de coleta e entrega.
- `EconomyManager`: controla saldo de MutterCoins e recompensas.

### Fluxo de integracao

1. A cidade e gerada.
2. O sistema escolhe um ponto valido de coleta e um destino.
3. O jogador aceita a missao.
4. A HUD mostra objetivo, tempo e recompensa.
5. Ao chegar no ponto de coleta, a carga e vinculada ao veiculo.
6. A partir dai, o jogador recebe sinais visuais e sonoros para seguir ao destino.
7. Ao entregar, o `DeliveryManager` calcula o resultado e o `EconomyManager` credita os MutterCoins.

### Sinais sugeridos

- `mission_accepted(contract)`
- `mission_phase_changed(phase)`
- `mission_time_changed(seconds_left)`
- `mission_completed(result)`
- `mission_failed(reason)`
- `balance_changed(muttercoins)`

Esses sinais mantem a missao desacoplada da direcao do carro, o que facilita expandir o jogo depois.

## Cenário e cidade

A cidade precisa parecer um tabuleiro vivo, mas sem perder a leitura isometrica. O jogador deve entender rapidamente:

- por onde pode dirigir;
- o que e obstaculo;
- onde esta a coleta;
- onde esta o destino;
- quais rotas sao mais rapidas ou mais arriscadas.

### Linguagem visual

- perspectiva isometrica com leitura limpa das vias;
- edificios com altura e silhueta fortes;
- elementos de rua em camadas para dar profundidade;
- sombras e neblina leve para reforcar a 2,5D;
- marcadores de missao sempre visiveis sem poluir a cena.

### Distritos sugeridos

| Distrito | Identidade | Uso em gameplay |
| --- | --- | --- |
| Centro | Predios altos, cruzamentos e neon | Trafego pesado e entregas rapidas |
| Residencial | Ruas menores, curvas e casas | Rotas mais calmas e arriscadas para cargas fragiles |
| Industrial | Galpoes, patios e vias largas | Cargas pesadas e trajetos longos |
| Comercial | Lojas, mercados e fluxo constante | Entregas frequentes e movimentacao intensa |
| Periferia | Acesso irregular e caminhos alternativos | Atalhos e rotas de escape |

### Eventos de cenário

- congestionamentos;
- obras e bloqueios;
- chuva e piso escorregadio;
- patrulhas policiais;
- rotas alternativas liberadas por eventos;
- areas temporariamente perigosas.

Esses eventos devem mudar a leitura da rota sem exigir que o jogador decore a cidade inteira.

## Economia e MutterCoins

MutterCoins sao a moeda de progressao do jogo. Eles devem ser a recompensa direta pelo desempenho nas missoes.

### Fontes

- pagamento de entregas;
- bonus de tempo;
- bonus de integridade;
- bonus por risco;
- objetivos especiais.

### Gastos

- melhora de motor;
- melhora de pneus e aderencia;
- protecao de carga;
- aumento de capacidade;
- desbloqueio de novos veiculos;
- personalizacao visual.

O ideal e que o jogador sinta progresso logo nas primeiras entregas, mas ainda tenha metas de medio prazo.

## Ritmo de jogo

O ritmo deve alternar entre:

- calmaria ao planejar a rota;
- tensao ao entrar em zonas de trafego;
- alivio ao encontrar um atalho;
- pressao nos minutos finais da entrega;
- recompensa clara na conclusao.

## Escopo do vertical slice

Para uma primeira versao jogavel, o recorte minimo recomendado e:

- uma cidade procedural com um distrito principal;
- um sistema de missao padrao com coleta e entrega;
- HUD de objetivo e tempo;
- calculo simples de recompensa;
- economia local com MutterCoins;
- um sistema basico de penalidade por dano e atraso.

## Fora do escopo inicial

- multiplayer;
- mundo aberto sem limites;
- dezenas de veiculos e cargas logo de inicio;
- blockchain ou integracao externa obrigatoria;
- IA complexa de pedestres em larga escala.

## Direcao de produto

Beat Up deve crescer a partir de uma experiencia pequena, clara e rejogavel. O primeiro objetivo nao e ter tudo, e sim provar que a base de dirigir, entregar e ganhar MutterCoins e divertida o suficiente para sustentar evolucoes futuras.

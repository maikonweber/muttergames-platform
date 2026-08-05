# SRS — Software Requirements Specification

## Escopo

Aplicação desktop para Windows que simula um sistema solar idle, persiste o progresso local e oferece uma janela compacta e expansível. A fonte normativa de requisitos detalhados é [functional-requirements.md](functional-requirements.md) e [non-functional-requirements.md](non-functional-requirements.md).

## Atores

- **Jogador:** controla criação, evolução, preferências e prestígio.
- **Sistema operacional:** fornece tela, bandeja, ciclo de vida e relógio.
- **MutterGames (futuro):** identidade e catálogo opcionais, sem acesso ao estado do jogo por padrão.

## Critérios globais de aceite

1. Um jogador inicia, cria um planeta, fecha e recupera o mesmo estado.
2. O modo compacto não cobre deliberadamente a área de trabalho escolhida e pode ser pausado/ocultado.
3. O progresso offline é limitado, explicado e resistente a alteração trivial de relógio.
4. Falha de escrita não destrói o último save válido.

## Interfaces externas

MVP: sistema de arquivos local, bandeja Windows e opcionalmente APIs de janela nativas. Integrações MutterGames usam adaptadores futuros, sem dependência do game loop.

# Lira Studio

Base de planejamento para o jogo casual mobile de maquiagem descrito no GDD. O nome do produto ainda e provisório; os documentos usam **Lira Studio** como nome de trabalho.

## Objetivo do MVP

Entregar para Android um jogo 2D em retrato no qual a pessoa joga uma maquiagem completa em uma modelo, conclui desafios, recebe moedas e desbloqueia cosméticos. A experiência precisa funcionar offline e manter a criação leve, inclusiva e sem pressão de compra.

## Ponto de partida

O primeiro marco não é o MVP inteiro: é uma cena única com um rosto, três batons, três sombras, apagar/desfazer e comparação antes/depois. Esta validação decide se o restante do conteúdo deve ser produzido.

## Como rodar o protótipo

Godot **4.7** (Forward+/Compatibility). Cena principal: `scenes/makeup/makeup_studio.tscn`.

```text
Godot --path "lira_studio"
Godot --path "lira_studio" --editor
Godot --headless --path "lira_studio" -s res://tests/smoke_prototype.gd
```

Retrato 720×1280. No briefing escolha **Noite de gala** ou **Modo livre**. Toque/mouse pinta na máscara; em Linha/Cílios um toque aplica o estilo com tolerância. Acessórios encaixam por âncora. Espaço = antes/depois; Ctrl+Z / Ctrl+Y = desfazer/refazer. **Look** aplica overlays piloto. **Concluir** só no desafio.

## Documentação

- [Índice de execução](docs/README.md)
- [Roadmap](docs/01-roadmap.md)
- [Mapa de sprites](docs/02-mapa-de-sprites.md)
- [Plano de execução](docs/03-plano-de-execucao.md)
- [Backlog do MVP](docs/04-backlog-mvp.md)
- [Especificação técnica](docs/05-especificacao-tecnica.md)
- [Decisões pendentes](docs/06-decisoes-pendentes.md)
- [Mapa de scripts](docs/07-mapa-de-scripts.md)
- [Manifesto dos assets de protótipo](assets/ART_ASSETS.md)

## Escopo atual

Protótipo Godot em retrato: 4 modelos, pintura por máscara, delineador/cílios com guia, 12 acessórios, desafio de gala, modo livre e save local. Coleção e 20 desafios continuam no backlog.

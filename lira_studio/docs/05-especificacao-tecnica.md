# Especificação técnica inicial

## Estrutura sugerida

```text
lira_studio/
  assets/
  scenes/
    app/
    makeup/
    challenge/
    ui/
  scripts/
    data/
    services/
    makeup/
    ui/
  resources/
    models/
    cosmetics/
    challenges/
  tests/
  docs/
```

## Componentes

| Componente | Responsabilidade | Não deve fazer |
| --- | --- | --- |
| `ModelData` | ID, sprites, máscaras e âncoras de uma modelo. | Calcular pontos ou gravar save. |
| `CosmeticData` | Categoria, cor, acabamento, preço e requisito. | Conhecer uma tela específica. |
| `MakeupCanvas` | Receber gestos e aplicar textura na região válida. | Decidir recompensa de desafio. |
| `ChallengeData` | Tema, objetivos, recomendações e recompensa. | Manipular sprites diretamente. |
| `ScoringService` | Avaliar objetivos, aplicação e harmonia do tema. | Avaliar características naturais da modelo. |
| `SaveService` | Persistir versão, moedas, estrelas, inventário e ajustes. | Renderizar UI. |
| `GameState` | Estado da sessão e navegação de alto nível. | Duplicar dados persistidos. |

## Dados mínimos

```gdscript
# CosmeticData.gd (conceito)
id: String
category: String # foundation, blush, eyeshadow, eyeliner, mascara, lipstick, accessory
display_name: String
color: Color
finish: String
price: int
unlock_requirement: String
asset_path: String
thumbnail_path: String
```

```gdscript
# ChallengeData.gd (conceito)
id: String
model_id: String
theme: String
mandatory_objectives: Array
optional_objectives: Array
recommended_cosmetic_ids: Array[String]
coin_reward: int
star_thresholds: Array[int]
```

## Regras técnicas do protótipo

- Renderizar cada categoria de maquiagem em uma camada independente para permitir limpar somente a etapa ativa.
- Registrar comandos de aplicação, e não apenas capturas de tela, para permitir desfazer/refazer com memória limitada.
- Manter máscaras e arte no mesmo tamanho e no mesmo ponto de origem por modelo.
- Não introduzir backend, login ou sincronização no MVP.
- Salvar com campo de versão e migração segura antes de alterar o formato de dados.
- Testar toque e exportação Android desde M0; não deixar a primeira build móvel para o fim.

## Métricas de teste inicial

- FPS médio e mínimo durante aplicação com todas as camadas ativas.
- Memória usada pela cena da modelo e ao trocar de modelo.
- Tempo para concluir o primeiro desafio.
- Número de desfazeres por ferramenta e abandono por etapa.

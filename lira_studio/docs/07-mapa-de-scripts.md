# Mapa de scripts necessários

Este mapa traduz o GDD em scripts Godot 4.x com GDScript. Os caminhos são propostos; a implementação começa pelos itens P0, necessários para validar a aplicação de maquiagem.

## Visão de dependências

```text
Resources de dados ──┬── MakeupSession ── MakeupCanvas ── HistoryService
                     │                         │
                     │                         └── ToolController
                     │
                     ├── ChallengeService ── ScoringService
                     │
                     └── SaveService ── InventoryService

GameState ── SceneRouter ── telas de início, seleção, maquiagem e resultado
```

## Scripts P0 — protótipo de pintura

| Arquivo | Classe | Responsabilidade | Depende de | Critério de aceite |
| --- | --- | --- | --- | --- |
| `scripts/data/model_data.gd` | `ModelData` | Resource com ID, sprites, máscaras e âncoras da modelo. | Assets da modelo. | Carrega o rosto piloto e expõe regiões por ID. |
| `scripts/data/cosmetic_data.gd` | `CosmeticData` | Resource com categoria, cor, acabamento, intensidade e paths visuais. | — | Batom e sombra são definidos por dados, não por condicionais de UI. |
| `scripts/makeup/makeup_session.gd` | `MakeupSession` | Mantém o estado da modelo, ferramenta e camadas aplicadas na sessão. | `ModelData`, `CosmeticData`. | Trocar cosmético preserva o que já foi aplicado. |
| `scripts/makeup/makeup_canvas.gd` | `MakeupCanvas` | Converte toque/arraste em aplicação sobre uma camada, respeitando máscara. | `MakeupSession`. | Nenhum traço aparece fora de lábios ou pálpebras. |
| `scripts/makeup/tool_controller.gd` | `ToolController` | Seleciona categoria, cor, tamanho e intensidade da ferramenta ativa. | `CosmeticData`, `MakeupCanvas`. | Batom e sombra alternam sem perder o estado da sessão. |
| `scripts/makeup/history_service.gd` | `HistoryService` | Registra comandos para desfazer/refazer e limpar etapa. | `MakeupSession`. | Dez ações consecutivas desfazem/refazem corretamente. |
| `scripts/ui/makeup_hud.gd` | `MakeupHud` | Liga botões, slider, antes/depois e feedback visual à sessão. | `ToolController`, `HistoryService`. | Controles são acessíveis por toque e refletem a ferramenta ativa. |
| `scripts/app/game_state.gd` | `GameState` | Autoload do estado transitório da aplicação e da sessão atual. | — | Cena de maquiagem recebe o modelo e o modo selecionados. |

## Scripts P1 — vertical slice e MVP

| Arquivo | Classe | Responsabilidade | Depende de |
| --- | --- | --- | --- |
| `scripts/data/challenge_data.gd` | `ChallengeData` | Resource com tema, objetivos, recompensas e modelo. | `ModelData`, IDs de cosméticos. |
| `scripts/challenge/challenge_service.gd` | `ChallengeService` | Inicia desafio, acompanha objetivos e prepara o resultado. | `ChallengeData`, `MakeupSession`. |
| `scripts/challenge/scoring_service.gd` | `ScoringService` | Calcula estrelas e moedas de modo explicável e inclusivo. | `ChallengeData`, estado aplicado. |
| `scripts/save/save_service.gd` | `SaveService` | Lê e grava save local com versão e migrações. | `InventoryService`, `SettingsService`. |
| `scripts/save/inventory_service.gd` | `InventoryService` | Controla moedas, estrelas, itens obtidos e requisitos. | `SaveService`, `CosmeticData`. |
| `scripts/save/settings_service.gd` | `SettingsService` | Armazena volume, vibração, idioma futuro e preferências de acessibilidade. | `SaveService`. |
| `scripts/ui/scene_router.gd` | `SceneRouter` | Navegação entre abertura, início, seleção, maquiagem e resultado. | `GameState`. |
| `scripts/ui/challenge_select.gd` | `ChallengeSelect` | Mostra desafios, modelo, tema, recompensa e bloqueios. | `ChallengeService`, `InventoryService`. |
| `scripts/ui/result_screen.gd` | `ResultScreen` | Exibe antes/depois, objetivos, estrelas, moedas e próxima ação. | `ScoringService`, `InventoryService`. |
| `scripts/ui/collection_screen.gd` | `CollectionScreen` | Lista cosméticos, filtros, preço e requisito de desbloqueio. | `InventoryService`, `CosmeticData`. |
| `scripts/tutorial/tutorial_controller.gd` | `TutorialController` | Exibe instruções curtas da primeira sessão e registra conclusão. | `GameState`, `SaveService`. |
| `scripts/media/look_capture_service.gd` | `LookCaptureService` | Gera imagem de antes/depois e solicita permissões somente quando necessário. | Cena de resultado, APIs Android. |

## Scripts P2 — qualidade, lançamento e extensões

| Arquivo | Classe | Responsabilidade | Condição para iniciar |
| --- | --- | --- | --- |
| `scripts/audio/audio_service.gd` | `AudioService` | Música, efeitos, volume e vibração opcional. | Vertical slice aprovado. |
| `scripts/vfx/feedback_service.gd` | `FeedbackService` | Partículas, brilho e feedback visual discreto. | Desempenho do MVP conhecido. |
| `scripts/analytics/analytics_service.gd` | `AnalyticsService` | Eventos mínimos, consentimento e filas locais. | Política de privacidade e faixa etária confirmadas. |
| `scripts/monetization/rewarded_ad_service.gd` | `RewardedAdService` | Anúncio recompensado estritamente opcional. | Retenção e economia validadas. |
| `scripts/content/content_catalog.gd` | `ContentCatalog` | Carrega e valida catálogo de modelos, itens e desafios. | Volume de conteúdo tornar o carregamento manual impraticável. |

## Ordem de criação

1. `ModelData` e `CosmeticData`.
2. `MakeupSession` e `MakeupCanvas`.
3. `ToolController`, `HistoryService` e `MakeupHud`.
4. Teste em Android do fluxo de pintura.
5. `ChallengeData`, `ChallengeService` e `ScoringService`.
6. `SaveService`, `InventoryService` e telas de resultado/seleção.
7. Demais categorias de maquiagem, conteúdo e sistemas P2.

## Autoloads propostos

| Script | Autoload? | Motivo |
| --- | --- | --- |
| `GameState` | Sim | Estado que atravessa a troca de cenas. |
| `SaveService` | Sim | Fonte única do save e carregamento inicial. |
| `InventoryService` | Sim | Acesso consistente a moedas e desbloqueios. |
| `SettingsService` | Sim | Preferências globais de áudio e vibração. |
| `SceneRouter` | Opcional | Use como autoload apenas se a navegação for centralizada desde o início. |
| `MakeupSession` | Não | Deve existir somente durante a sessão de maquiagem. |
| `MakeupCanvas` | Não | Componente da cena de maquiagem. |

## Regras de implementação

- Um script não deve carregar assets por nome literal quando puder receber um `Resource` ou ID.
- `MakeupCanvas` não calcula recompensa; `ScoringService` não altera pixels.
- Salve dados de jogo, não texturas completas, sempre que for possível reconstruir a aparência pelos comandos de aplicação.
- Toda integração de anúncio, telemetria ou permissão deve ficar isolada atrás de um serviço.
- Cada script novo precisa de uma cena ou teste manual com critério de aceite no Android.

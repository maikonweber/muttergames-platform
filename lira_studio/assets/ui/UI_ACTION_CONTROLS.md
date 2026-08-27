# Controles de ação da UI

O atlas `atlas/ui_action_controls_atlas_v1.png` contém seis sprites RGBA, exportados em `action_controls/` como cards individuais de 512 × 512. Todos preservam transparência fora do ícone e devem receber redução por escala no runtime, não reamostragem destrutiva no arquivo-fonte.

| Ação | Arquivo | Uso |
| --- | --- | --- |
| Desfazer | `action_controls/action_undo_card_v1.png` | Reverte a última ação de maquiagem. |
| Refazer | `action_controls/action_redo_card_v1.png` | Reaplica a ação revertida. |
| Comparar | `action_controls/action_compare_card_v1.png` | Botão de antes/depois. |
| Apagar | `action_controls/action_erase_card_v1.png` | Ativa o apagador. |
| Confirmar | `action_controls/action_confirm_card_v1.png` | Confirma look, seleção ou resultado. |
| Bloqueado | `action_controls/action_locked_card_v1.png` | Identifica item ainda não desbloqueado. |

Para o HUD de maquiagem, use 96–128 px visuais como ponto de partida. Mantenha áreas de toque de pelo menos 48 dp, mesmo quando o ícone for exibido menor.

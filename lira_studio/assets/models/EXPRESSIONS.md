# Frames de expressão

Cada modelo possui um frame de sorriso completo em `expressions/model_XX_expression_smile_v1.png`. O arquivo mantém canvas de 1024 × 1536, fundo e pose do rosto-base.

| Estado | Arquivo | Uso |
| --- | --- | --- |
| `idle` | `base/model_XX_face_base_v1.png` | Edição de maquiagem e telas neutras. |
| `smile` | `expressions/model_XX_expression_smile_v1.png` | Celebração de objetivo, resultado e recompensa. |
| `blink` | Pendente | Frame breve do loop de idle. |

## Regra de uso

- Não componha overlays de maquiagem diretamente sobre o frame de sorriso no P0; os pixels faciais mudaram e ainda não há máscaras equivalentes.
- Durante a sessão de maquiagem, use sempre o rosto-base e seus overlays.
- Na tela de resultado, troque para o sorriso somente depois de concluir a composição ou use uma transição curta.
- Para produção, produzir máscaras sincronizadas para cada expressão ou migrar expressão para rig facial.

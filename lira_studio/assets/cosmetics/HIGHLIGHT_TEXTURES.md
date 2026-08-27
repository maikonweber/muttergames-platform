# Texturas de iluminador

As quatro texturas em `highlights/` foram fatiadas do atlas `atlas/cosmetic_highlight_texture_atlas_v1.png`. Cada uma mede 627 × 627 px, é opaca e deve ser colorizada/mesclada pelo shader somente dentro de uma máscara dedicada de iluminador.

| ID sugerido | Arquivo | Caráter |
| --- | --- | --- |
| `highlight_pearl_soft` | `highlights/highlight_pearl_soft_card_v1.png` | Pérola sutil. |
| `highlight_champagne_fine` | `highlights/highlight_champagne_fine_card_v1.png` | Champanhe fino. |
| `highlight_gold_subtle` | `highlights/highlight_gold_subtle_card_v1.png` | Dourado discreto. |
| `highlight_rose_shimmer` | `highlights/highlight_rose_shimmer_card_v1.png` | Rosé cintilante. |

Não use `skin_mask` como máscara final: crie regiões específicas para ponte do nariz, topo das maçãs e arco do cupido, com intensidade baixa.

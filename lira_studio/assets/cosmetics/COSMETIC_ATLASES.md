# Mapa dos atlases de cosméticos

## Acabamentos

Arquivo: `atlas/cosmetic_finish_texture_atlas_v1.png`

Grade 3 × 2, leitura da esquerda para a direita e de cima para baixo:

| Índice | ID | Aplicação sugerida |
| ---: | --- | --- |
| 0 | `matte` | Base, blush, sombra e batom matte. |
| 1 | `satin` | Base, sombra e batom acetinado. |
| 2 | `pearl` | Sombra perolada e iluminador. |
| 3 | `glitter` | Sombra e detalhes de festa. |
| 4 | `metallic` | Sombra e batom metálico. |
| 5 | `gloss` | Batom e efeito molhado. |

O atlas é neutro. A cor deve vir do item cosmético ou do shader, e a textura deve ser limitada pelas máscaras faciais.

## Iluminadores

Arquivo: `atlas/cosmetic_highlight_texture_atlas_v1.png`

Grade 2 × 2: `pearl_soft`, `champagne_fine`, `gold_subtle` e `rose_shimmer`, nessa ordem de leitura. Aplique a cor pelo shader e limite o efeito a uma máscara de iluminador dedicada; não reutilize a máscara inteira de pele.

## Delineadores

Arquivo: `eyeliner/eyeliner_style_atlas_v1.png`

Grade 3 × 2:

| Índice | ID |
| ---: | --- |
| 0 | `natural_thin` |
| 1 | `classic_cat` |
| 2 | `long_wing` |
| 3 | `short_round` |
| 4 | `double_graphic` |
| 5 | `dramatic_thick` |

O atlas possui fundo transparente. Cada célula contém o par esquerdo/direito como referência visual; para produção, separe os lados e ajuste-os às máscaras `lash_l` e `lash_r` de cada modelo.

Os 12 sprites individuais já estão em `eyeliner/items/`; consulte `EYE_STYLE_SPRITES.md` para os nomes e regras de aplicação.

## Cílios e máscara

Arquivo: `mascara/mascara_style_atlas_v1.png`

Grade 2 × 2:

| Índice | ID |
| ---: | --- |
| 0 | `natural_defined` |
| 1 | `lengthening` |
| 2 | `volumizing` |
| 3 | `dramatic_fan` |

Cada célula possui um par simétrico em fundo transparente. Use como fonte para sprites separados por olho e calibre escala, rotação e posição para cada rosto.

Os 8 sprites individuais já estão em `mascara/items/`; consulte `EYE_STYLE_SPRITES.md` para os nomes e regras de aplicação.

## Importação no Godot

- Desative repetição nos atlases de delineador e cílios.
- Use filtro linear durante o protótipo.
- Recorte por região matemática, sem incluir as faixas transparentes entre células.
- Para acabamentos, teste os modos `mix`, `multiply`, `screen` e `add` conforme a categoria.
- Não aplique delineador ou cílios sem a máscara correspondente do modelo.

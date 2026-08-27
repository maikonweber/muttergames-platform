# Catálogo de acessórios

Os PNGs em `items/` foram extraídos dos atlases de seleção e receberam transparência estimada a partir do fundo. Eles são sprites de protótipo para composição; antes do lançamento, revisar visualmente as bordas semitransparentes e os pontos de encaixe por modelo.

| Item | Sprite | Fonte | Âncora de runtime | Escala inicial |
|---|---|---|---|---|
| Brincos de pérola | `items/accessory_pearl_drop_earrings_v1.png` | atlas v1, célula 1 | lóbulo esquerdo e direito | 0,48 da largura da cabeça |
| Argolas douradas | `items/accessory_gold_hoop_earrings_v1.png` | atlas v1, célula 2 | lóbulo esquerdo e direito | 0,45 |
| Presilha de estrela | `items/accessory_star_barrette_v1.png` | atlas v1, célula 3 | têmpora direita | 0,28 |
| Presilha floral | `items/accessory_flower_barrette_v1.png` | atlas v1, célula 4 | têmpora esquerda | 0,30 |
| Óculos gatinho | `items/accessory_cat_eye_sunglasses_v1.png` | atlas v1, célula 5 | ponte nasal | 0,68 |
| Tiara de coração | `items/accessory_heart_tiara_v1.png` | atlas v1, célula 6 | topo da cabeça | 0,76 |
| Brincos de coração | `items/accessory_heart_stud_earrings_v1.png` | atlas v2, célula 1 | lóbulo esquerdo e direito | 0,31 |
| Presilha de lua | `items/accessory_moon_barrette_v1.png` | atlas v2, célula 2 | têmpora direita | 0,31 |
| Presilha safira | `items/accessory_sapphire_barrette_v1.png` | atlas v2, célula 3 | têmpora esquerda | 0,40 |
| Óculos redondos | `items/accessory_round_glasses_v1.png` | atlas v2, célula 4 | ponte nasal | 0,70 |
| Tiara floral | `items/accessory_floral_headband_v1.png` | atlas v2, célula 5 | topo da cabeça | 0,78 |
| Colar de pérolas | `items/accessory_pearl_flower_necklace_v1.png` | atlas v2, célula 6 | base do pescoço | 0,78 |

## Ordem de composição

1. Cabelo traseiro.
2. Modelo e maquiagem.
3. Óculos, brincos e presilhas.
4. Cabelo frontal, quando o acessório deve ficar parcialmente oculto.
5. Tiaras e colar, conforme a âncora; o colar fica acima da roupa/fundo.

Os valores são pontos de partida relativos à largura da cabeça detectada. Cada modelo precisa de ajuste fino no runtime, sobretudo para brincos e acessórios de cabelo.

# Calibração das máscaras da modelo 03

As máscaras deste diretório têm 1024 × 1536 px, exatamente a resolução de `../base/model_03_face_base_v1.png`.

| Máscara | Região | Uso |
| --- | --- | --- |
| `model_03_skin_mask.png` | Face | Limite para base e preparação. |
| `model_03_cheek_l_mask.png` / `_r_mask.png` | Bochechas | Blush. |
| `model_03_eye_l_mask.png` / `_r_mask.png` | Pálpebras | Sombra. |
| `model_03_lash_l_mask.png` / `_r_mask.png` | Linha superior dos olhos | Máscara de cílios e guia do delineador. |
| `model_03_lips_mask.png` | Lábios | Batom e brilho. |

## Teste obrigatório no Godot

1. Sobreponha cada máscara em branco, com 40% de opacidade, ao rosto base.
2. Confirme que os limites não invadem cabelo, dentes ou fundo.
3. Corrija somente os pixels da máscara e mantenha o sprite base em sua origem comum.
4. Não renderize as máscaras na versão final do jogo.

Estas são máscaras de protótipo. A troca do rosto base exige recriar todas as oito máscaras.

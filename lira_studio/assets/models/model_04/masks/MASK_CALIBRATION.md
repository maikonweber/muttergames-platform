# Calibração das máscaras da modelo 04

As máscaras deste diretório têm 1024 × 1536 px, exatamente a resolução de `../base/model_04_face_base_v1.png`.

| Máscara | Região | Uso |
| --- | --- | --- |
| `model_04_skin_mask.png` | Face | Limite para base e preparação. |
| `model_04_cheek_l_mask.png` / `_r_mask.png` | Bochechas | Blush. |
| `model_04_eye_l_mask.png` / `_r_mask.png` | Pálpebras | Sombra. |
| `model_04_lash_l_mask.png` / `_r_mask.png` | Linha superior dos olhos | Máscara de cílios e guia do delineador. |
| `model_04_lips_mask.png` | Lábios | Batom e brilho. |

## Teste obrigatório no Godot

1. Sobreponha cada máscara em branco, com 40% de opacidade, ao rosto base.
2. Confirme que os limites não invadem cabelo, dentes ou fundo.
3. Corrija somente os pixels da máscara e mantenha o sprite base em sua origem comum.
4. Não renderize as máscaras na versão final do jogo.

Estas são máscaras de protótipo. A troca do rosto base exige recriar todas as oito máscaras.

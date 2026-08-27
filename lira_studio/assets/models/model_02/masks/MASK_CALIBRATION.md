# Calibração das máscaras da modelo 02

As máscaras deste diretório têm 1024 × 1536 px, exatamente a resolução de `../base/model_02_face_base_v1.png`.

| Máscara | Região | Uso |
| --- | --- | --- |
| `model_02_skin_mask.png` | Face | Limite para base e preparação. |
| `model_02_cheek_l_mask.png` / `_r_mask.png` | Bochechas | Blush. |
| `model_02_eye_l_mask.png` / `_r_mask.png` | Pálpebras | Sombra. |
| `model_02_lash_l_mask.png` / `_r_mask.png` | Linha superior dos olhos | Máscara de cílios e guia do delineador. |
| `model_02_lips_mask.png` | Lábios | Batom e brilho. |

## Teste obrigatório no Godot

1. Sobreponha cada máscara em branco com 40% de opacidade ao rosto base.
2. Confira que o limite acompanha a região facial e não invade cabelo, dentes ou fundo.
3. Ajuste somente os pixels da máscara se necessário, mantendo o sprite base na origem comum.
4. Não exiba as máscaras no jogo final.

Estas são máscaras de protótipo. Se o rosto base for substituído, recrie todas as oito máscaras.

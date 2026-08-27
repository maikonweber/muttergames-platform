# Calibração das máscaras da modelo 01

As máscaras deste diretório têm 1024 × 1536 px, exatamente a resolução de `../base/model_01_face_base_v1.png`.

| Máscara | Região | Uso |
| --- | --- | --- |
| `model_01_skin_mask.png` | Face | Limite para base e preparação. |
| `model_01_cheek_l_mask.png` / `_r_mask.png` | Bochechas | Blush. |
| `model_01_eye_l_mask.png` / `_r_mask.png` | Pálpebras | Sombra. |
| `model_01_lash_l_mask.png` / `_r_mask.png` | Linha superior dos olhos | Máscara de cílios e guia do delineador. |
| `model_01_lips_mask.png` | Lábios | Batom e brilho. |

## Teste obrigatório no Godot

1. Sobreponha a máscara em branco com 40% de opacidade sobre o rosto base.
2. Confirme que cada limite acompanha a região correspondente sem invadir olhos, dentes, cabelo ou fundo.
3. Ajuste os pixels da máscara, nunca a posição do sprite base, para preservar a origem comum das camadas.
4. Use as máscaras somente como bloqueio de pintura; elas não devem aparecer no jogo final.

Estas são máscaras de protótipo, não arte final. A troca do rosto exige recriar todas as oito máscaras.

# Catálogo de overlays piloto

Os quatro modelos possuem um conjunto inicial de base, blush, sombra e batom em PNG RGBA de 1024 × 1536. Eles usam a origem e o canvas do rosto-base correspondente.

| Modelo | Base | Blush | Sombra | Batom |
| --- | --- | --- | --- | --- |
| 01 | `warm_natural` | `rose_soft` | `champagne_pearl` | `ruby_gloss` |
| 02 | `deep_natural` | `berry_soft` | `copper_satin` | `plum_gloss` |
| 03 | `olive_natural` | `coral_soft` | `bronze_satin` | `terracotta_gloss` |
| 04 | `peach_natural` | `peach_soft` | `rose_gold_pearl` | `berry_gloss` |

## Estrutura

```text
model_XX/makeup/
  foundation/model_XX_foundation_*_overlay_v1.png
  blush/model_XX_blush_*_overlay_v1.png
  eyeshadow/model_XX_eyeshadow_*_overlay_v1.png
  lipstick/model_XX_lipstick_*_overlay_v1.png
```

## Uso

- Trate estas imagens como referências visuais de vertical slice.
- Exponha intensidade, cor e acabamento como parâmetros de shader; não codifique esses valores em lógica de jogo.
- Renderize cabelo frontal acima dos overlays após a divisão dos sprites de cabelo.
- Revise máscaras e bordas antes de publicar conteúdo final.

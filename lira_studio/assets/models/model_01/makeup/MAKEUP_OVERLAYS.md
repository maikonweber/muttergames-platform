# Overlays piloto da modelo 01

Todos os arquivos usam canvas de 1024 × 1536 e origem idêntica ao rosto-base.

| Ordem | Arquivo | Máscara de origem | Mistura inicial |
| ---: | --- | --- | --- |
| 1 | `foundation/model_01_foundation_warm_natural_overlay_v1.png` | `skin` com olhos e lábios removidos | `mix`, intensidade 35%–60% |
| 2 | `blush/model_01_blush_rose_soft_overlay_v1.png` | `cheek_l` + `cheek_r` | `mix` ou `soft light`, 35%–75% |
| 3 | `eyeshadow/model_01_eyeshadow_champagne_pearl_overlay_v1.png` | metade superior de `eye_l` + `eye_r` | `screen` ou `add`, 25%–70% |
| 4 | `lipstick/model_01_lipstick_ruby_gloss_overlay_v1.png` | `lips` | `mix`, 50%–100% |

## Ordem de renderização

`rosto-base → base → blush → sombra → delineador → cílios → batom → cabelo-frente`

Durante o protótipo, `hair_full` pode ser renderizado por último para esconder a parte da máscara de pele que alcança a linha do cabelo. Na produção, use `hair_back` atrás do rosto e `hair_front` acima da maquiagem.

## Critérios de validação

- Nenhum overlay deve alterar pixels fora do canvas ou exigir offset próprio.
- Olhos e lábios permanecem livres da camada de base.
- A sombra não cobre a metade inferior dos olhos.
- Blush e batom devem aceitar redução de intensidade sem formar bordas duras.
- Cor e acabamento devem migrar para parâmetros de shader; estes PNGs são referências visuais do P0.

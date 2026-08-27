# Sprites de delineador e cílios

Os pares dos atlas foram separados por olho, preservando o canal alfa. São fontes de arte para calibração por modelo, não sprites prontos para composição direta sobre o rosto.

## Delineador

Pasta: `eyeliner/items/`. Cada estilo tem `*_left_v1.png` e `*_right_v1.png`, com 256 × 512 px.

`natural_thin`, `classic_cat`, `long_wing`, `short_round`, `double_graphic`, `dramatic_thick`.

## Máscara de cílios

Pasta: `mascara/items/`. Cada estilo tem `*_left_v1.png` e `*_right_v1.png`. Como o atlas-fonte tem largura ímpar de célula, os lados medem 313 × 627 e 314 × 627 px, respectivamente; não redimensione os arquivos só para igualá-los.

`natural_defined`, `lengthening`, `volumizing`, `dramatic_fan`.

## Aplicação

1. Use `left` na âncora esquerda e `right` na direita; não espelhe automaticamente.
2. Gere um overlay no canvas 1024 × 1536 de cada modelo antes de habilitar um estilo no runtime.
3. Para `natural_defined`, use os overlays já aprovados em `assets/models/MASCARA_CALIBRATION.md`.
4. Cada modelo precisa de posição, escala e rotação próprias. Registre os valores no recurso de estilo em vez de alterar os PNGs-fonte.

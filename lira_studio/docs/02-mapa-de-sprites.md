# Mapa de sprites e máscaras

## Padrão de composição

Cada modelo usa uma cena frontal e camadas 2D alinhadas no mesmo canvas. O rosto base não muda de posição; maquiagem, cabelo e acessórios são desenhados sobre ele. Máscaras em tons de cinza definem os limites de cada região, e não devem aparecer ao jogador.

**Resolução piloto recomendada:** canvas de 1080 × 1920 px; área de arte da modelo entre 900 e 1100 px de altura. Confirmar a resolução final após o primeiro teste em aparelho.

## Estrutura de arquivos

```text
assets/
  models/
    model_01/
      base/
      masks/
      makeup/
      hair/
      accessories/
      thumbnails/
  cosmetics/
    lipstick/
    eyeshadow/
    blush/
    foundation/
    eyeliner/
    mascara/
  ui/
  vfx/
  backgrounds/
```

## Convenção de nome

`{grupo}_{modelo-opcional}_{regiao-opcional}_{variante}_{estado}.png`

Exemplos: `model_01_face_base.png`, `mask_model_01_lips.png`, `lipstick_rose_01_color.png`, `eyeshadow_gold_01_overlay.png`, `ui_tool_lipstick_normal.png`.

Use apenas minúsculas, `snake_case`, PNG RGBA e origem de sprite consistente. Arquivos de máscara terminam sempre em `_mask.png`.

## Pacote mínimo por modelo

| ID | Arquivo/camada | Tipo | MVP | Observação |
| --- | --- | --- | --- | --- |
| M01-01 | `model_01_face_base.png` | Sprite | Sim | Rosto sem maquiagem. |
| M01-02 | `model_01_face_shadow.png` | Sprite | Sim | Sombra/iluminação fixa, se necessária. |
| M01-03 | `model_01_skin_mask.png` | Máscara | Sim | Limite para base/preparação. |
| M01-04 | `model_01_cheek_l_mask.png` e `_r_mask.png` | Máscaras | Sim | Limites do blush. |
| M01-05 | `model_01_eye_l_mask.png` e `_r_mask.png` | Máscaras | Sim | Limites da sombra. |
| M01-06 | `model_01_lips_mask.png` | Máscara | Sim | Limite de batom e brilho. |
| M01-07 | `model_01_lash_l_mask.png` e `_r_mask.png` | Máscaras | Sim | Guia para máscara de cílios. |
| M01-08 | `model_01_hair_back.png` | Sprite | Sim | Renderizado atrás do rosto. |
| M01-09 | `model_01_hair_front.png` | Sprite | Sim | Renderizado à frente do rosto. |
| M01-10 | `model_01_expression_idle.png` | Sprite | Sim | Piscar/sorriso pode usar frames adicionais. |
| M01-11 | `model_01_thumb.png` | UI | Sim | Seleção de modelo. |

Replicar o pacote para `model_02` a `model_04`; nunca reutilizar máscaras entre rostos diferentes.

## Biblioteca de cosméticos do MVP

| Categoria | Quantidade | Entrega visual |
| --- | ---: | --- |
| Base | 8 tons adaptáveis | Cor/overlay + parâmetros de intensidade. |
| Blush | 8 | Cor + textura suave opcional. |
| Sombra | 16 | Cor, acabamento e thumbnail. |
| Delineador | 6 cores / 3 estilos | Overlay de estilo + máscara/guia. |
| Máscara | 4 estilos | Overlay por olho. |
| Batom | 16 cores / 3 acabamentos | Cor + brilho/textura opcional. |
| Acessórios | 12 | Sprite frontal, thumbnail e ponto de ancoragem. |
| Fundos | 6 | Sprite 1080 × 1920 ou escalável. |

## Atlas e importação

- Use atlas somente para ícones de UI, thumbnails e itens pequenos de uma mesma categoria.
- Mantenha rostos, cabelos e overlays de maquiagem em arquivos individuais; isso reduz acoplamento e facilita a composição por modelo.
- Desative filtro para pixel art; para a direção estilizada polida do GDD, use filtro linear e comprima texturas após confirmar que não há faixas de cor perceptíveis.
- Defina a ordem de renderização: `fundo → cabelo_trás → rosto_base → base → blush → sombra → delineador → cílios → batom → cabelo_frente → acessórios → vfx → UI`.

## Checklist de aceite da arte

- Todas as camadas se alinham no mesmo ponto de origem no canvas.
- Máscaras não têm bordas visíveis no resultado final.
- Uma aplicação não invade olhos, lábios ou pele fora da região permitida.
- Cada cosmético tem miniatura, ID estável e prévia no rosto.
- O rosto continua legível com todas as camadas e acessórios ativos.

## Assets de protótipo disponíveis

Os bitmaps gerados para o P0 estão catalogados em [`../assets/ART_ASSETS.md`](../assets/ART_ASSETS.md). Eles já cobrem quatro rostos-base, quatro frames de sorriso, máscaras técnicas, miniaturas, cabelos completos e suas camadas frontal/traseira de protótipo, seis [ferramentas cosméticas](../assets/ui/COSMETIC_TOOL_CONTROLS.md), seis [amostras de cor](../assets/cosmetics/COLOR_SWATCHES.md), seis [texturas de acabamento](../assets/cosmetics/FINISH_TEXTURES.md), quatro [texturas de iluminador](../assets/cosmetics/HIGHLIGHT_TEXTURES.md), doze sprites de delineador e oito fontes de cílios [separados por olho](../assets/cosmetics/EYE_STYLE_SPRITES.md), dezesseis [overlays de cílios por modelo](../assets/models/MASCARA_CALIBRATION.md), dezesseis overlays piloto (quatro por modelo), doze acessórios individuais com [catálogo e âncoras](../assets/accessories/ACCESSORY_CATALOG.md), seis [cards de desafio](../assets/ui/CHALLENGE_EMBLEMS.md), seis [controles de ação](../assets/ui/UI_ACTION_CONTROLS.md), VFX e seis fundos. A piscada, a revisão artística dos cílios intensos, a calibração fina dos demais overlays e o refinamento manual das fronteiras de cabelo continuam pendentes antes da composição final.

# Assets gerados para o protótipo

| Arquivo | Uso | Estado |
| --- | --- | --- |
| `models/model_01/base/model_01_face_base_v1.png` | Rosto piloto frontal para a cena de maquiagem. | Pronto para composição de protótipo; fundo ainda opaco. |
| `models/model_02/base/model_02_face_base_v1.png` | Segunda modelo frontal, com pele escura e cabelo cacheado. | Pronta como referência para o segundo pacote de máscaras. |
| `models/model_03/base/model_03_face_base_v1.png` | Terceira modelo frontal, com pele oliva e cabelo curto liso. | Pronta como referência para o terceiro pacote de máscaras. |
| `models/model_04/base/model_04_face_base_v1.png` | Quarta modelo frontal, com pele clara sardenta e cabelo ruivo. | Pronta como referência para o quarto pacote de máscaras. |
| `models/model_04/masks/*.png` | Oito máscaras de regiões do rosto da quarta modelo. | Prontas para teste técnico; requerem calibração no canvas da cena. |
| `models/model_01..04/thumbnails/*_thumb.png` | Quatro miniaturas quadradas de seleção. | Prontas para listas, cards e seleção de modelo. |
| `models/model_01..04/hair/*_hair_full_v1.png` | Quatro sprites RGBA de cabelo completo, alinhados ao canvas de cada modelo. | Prontos para prototipagem; validar alinhamento e limpar pequenos resíduos de chroma antes da arte final. |
| `models/model_01..04/hair/*_hair_back_v1.png` e `*_hair_front_v1.png` | Oito camadas técnicas de cabelo separadas por profundidade. | Prontas para composição do vertical slice; cada par recompõe o `hair_full` sem perda de pixels. |
| `models/model_01..04/expressions/*_expression_smile_v1.png` | Quatro frames completos de sorriso, um por modelo. | Prontos para celebração e tela de resultado; não devem substituir a base durante a edição de maquiagem. |
| `models/model_01/makeup/foundation/model_01_foundation_warm_natural_overlay_v1.png` | Overlay piloto de base natural para a modelo 01. | Pronto para vertical slice; intensidade recomendada controlada pelo motor. |
| `models/model_01/makeup/blush/model_01_blush_rose_soft_overlay_v1.png` | Overlay piloto de blush rosa suave para a modelo 01. | Pronto para vertical slice; derivado das duas máscaras de bochecha. |
| `models/model_01/makeup/eyeshadow/model_01_eyeshadow_champagne_pearl_overlay_v1.png` | Overlay piloto de sombra champanhe perolada para a modelo 01. | Pronto para vertical slice; restringido à metade superior das máscaras dos olhos. |
| `models/model_01/makeup/lipstick/model_01_lipstick_ruby_gloss_overlay_v1.png` | Overlay piloto de batom rubi gloss para a modelo 01. | Pronto para vertical slice; derivado da máscara de lábios. |
| `models/model_02..04/makeup/*/*_overlay_v1.png` | Doze overlays piloto de base, blush, sombra e batom para as modelos 02–04. | Prontos para vertical slice; cada arquivo usa a máscara do próprio rosto. |
| `models/model_03/masks/*.png` | Oito máscaras de regiões do rosto da terceira modelo. | Prontas para teste técnico; requerem calibração no canvas da cena. |
| `models/model_02/masks/*.png` | Oito máscaras de regiões do rosto da segunda modelo. | Prontas para teste técnico; requerem calibração no canvas da cena. |
| `models/model_01/masks/*.png` | Oito máscaras de regiões do rosto da modelo piloto. | Prontas para teste técnico; requerem calibração no canvas da cena. |
| `ui/atlas/ui_cosmetic_tools_atlas_v1.png` | Atlas visual de ferramentas cosméticas. | Pronto para fatiamento manual no Godot; contém batom, pincel, paleta de sombra, delineador, máscara e esponja. |
| `ui/cosmetic_tools/*_card_v1.png` | Seis sprites RGBA individuais das ferramentas cosméticas. | Prontos para o HUD e menu de categorias; IDs de uso em `ui/COSMETIC_TOOL_CONTROLS.md`. |
| `ui/atlas/ui_action_controls_atlas_v1.png` e `ui/action_controls/*_card_v1.png` | Atlas e seis sprites RGBA de ações de interface. | Prontos para desfazer, refazer, comparar, apagar, confirmar e estado bloqueado. |
| `ui/atlas/challenge_theme_emblems_atlas_v1.png` e `ui/challenge_emblems/*_card_v1.png` | Atlas e seis sprites RGBA de seleção de desafios. | Prontos para a seleção de temas, botões e cards; preservam transparência fora do emblema. |
| `cosmetics/atlas/cosmetic_color_swatches_v1.png` | Atlas 3 × 2 de cores para o P0. | Pronto para fatiamento: rubi, rosa, ameixa, champanhe, cobre e violeta. |
| `cosmetics/swatches/*_card_v1.png` | Seis thumbnails individuais de cor. | Prontos para seleção de batom e sombra; IDs em `cosmetics/COLOR_SWATCHES.md`. |
| `cosmetics/atlas/cosmetic_finish_texture_atlas_v1.png` | Atlas 3 × 2 de acabamentos neutros para shader. | Pronto para fatiamento: matte, cetim, perolado, glitter, metálico e gloss. |
| `cosmetics/finishes/*_card_v1.png` | Seis texturas individuais de acabamento. | Prontas para carregar por ID em shader; guia em `cosmetics/FINISH_TEXTURES.md`. |
| `cosmetics/atlas/cosmetic_highlight_texture_atlas_v1.png` | Atlas 2 × 2 de texturas neutras de iluminador. | Pronto para colorização por shader: pérola, champanhe, dourado e rosé. |
| `cosmetics/highlights/*_card_v1.png` | Quatro texturas individuais de iluminador. | Prontas para shader e seleção por ID; guia em `cosmetics/HIGHLIGHT_TEXTURES.md`. |
| `cosmetics/eyeliner/eyeliner_style_atlas_v1.png` | Atlas RGBA 3 × 2 com seis pares de delineadores. | Pronto para fatiamento e calibração por modelo; fundo transparente. |
| `cosmetics/mascara/mascara_style_atlas_v1.png` | Atlas RGBA 2 × 2 com quatro pares de cílios. | Pronto para fatiamento e calibração por modelo; fundo transparente. |
| `cosmetics/eyeliner/items/*_left_v1.png` e `*_right_v1.png` | Doze sprites individuais de delineador. | Prontos para calibração por olho e modelo; guia em `cosmetics/EYE_STYLE_SPRITES.md`. |
| `cosmetics/mascara/items/*_left_v1.png` e `*_right_v1.png` | Oito sprites individuais de cílios. | Prontos para calibração por olho e modelo; guia em `cosmetics/EYE_STYLE_SPRITES.md`. |
| `models/model_01..04/makeup/mascara/*_overlay_v1.png` | Dezesseis overlays de cílios, quatro estilos por rosto, alinhados ao canvas correspondente. | Prontos para runtime; detalhes e revisão final em `models/MASCARA_CALIBRATION.md`. |
| `backgrounds/background_gala_01_v1.png` | Fundo de foto para desafio/noite de gala. | Pronto para a tela de resultado em retrato. |
| `backgrounds/background_daily_01_v1.png` | Fundo de foto para modo livre e looks do dia a dia. | Pronto para a tela de resultado em retrato. |
| `backgrounds/background_festival_01_v1.png` | Fundo de foto para desafio/festival ao pôr do sol. | Pronto para composição em retrato; centro livre para a modelo. |
| `backgrounds/background_fantasy_01_v1.png` | Fundo de foto para desafio/fantasia em jardim encantado. | Pronto para composição em retrato; centro livre para a modelo. |
| `backgrounds/background_urban_editorial_01_v1.png` | Fundo de foto para desafio/editorial urbano. | Pronto para composição em retrato; centro livre para a modelo. |
| `backgrounds/background_romantic_garden_01_v1.png` | Fundo de foto para desafio/celebração romântica. | Pronto para composição em retrato; centro livre para a modelo. |
| `accessories/atlas/accessory_selection_atlas_v1.png` | Atlas 3 × 2 de acessórios. | Pronto para miniaturas de seleção: brincos, argolas, presilhas, óculos e tiara. |
| `accessories/atlas/accessory_selection_atlas_v2.png` | Segundo atlas 3 × 2 de acessórios. | Completa o catálogo inicial de 12 itens com brincos, presilhas, óculos, tiara e colar. |
| `accessories/items/accessory_*_v1.png` | Doze sprites RGBA individuais de acessórios. | Prontos para protótipo de composição; ancoragens e escalas iniciais em `accessories/ACCESSORY_CATALOG.md`. |
| `vfx/vfx_makeup_sparkle_sheet_v1.png` | Folha 4 × 4 de efeitos de brilho. | Usar com mistura aditiva; sequência de explosão e dissipação. |

## Observações de produção

- A geração de recorte transparente do rosto foi bloqueada pela moderação do gerador. Portanto, `model_01_face_base_v1.png` deve ser usado como referência/protótipo de cena, não como camada final de composição.
- Antes de implementar as camadas de maquiagem, produzir ou aprovar as máscaras alinhadas: `skin`, `cheek_l`, `cheek_r`, `eye_l`, `eye_r`, `lips`, `lash_l` e `lash_r`.
- As máscaras de `model_01` foram geradas como aproximações técnicas no mesmo canvas de 1024 × 1536 do rosto piloto. Verifique o alinhamento com uma camada de depuração antes de publicar conteúdo.
- O atlas de ferramentas possui seis itens em grade visual, mas não tem bordas de célula. No Godot, configure as regiões manualmente após a escolha do tamanho de ícone da UI.
- Assets finais devem preservar os IDs e caminhos definidos em `docs/02-mapa-de-sprites.md`; use sufixo de versão em vez de sobrescrever estes protótipos.
- Os sprites `hair_full_v1` são recortes combinados. As camadas `hair_back_v1` e `hair_front_v1` já foram derivadas sem perda de pixels para o vertical slice; refine manualmente mechas de sobreposição antes da arte final.
- Os overlays da modelo 01 são exemplos coloridos para validar composição. A implementação final deve permitir cor, intensidade e acabamento por parâmetros, preservando as máscaras como fonte de recorte.
- Os frames de sorriso preservam o canvas e a pose do rosto-base. A piscada continua pendente: os overlays técnicos de olho foram rejeitados por não acompanhar as pálpebras com qualidade suficiente.
- Os acessórios individuais foram derivados dos dois atlases por recorte e remoção estimada do fundo. Revise as bordas translúcidas, em especial nos itens claros, antes de arte final.

## Prompts usados

1. Rosto piloto: ilustração 2D mobile de uma modelo adulta frontal, expressão neutra, sem maquiagem, enquadramento simétrico para aplicação em camadas.
1a. Segunda modelo: ilustração 2D mobile de uma modelo adulta frontal, sem maquiagem, com pele escura e cabelo cacheado, para ampliar a variedade do elenco.
1b. Terceira modelo: ilustração 2D mobile de uma modelo adulta frontal, sem maquiagem, com pele oliva e cabelo curto liso, para ampliar a variedade do elenco.
1c. Quarta modelo: ilustração 2D mobile de uma modelo adulta frontal, sem maquiagem, com pele clara sardenta e cabelo ruivo, para ampliar a variedade do elenco.
1d. Miniaturas: recortes quadrados 256 × 256 derivados das quatro modelos para uso na interface de seleção.
1e. Cabelos: extração do penteado de cada rosto-base em canvas 1024 × 1536; quando o gerador não forneceu alfa real, foi usado chroma key com conversão determinística para PNG RGBA.
2. Atlas de ferramentas: ícones 2D de batom, pincel, paleta de sombra, delineador, máscara e esponja, com paleta rosa, creme e dourado.
3. Atlas de cores: seis amostras circulares em grade 3 × 2, com três cores de batom e três de sombra.
3a. Atlas de acabamentos: seis texturas neutras em grade 3 × 2 para colorização por shader: matte, cetim, perolado, glitter, metálico e gloss.
3b. Atlas de delineadores: seis pares simétricos em grade 3 × 2 sobre chroma técnico, posteriormente convertido para PNG RGBA.
3c. Atlas de cílios: quatro pares simétricos em grade 2 × 2 sobre chroma técnico, posteriormente convertido para PNG RGBA.
3d. Atlas de iluminador: quatro texturas neutras em grade 2 × 2, pensadas para colorização por shader.
4. Fundo de gala: cenário 2D em retrato com cortinas, flores, luzes douradas e área central livre para a modelo.
4a. Fundo cotidiano: estúdio de beleza claro, com plantas e espelho nas bordas e área central livre para a modelo.
4b. Fundo de festival: cenário 2D em retrato ao pôr do sol, com palco, luzes, fitas, confetes e área central livre para a modelo.
4c. Fundo de fantasia: jardim encantado noturno em tons de lavanda, com flores luminosas, folhas de cristal, lua crescente e área central livre para a modelo.
4d. Fundo editorial urbano: rooftop ao entardecer, skyline suave, painéis geométricos, refletores nas bordas e área central livre para a modelo.
4e. Fundo romântico: jardim matinal em tons creme e rosa, arco floral distante, tecidos e flores nas bordas e área central livre para a modelo.
5. Atlas de acessórios: seis acessórios elegantes em grade 3 × 2, pensados para a etapa de finalização.
5a. Segundo atlas de acessórios: seis itens adicionais em grade 3 × 2, completando os 12 acessórios do MVP.
5b. Sprites individuais de acessórios: fatiamento determinístico dos dois atlases e transparência estimada a partir do fundo de cada célula; não houve uma nova geração de imagem.
6. Folha de VFX: sequência 4 × 4 de brilho rosa-dourado em fundo preto para composição aditiva.
7. Overlays piloto: composição RGBA derivada das máscaras da modelo 01, com cores de referência e suavização por região para base, blush, sombra e batom.
7a. Expansão dos overlays: o mesmo pacote RGBA foi adaptado às máscaras das modelos 02–04, usando cores de referência específicas sem inferir tom de pele como requisito de avaliação.
8. Expressões de sorriso: edição de cada rosto-base com alteração limitada à expressão, preservando identidade, pose, cabelo, fundo e iluminação.
9. Emblemas de desafio: atlas 3 × 2 com os temas diário, gala, festival, fantasia, editorial urbano e jardim romântico; os sprites individuais foram fatiados preservando o canal alfa de origem.
10. Controles de ação: atlas 3 × 2 de ícones de desfazer, refazer, comparação, apagar, confirmar e bloqueado, gerado sobre transparência e fatiado sem alteração do alfa.
11. Ferramentas cosméticas individuais: fatiamento determinístico do atlas original de duas colunas por três linhas, preservando o alfa e sem geração nova.
12. Amostras de cor individuais: fatiamento determinístico do atlas 3 × 2; os cards preservam o fundo opaco para uso em catálogo.
13. Texturas de acabamento individuais: fatiamento determinístico do atlas 3 × 2, preservando as texturas RGB para prévia e shader.
14. Estilos de olhos individuais: separação determinística dos pares de delineador e cílios em lados esquerdo/direito, mantendo as dimensões e o alfa do atlas-fonte.
15. Texturas individuais de iluminador: fatiamento do atlas 2 × 2 sem conversão de cor; devem ser restringidas por máscara própria.
16. Correção de cílios: os sprites genéricos foram convertidos em 16 overlays de canvas completo (quatro estilos por modelo). O estilo natural foi calibrado visualmente em todos os rostos; não use as máscaras `lash` originais, que são inválidas.

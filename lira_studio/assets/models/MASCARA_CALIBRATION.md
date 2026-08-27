# Calibração de cílios por modelo

Os sprites genéricos em `assets/cosmetics/mascara/items/` são fontes de arte e não devem ser compostos diretamente sobre os rostos. Cada rosto usa overlays completos e alinhados, um por estilo:

| Modelo | Overlay de runtime | Estilo | Estado |
| --- | --- | --- | --- |
| 01 | `model_01/makeup/mascara/model_01_mascara_<estilo>_overlay_v1.png` | 4 estilos | Natural validado; demais derivados da mesma âncora. |
| 02 | `model_02/makeup/mascara/model_02_mascara_<estilo>_overlay_v1.png` | 4 estilos | Natural validado; demais derivados da mesma âncora. |
| 03 | `model_03/makeup/mascara/model_03_mascara_<estilo>_overlay_v1.png` | 4 estilos | Natural validado; demais derivados da mesma âncora. |
| 04 | `model_04/makeup/mascara/model_04_mascara_<estilo>_overlay_v1.png` | 4 estilos | Natural validado; demais derivados da mesma âncora. |

Todos os overlays usam o canvas 1024 × 1536 do rosto correspondente e devem ser desenhados em `(0, 0)`, sem escala ou deslocamento adicional.

## Integração no jogo

`MakeupSession.apply_lashes()` procura primeiro o overlay do estilo e do modelo ativos. Assim, a seleção de cílios no HUD usa o arquivo calibrado e só recorre ao atlas genérico caso um overlay esteja ausente.

## Regra de implementação

- Use os overlays por modelo para `natural_defined`, `lengthening`, `volumizing` e `dramatic_fan`.
- Os três estilos mais intensos usam a âncora já aprovada do estilo natural; faça uma revisão artística final em aparelho para cada um antes de publicação.
- As máscaras `lash_l_mask.png` e `lash_r_mask.png` originais são protótipos inválidos (estão preenchidas); não as use para recortar os cílios. O overlay calibrado já traz o alfa correto.
- O script `tools/build_mascara_overlays.ps1` reproduz os quatro overlays se for necessário ajustar a arte-fonte.

# Texturas de acabamento

Os arquivos de `finishes/` foram extraídos do atlas `atlas/cosmetic_finish_texture_atlas_v1.png`. São texturas RGB opacas de 512 × 512 px para uso em shader ou como prévias de catálogo; a cor vem do cosmético selecionado e não da textura.

| ID sugerido | Arquivo | Uso visual |
| --- | --- | --- |
| `finish_matte` | `finishes/finish_matte_card_v1.png` | Sem brilho especular. |
| `finish_satin` | `finishes/finish_satin_card_v1.png` | Brilho suave e uniforme. |
| `finish_pearl` | `finishes/finish_pearl_card_v1.png` | Reflexo perolado discreto. |
| `finish_glitter` | `finishes/finish_glitter_card_v1.png` | Partículas pontuais; moderar opacidade. |
| `finish_metallic` | `finishes/finish_metallic_card_v1.png` | Reflexo mais intenso e direcional. |
| `finish_gloss` | `finishes/finish_gloss_card_v1.png` | Brilho úmido concentrado. |

Use-as com mapeamento UV local à máscara de olhos ou lábios. Evite aplicá-las sobre o canvas inteiro: recorte por máscara antes de combinar com a cor-base.

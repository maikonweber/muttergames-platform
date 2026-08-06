# Ferramentas — Beat Up

| Ferramenta | Path | Status |
|---|---|---|
| Creative Tools (monorepo) | `scripts/mutter-creative.sh` | Preferir para packs novos |
| OpenRouter Image | `scripts/openrouter-image.sh` | Opcional |
| Meshy helper | `services/meshy/` | Opcional; ver README do serviço |
| Sheet slicer | `tools/slice_spritesheet.py` | **Legado** — paths absolutos hardcoded |

## Slicer legado

`slice_spritesheet.py` assume paths fora do monorepo. Antes de reusar:

1. Atualizar `SHEET` e `OUT_DIR` para paths relativos ao projeto, ou  
2. Migrar o fluxo para `mutter-creative.sh sheet` / `cutout`.

Catálogo: `Ecosystem/tools/01-tools-catalog.md` (TOOL-10).

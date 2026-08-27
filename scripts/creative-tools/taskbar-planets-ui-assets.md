# TaskBar Planets — pack UI / planetas / VFX (2D)

Gera e instala assets **raster offline** para o protótipo Godot, alinhados a
`TaskBarPlanetsForger/docs/design-system.md`.

## Scripts

| Comando | Função |
|---|---|
| `scripts/taskbar-planets-ui-assets.sh init` | Pastas + `PROMPTS.md` + `catalog.json` |
| `… prompts` | Imprime prompts do manifesto |
| `… install --from-dir DIR` | Normaliza e copia PNGs para o jogo |
| `… catalog` | Reescreve `catalog.json` |
| `… doctor` | Lista presentes / faltantes |

Saída:

```text
TaskBarPlanetsForger/task-bar-planet-forger/assets/generated/
  planets/   # globos e props
  vfx/       # forja, terraform, vida, supernova
  ui/        # painéis, botões, barras, ícones
  catalog.json
  PROMPTS.md
```

## Contrato visual

- Fundo **magenta `#FF00FF`** (shader `chroma_key.gdshader`)
- Sem texto nos sprites
- Estilo: oficina cósmica, navy profundo, ciano / ouro solar
- Planetas: esfera centrada, legível em 64–96 px no mapa orbital

## Fluxo com Imagine (Grok)

1. `init`
2. Gerar imagens com os prompts de `PROMPTS.md` (ou peça ao agente)
3. `install --from-dir <pasta das imagens>`
4. Abrir o Godot — `PlanetVisualCatalog` e VFX leem o catálogo

## Fluxo com OpenRouter (opcional)

```bash
scripts/openrouter-image.sh generate --prompt "..." --out tmp/tp-ui/planet-oceanic
# repetir / copiar PNGs para uma pasta
scripts/taskbar-planets-ui-assets.sh install --from-dir tmp/tp-ui
```

## Relação com Meshy

| Pack | Path | Uso |
|---|---|---|
| 2D UI/VFX/planetas | `assets/generated/` | Runtime HUD + fallbacks + VFX |
| 3D Meshy | `assets/meshy/` | Previews opcionais (`taskbar-planets-meshy-pack.sh`) |

O catálogo 2D tem prioridade nos arquétipos quando o arquivo existe; vida/civilização
continuam preferindo o procedural determinístico (seed lab).

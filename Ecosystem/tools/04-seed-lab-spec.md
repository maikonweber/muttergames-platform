# Spec — Seed Lab / Procedural Planet Tool (TOOL-03)

**Versão:** 1.0.0  
**Data:** 2026-08-05  
**Produto:** Taskbar Planets Forger  
**Cena:** `TaskBarPlanetsForger/task-bar-planet-forger/scenes/seed_lab.tscn`  
**Docs locais:** `TaskBarPlanetsForger/docs/procedural-sprite-tool.md`

## 1. Objetivo

Fornecer um laboratório in-engine para gerar sprites planetários **determinísticos**, inspecionar evolução visual e exportar PNGs reproduzíveis para o jogo e para packs compartilhados.

## 2. Não-objetivos

- Editor de tilesets genérico.
- Geração on-chain de NFT a partir do lab (MVP offline).
- Substituir Creative Tools para cutout/sheet/áudio.

## 3. Requisitos funcionais

| ID | Requisito | Aceite |
|---|---|---|
| SL-RF-01 | Abrir cena isolada com F6 | Lab roda sem precisar do loop idle completo |
| SL-RF-02 | Gerar nova seed | Seed copiável |
| SL-RF-03 | Escolher arquétipo e ajustar Atmosfera/Água | Preview atualiza |
| SL-RF-04 | Avançar evolução Habitável → Vida → Civilização | Estados visuais distintos |
| SL-RF-05 | Exportar PNG 512px | Arquivo em `user://generated_planets` |
| SL-RF-06 | Persistir identidade visual no save do jogo | `visual_seed` + `generator_version` |

## 4. Contrato de reprodução

```text
appearance = f(
  visual_seed,
  generator_version,
  tipo,
  atmosfera,
  água,
  vida,
  civilização
)
```

| Campo | Obrigatório | Nota |
|---|---|---|
| `visual_seed` | sim | Persistido em `Planet` |
| `generator_version` | sim | Quebra visual exige bump |
| tipo / atmosfera / água / vida / civilização | sim | Inputs de domínio do GDD |

Implementação: `scripts/procedural_planet_generator.gd`.

## 5. Requisitos não funcionais

| ID | Meta |
|---|---|
| SL-RNF-01 | Mesma seed+versão+params ⇒ mesmo PNG (bit-stable o quanto o raster permitir) |
| SL-RNF-02 | Export ≤ poucos segundos em máquina de desenvolvimento |
| SL-RNF-03 | Sem dependência de rede |
| SL-RNF-04 | UI legível em 1280×720+ |

## 6. Integração com Creative Tools

Fluxo recomendado após export:

```bash
# 1. Copiar PNG de user://generated_planets para o workspace
# 2. Normalizar / recortar se necessário
scripts/mutter-creative.sh crop planet.png assets/planets/planet-oceanic.png 512x512 center
scripts/mutter-creative.sh cutout assets/planets/planet-oceanic.png assets/planets/planet-oceanic.png '#ff00ff'
scripts/mutter-creative.sh manifest assets assets/manifest.json
scripts/mutter-creative.sh validate assets
```

## 7. Critérios de aceite

1. Duas execuções com a mesma seed e params produzem visual equivalente.  
2. Export aparece listado/recuperável no lab.  
3. Planeta forjado no jogo mantém aparência após reload do save.  
4. Bump de `generator_version` é documentado quando o algoritmo muda.

## 8. Evolução

| Item | Prioridade |
|---|---|
| Batch export de N seeds | P2 |
| Metadata JSON ao lado do PNG (seed, versão, params) | P1 |
| Hook CLI headless Godot para CI visual | P2 |
| Presets de arquétipo versionados em `data/` | P1 |

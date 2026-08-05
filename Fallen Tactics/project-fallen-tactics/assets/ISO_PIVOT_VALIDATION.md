# Validação de pivot — Iso 2:1 (primeiro lote)

**Data:** 2026-08-01  

## Assets gerados

| Arquivo | Spec | Status |
|---------|------|--------|
| `tiles/combat/grass_01.png` | Diamante **128×64** | OK |
| `tiles/combat/grass_02.png` | Variante grama | OK |
| `tiles/combat/stone_01.png` | Pedra arena 128×64 | OK |
| `units/espadachim/espadachim_idle_se.png` | Idle SE 128×128 | OK |
| `units/espadachim/espadachim_idle_sw.png` | Idle SW 128×128 | OK |
| `units/espadachim/espadachim_attack_slash_se.png` | Attack slash SE | OK |
| `_preview_iso_pivot.png` / `_preview_idle_sw.png` / `_preview_attack_slash_se.png` | Previews | OK |
| Cena Godot | `scenes/dev/iso_asset_preview.tscn` | OK |

## Checklist de pivot

- [x] Tile é diamante 2:1 (não quadrado)  
- [x] Vários tiles encaixam em flor isométrica  
- [x] Pés do herói alinham com o **centro** do diamante (cruz amarela no preview)  
- [x] Fundo do sprite transparente (sem checkerboard)  
- [x] Sombra achatada sob os pés  

## Ferramenta

```text
python tools/process_iso_assets.py
```

Reprocessa fontes da sessão Imagine → PNGs do projeto.

## Próximos assets (mesma pipeline)

1. `espadachim_idle_sw.png` (espelho ou desenho)  
2. `espadachim_attack_slash_se.png`  
3. `grass_02.png` / `grass_03.png` (variantes de textura)  
4. `stone_01.png`  

## Nota engine

**Migrado (2026-08-01):** combate principal usa iso 2:1.

| Peça | Arquivo |
|------|---------|
| Projeção | `scripts/combat/iso_math.gd` |
| Grid | `scripts/combat/grid_map.gd` |
| Unidades | `scripts/combat/unit.gd` (sprite + y-sort) |
| Cena | `scenes/combat/combat_scene.tscn` |
| Preview dev | `scenes/dev/iso_asset_preview.tscn` |

Lógica de células/path/cartas **não mudou** — só render e input.

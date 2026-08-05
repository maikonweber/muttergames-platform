# P1 Production Checklist — Vertical Slice Apresentável

**Fase de arte:** A1 / P1 (ver [`ASSETS_AND_ANIMATIONS.md`](ASSETS_AND_ANIMATIONS.md))  
**CSV rastreável:** [`P1_production_sheet.csv`](P1_production_sheet.csv)  
**Instruções detalhadas por asset:** [`ASSET_INSTRUCTIONS.md`](ASSET_INSTRUCTIONS.md)  
**Última atualização:** 2026-08-01  

Marque `[x]` quando o asset estiver **no repo e plugado no Godot**.  
Para **como desenhar/exportar** cada item, use sempre o `ASSET_INSTRUCTIONS.md`.

---

## Como usar

1. Produza na ordem das seções (unidades → tiles → cartas → VFX → UI → SFX).  
2. Valide cada sprite no grid real (zoom 1.0, tile 64).  
3. Atualize a coluna `status` no CSV: `todo` → `wip` → `done` → `ingame`.  
4. Placeholder engine (P0) **não** substitui linha do CSV de arte final — mas desbloqueia playtest.

---

## P0 — Engine placeholders (código)

| ID | Item | Status |
|----|------|--------|
| P0-01 | Outline ally/enemy | [x] engine 2026-08-01 |
| P0-02 | Silhuetas distintas por unidade | [x] engine 2026-08-01 |
| P0-03 | Facing legível | [x] engine 2026-08-01 |
| P0-04 | Ícone de postura | [x] engine 2026-08-01 |
| P0-05 | Floating damage / block / miss | [x] engine 2026-08-01 |
| P0-06 | Hit flash + knockback | [x] engine 2026-08-01 |
| P0-07 | Death fade | [x] engine 2026-08-01 |
| P0-08 | Tiles com padrão distinto | [x] engine 2026-08-01 |
| P0-09 | Active unit pulse | [x] engine 2026-08-01 |
| P0-10 | HP bar sob a unidade | [x] engine 2026-08-01 |

---

## P1 — Unidades (arte final)

### Espadachim (`espadachim`)

| Anim | Dirs | Frames | Status |
|------|------|--------|--------|
| idle | se/sw min · nw/ne ideal | 4–6 | [x] `idle_se` + `idle_sw` (ainda 1 frame cada) |
| idle_guard | E/W | 2–4 | [ ] |
| idle_offense | E/W | 2–4 | [ ] |
| move | E/W | 4–6 | [ ] |
| attack_slash | se/sw | 4–6 | [x] `attack_slash_se` (1 frame; sheet depois) |
| attack_thrust | E/W | 4–6 | [ ] |
| attack_charge | E/W | 4–6 | [ ] |
| parry | E/W | 3–4 | [ ] |
| hit | se/sw | 2–3 | [x] `hit_se` |
| death | se | 4–6 | [x] `death_se` |
| skill_finisher | E | 4–6 | [ ] |

### Goblin (`goblin`)

| Anim | Status |
|------|--------|
| idle / move / attack / hit / death | [x] `idle_se` (restante pendente) |

### Orc (`orc`)

| Anim | Status |
|------|--------|
| idle / move / attack / hit / death | [x] `idle_se` (restante pendente) |

### Arqueiro (`arqueiro`)

| Anim | Status |
|------|--------|
| idle / move / attack_ranged / hit / death | [x] `idle_se` (restante pendente) |

### Capitão (`capitao`)

| Anim | Status |
|------|--------|
| idle / move / attack / hit / death | [x] `idle_se` (restante pendente) |
| phase_roar | [ ] |
| push_attack | [ ] |
| summon | [ ] |

---

## P1 — Tiles combat

| Tile | Variantes | Status |
|------|-----------|--------|
| grass | 3 | [x] `grass_01`, `grass_02` (falta 03) |
| stone | 2 | [x] `stone_01` (falta 02) |
| elevated | 2 | [x] `elevated_01` |
| water | 2 (+ shimmer opcional) | [x] `water_01` |
| wall | 2 | [x] `wall_01` |
| pit | 1–2 | [x] `pit_01` |

---

## P1 — Cartas

| Item | Status |
|------|--------|
| frame_attack | [ ] |
| frame_defense | [ ] |
| frame_movement | [ ] |
| frame_control | [ ] |
| frame_buff | [ ] |
| frame_debuff | [ ] |
| frame_special | [ ] |
| 16 ícones card_id (ver CSV) | [ ] |

---

## P1 — VFX

| ID | Status |
|----|--------|
| slash_arc | [ ] |
| thrust_line | [ ] |
| impact_hit | [ ] |
| impact_block | [ ] |
| parry_spark | [ ] |
| dust_move | [ ] |
| death_poof | [ ] |
| status_vulnerable | [ ] |
| status_marked_duel | [ ] |

---

## P1 — UI

| Item | Status |
|------|--------|
| end_turn button 9-slice | [ ] |
| energy pips | [ ] |
| hp bar style | [ ] |
| timeline pip ally/enemy/active | [ ] |
| stance icons 32px | [ ] |
| targeting cursors | [ ] |
| turn banner | [ ] |
| reward panel style | [ ] |

---

## P1 — SFX

| Evento | Status |
|--------|--------|
| ui_click | [ ] |
| card_play | [ ] |
| slash_hit | [ ] |
| block | [ ] |
| parry | [ ] |
| death | [ ] |
| boss_roar | [ ] |
| reward | [ ] |
| footstep (opcional) | [ ] |

---

## Critério de “P1 done”

- [ ] 5 unidades com set mínimo **ingame**  
- [ ] Tiles combat substituem draw flat (ou misturam)  
- [ ] Toda carta do starter+reward tem ícone  
- [ ] Hit/block/death têm VFX+SFX  
- [ ] Playtest: “dá pra ler o combate sem o log”  

---

## Notas de pipeline

**Perspectiva travada: isométrico 2:1.**

| Item | Spec |
|------|------|
| Tile combat | Diamante **128×64** (ou 64×32) |
| Unidade | Canvas 96–128; pivot nos pés no centro do diamante |
| Dirs de arquivo | `se` `sw` `nw` `ne` (não n/e/s/w ortogonal) |
| UI / cartas | Ortogonais (não iso) |

```text
assets/units/{id}/{id}_{anim}_{dir}.png   # dir = se|sw|nw|ne
assets/tiles/combat/{type}_{variant}.png  # diamante 128x64
assets/cards/icons/{card_id}.png
assets/cards/frames/frame_{type}.png
assets/vfx/{id}_sheet.png
assets/ui/{name}_{state}.png
assets/audio/sfx/{name}.wav
```

Import Godot: Filter nearest se pixel art; linear se painted soft.  
Detalhes e prompts: [`ASSET_INSTRUCTIONS.md`](ASSET_INSTRUCTIONS.md).

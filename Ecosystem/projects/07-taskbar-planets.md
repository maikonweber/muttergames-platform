# PRJ-07 — Taskbar Planets Forger

**Pasta:** `TaskBarPlanetsForger/`  
**Protótipo:** `task-bar-planet-forger/`  
**Engine:** Godot 4.7  
**Status:** Vertical slice jogável (offline, Windows-first) · **MVP gate (M0) pendente**  
**Owner:** Produto / Eng Taskbar Planets  
**Estado vivo:** [`../../TaskBarPlanetsForger/docs/current-state.md`](../../TaskBarPlanetsForger/docs/current-state.md)

## 1. High concept

Idle discreto na barra de tarefas: **um planeta por capítulo** — forjar, terraformar, evoluir vida/civilização, sobreviver a meteoros, reconstruir, supernova (Essência + memórias). Conta/blockchain **fora** do MVP.

## 2. Estado técnico

- Compacto (idle bar) + expandido com abas **Sistema / Missão / Memórias**.
- Loop single-planet: integridade, eras, missão rebuild 3 etapas, capítulos, `MemoryBank`.
- Save JSON local (checksum, backup, soft recovery).
- Seed Lab: `scenes/seed_lab.tscn`.
- Pack 2D: `assets/generated/` · Meshy opcional: `assets/meshy/`.
- Áudio procedural; tutorial não bloqueante; bandeja Windows.

## 3. Requisitos (ponte)

Fonte completa: `TaskBarPlanetsForger/docs/` (SRS, RF/RNF, ADRs). Preferir **current-state + GDD** sobre RF legados que ainda mencionem “três órbitas”.

| ID | Nota |
|---|---|
| TP-RF-* | Ver `docs/functional-requirements.md` (migrar linguagem multi-órbita quando tocados) |
| TP-RNF-* | Ver `docs/non-functional-requirements.md` |
| Seed Lab | [`../tools/04-seed-lab-spec.md`](../tools/04-seed-lab-spec.md) |
| Roadmap | [`../../TaskBarPlanetsForger/docs/implementation-roadmap.md`](../../TaskBarPlanetsForger/docs/implementation-roadmap.md) |

## 4. Docs

- Índice: [`TaskBarPlanetsForger/docs/README.md`](../../TaskBarPlanetsForger/docs/README.md)
- Estado: [`current-state.md`](../../TaskBarPlanetsForger/docs/current-state.md)
- Protótipo: [`task-bar-planet-forger/README.md`](../../TaskBarPlanetsForger/task-bar-planet-forger/README.md)
- Integração futura: [`../game-integrations/taskbar-planets-forger.md`](../game-integrations/taskbar-planets-forger.md)

## 5. Como rodar

```text
Godot --path "TaskBarPlanetsForger/task-bar-planet-forger"
```

## 6. Critérios MVP

1. Loop offline completo (forja → civ → meteoro → rebuild → supernova) com save/reload.  
2. Compacto + expandido + bandeja no Windows; abas legíveis.  
3. Seed Lab exporta PNG com `visual_seed` + `generator_version`.  
4. Sem dependência de API/blockchain para jogar.  
5. Gate M0: smoke + DPI + 2 monitores (ver implementation-roadmap).

## 7. Próximo no roadmap

**M0** — VS gate (playtest/DPI/monitores) → **M1** — export Windows e polish de alpha. MutterGames só em **M4**.

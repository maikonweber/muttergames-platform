# PRJ-07 — Taskbar Planets Forger

**Pasta:** `TaskBarPlanetsForger/`  
**Protótipo:** `task-bar-planet-forger/`  
**Engine:** Godot 4.7  
**Status:** MVP jogável (offline, Windows-first)  
**Owner:** Produto / Eng Taskbar Planets

## 1. High concept

Idle discreto na barra de tarefas: forje planetas, terraform, evolua vida/civilização, supernova para prestígio. Conta/blockchain **fora** do MVP.

## 2. Estado técnico (MVP)

- Modos compacto (barra) e expandido; bandeja Windows; save JSON local.
- Órbitas, asteroides, forja, terraform, vida, civilização, eventos cósmicos.
- Seed Lab: `scenes/seed_lab.tscn` — sprites determinísticos.
- Áudio procedural; tutorial não bloqueante.

## 3. Requisitos (ponte)

Fonte completa: `TaskBarPlanetsForger/docs/` (SRS, RF/RNF, ADRs). Specs Ecosystem apontam; não duplicam o SRS.

| ID | Nota |
|---|---|
| TP-RF-* | Ver `docs/functional-requirements.md` |
| TP-RNF-* | Ver `docs/non-functional-requirements.md` |
| Seed Lab | [`../tools/04-seed-lab-spec.md`](../tools/04-seed-lab-spec.md) |

## 4. Docs

- Índice: [`TaskBarPlanetsForger/docs/README.md`](../../TaskBarPlanetsForger/docs/README.md)
- Protótipo: [`task-bar-planet-forger/README.md`](../../TaskBarPlanetsForger/task-bar-planet-forger/README.md)
- Integração futura: [`../game-integrations/taskbar-planets-forger.md`](../game-integrations/taskbar-planets-forger.md)

## 5. Como rodar

```text
Godot --path "TaskBarPlanetsForger/task-bar-planet-forger"
```

## 6. Critérios MVP

1. Loop idle completo offline com save/reload.  
2. Compacto + expandido + bandeja funcionam no Windows.  
3. Seed Lab exporta PNG reproduzível com `visual_seed` + `generator_version`.  
4. Sem dependência de API/blockchain para jogar.

# Mapa de scripts

Godot 4.x / GDScript. Começar pelos P0. Caminhos propostos.

## Dependências

```text
JSON / Resources
        │
 NarrativeManager ── RelationshipSystem
        │            EvidenceSystem
        │            RandomEventSystem
        │
 GameState ── SaveManager
        │
 UIManager ── DialogueView, MapView, PhoneView, InvestigationView
        │
 AudioManager    Analytics (P2)
```

## P0 — diálogo jogável

| Arquivo | Classe | Responsabilidade | Depende de | Aceite |
| --- | --- | --- | --- | --- |
| `scripts/data/narrative_node.gd` | `NarrativeNode` | Resource espelhando o JSON | schema | Um nó deserializa. |
| `scripts/narrative/narrative_manager.gd` | `NarrativeManager` | Resolve condições, efeitos, `next` | `GameState` | Escolha troca de nó. |
| `scripts/narrative/condition_eval.gd` | `ConditionEval` | `flag`, `affinity`, `trust`, `evidence`, `episode` | `GameState` | Condição falsa esconde escolha. |
| `scripts/relationship/relationship_system.gd` | `RelationshipSystem` | Clamp 0–100; deltas | `GameState` | 100 não estoura. |
| `scripts/evidence/evidence_system.gd` | `EvidenceSystem` | Coletar e combinar | `GameState` | Combo conhecido vs desconhecido. |
| `scripts/save/save_manager.gd` | `SaveManager` | Autosave versionado | `GameState` | Roundtrip do slice. |
| `scripts/app/game_state.gd` | `GameState` | Autoload | — | Estado atravessa cenas. |
| `scripts/ui/dialogue_view.gd` | `DialogueView` | Retrato, texto, escolhas, histórico | `NarrativeManager` | 4 botões no máximo. |
| `scripts/ui/ui_manager.gd` | `UIManager` | Transições e camadas | — | Diálogo não vaza clique no mapa. |

## P1 — mapa, celular, eventos, episódios

| Arquivo | Classe | Responsabilidade | Depende de |
| --- | --- | --- | --- |
| `scripts/ui/map_view.gd` | `MapView` | Locais, pins, objetivo | `locations.json` |
| `scripts/events/random_event_system.gd` | `RandomEventSystem` | 1 evento por visita; seed | `GameState`, `events.json` |
| `scripts/ui/phone_view.gd` | `PhoneView` | Threads de mensagem | nós `phone_*` |
| `scripts/ui/investigation_view.gd` | `InvestigationView` | Cartas e combinação | `EvidenceSystem` |
| `scripts/ui/wardrobe_view.gd` | `WardrobeView` | Tags e preview | `GameState` |
| `scripts/narrative/token_sub.gd` | `TokenSub` | `{name}` e pronomes | perfil |
| `scripts/audio/audio_manager.gd` | `AudioManager` | Crossfade por campo `music` | — |

## P2

| Arquivo | Classe | Condição |
| --- | --- | --- |
| `scripts/analytics/analytics.gd` | `Analytics` | Consentimento e política |
| `scripts/save/cloud_sync.gd` | — | Fora do MVP |
| `scripts/monetization/store.gd` | — | Experiência central validada |

## Autoloads

| Script | Autoload | Motivo |
| --- | --- | --- |
| `GameState` | Sim | Atravessa cenas |
| `NarrativeManager` | Sim | Continuidade do grafo |
| `SaveManager` | Sim | Autosave em hooks |
| `RelationshipSystem` | Sim | Consultas da UI |
| `EvidenceSystem` | Sim | Painel e condições |
| `RandomEventSystem` | Sim | Mapa |
| `UIManager` | Opcional | Se a navegação for central |
| `DialogueView` | Não | Pertence à cena |

## Regras

- Nenhum script carrega fala por nome de arquivo; só por ID.
- `RandomEventSystem` recusa efeito `flag` cujo nome começa com prefixos críticos (`ep0*_crit_`, `ending_`, `route_lock_`).
- `NarrativeManager` não desenha; `DialogueView` não aplica delta de relação.
- Texto novo entra em JSON, não em constante GDScript.

# Especificação técnica

## Estrutura sugerida

```text
game-narrativo/
  conexoes/                    # projeto Godot (a criar)
    assets/
      portraits/
      backgrounds/
      cg/
      ui/
      vfx/
      wardrobe/
      audio/
    scenes/
      boot/
      dialogue/
      map/
      phone/
      investigation/
      wardrobe/
      ui/
    scripts/
      data/
      narrative/
      relationship/
      evidence/
      events/
      save/
      ui/
      audio/
    resources/
    tests/
  data/                       # conteúdo (este repo, já existente)
    schema/
    episodes/
    locations/
    events/
    characters/
  docs/
  personagens/
  narrativa/
```

Premissa: o Godot lê `res://../data` ou uma cópia importada em `conexoes/data`. IDs nunca dependem do texto.

## Componentes (GDD 13.1)

| Componente | Responsabilidade | Não deve fazer |
| --- | --- | --- |
| `NarrativeManager` | Carregar nós, avaliar condições, aplicar efeitos, avançar | Renderizar UI ou gravar disco |
| `GameState` | Flags, atributos, inventário, rota, episódio, versão do save | Conhecer paths de sprite |
| `RelationshipSystem` | Aplicar/consultar afinidade e confiança | Decidir o próximo nó |
| `EvidenceSystem` | Pistas, combinações, hipóteses | Disparar diálogo |
| `RandomEventSystem` | Escolher no máximo 1 evento elegível por visita ao mapa | Setar flags `critical` ou evidências únicas do final verdadeiro |
| `SaveManager` | Autosave, slot, migração, integridade | Interpretar escolhas |
| `UIManager` | Diálogo, mapa, celular, guarda-roupa, transições | Mutar flags diretamente |
| `AudioManager` | Música, ambiência, vozes, volumes, crossfade | Conhecer o grafo narrativo |
| `Analytics` | Eventos anônimos consentidos | Guardar texto livre |

## Formato de nó

Campos mínimos do GDD 13.2. Schema: [`../data/schema/narrative-node.schema.json`](../data/schema/narrative-node.schema.json).

```json
{
  "id": "EP01_SC01_N001",
  "speaker": "narrator",
  "text": "O ônibus desce a serra. O mar aparece de lado, cinza e largo.",
  "expression": "idle",
  "location": "loc_terminal",
  "music": "mus_arrival",
  "conditions": [],
  "choices": [],
  "effects": [],
  "next": "EP01_SC01_N002",
  "tags": ["pt-BR", "ep01"]
}
```

Convenção de IDs: cena `EP01_SC03_N015`; escolha `EP01_SC03_C02`. Flags legíveis: `ep01_viu_foto_iris`, `confiou_noah_app`.

Tokens de texto: `{name}`, `{they}`, `{them}`, `{their}` — flexionados pelo perfil. Não concatenar gênero no ID.

## GameState mínimo

```gdscript
# conceito — não é o arquivo final
episode: String
node_id: String
flags: Dictionary # String -> Variant
affinity: Dictionary # character_id -> int
trust: Dictionary
courage: int
evidence_ids: Array[String]
hypotheses: Array[String]
wardrobe_equipped: Dictionary
pronouns: Dictionary
player_name: String
save_version: int
rng_seed: int
day_index: int
```

## Save

- Autosave a cada troca de cena e antes de escolha crítica.
- MVP: 1 slot local. Completo: 3 manuais + autosave.
- `save_version` sobe quando o schema muda; `SaveManager` migra.
- Resumo por episódio: personagem mais próximo, pista-chave, coragem, prévia sem spoiler.

## Privacidade

Coletar só o necessário, com consentimento. Analytics não armazena texto livre. Conta, progresso e telemetria separados. LGPD antes de loja.

## Desempenho

60 FPS na UI. Boot < 5 s em intermediário. Texturas comprimidas. 16:9 + áreas seguras. Android 10+ até o teste de aparelhos fechar o mínimo.

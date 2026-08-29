# Dados jogáveis

Conteúdo que o Godot carrega. IDs estáveis. Texto em pt-BR.

| Arquivo | Uso |
| --- | --- |
| [schema/narrative-node.schema.json](schema/narrative-node.schema.json) | Contrato de nó |
| [schema/random-event.schema.json](schema/random-event.schema.json) | Contrato de evento de mapa |
| [locations/locations.json](locations/locations.json) | 12 locais do MVP |
| [events/campus-day.json](events/campus-day.json) | Tabela aleatória |
| [episodes/ep01/nodes.json](episodes/ep01/nodes.json) | Episódio 1 |

Validar JSON contra o schema antes do merge. O `NarrativeManager` não lê markdown.

```text
python game-narrativo/data/validate.py
```

Confere `next` órfão, teto de 4 escolhas e a denylist de eventos aleatórios.

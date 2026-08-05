# Laboratório de Seeds e Evolução

O projeto possui uma ferramenta Godot para criar sprites planetários determinísticos e verificar sua evolução visual.

## Como usar

1. Abra `task-bar-planet-forger/project.godot` no Godot 4.7+.
2. No painel **FileSystem**, abra `scenes/seed_lab.tscn`.
3. Execute a cena com `F6`.
4. Gere uma nova seed, escolha o arquétipo e ajuste Atmosfera/Água.
5. Use **Avançar evolução** para percorrer Habitável → Vida → Civilização.
6. Copie a seed ou exporte um PNG de 512 px.

Os PNGs exportados são gravados em `user://generated_planets`, que será exibido pela própria ferramenta após a exportação.

## Contrato de reprodução

A aparência é obtida de:

```text
visual_seed + generator_version + tipo + atmosfera + água + vida + civilização
```

`Planet.visual_seed` e `Planet.generator_version` são persistidos no save. Dessa forma, um planeta forjado mantém a mesma identidade visual ao recarregar a partida. O rasterizador está em `scripts/procedural_planet_generator.gd`.

# MutterGames Game Kit

**Spec formal:** [`Ecosystem/tools/09-gamekit-spec.md`](../../Ecosystem/tools/09-gamekit-spec.md)

`scripts/mutter-gamekit.sh` cria estruturas consistentes para dados, Godot, localização, releases e game design. Ele usa apenas Bash e `awk`.

## Exemplos

```bash
# Dados versionáveis
scripts/mutter-gamekit.sh data quest data/quests/first-orbit.json
scripts/mutter-gamekit.sh data resource data/resources/energy.json

# Localização e verificação
scripts/mutter-gamekit.sh locale locales/ui.csv pt-BR,en-US,es-ES
scripts/mutter-gamekit.sh locale-check locales/ui.csv

# Componentes Godot reutilizáveis
scripts/mutter-gamekit.sh component health scripts/components/health_component.gd
scripts/mutter-gamekit.sh component state-machine scripts/components/state_machine_component.gd

# Planejamento de produção
scripts/mutter-gamekit.sh loop "TaskBar Planets Forger" docs/game-loop-canvas.md
scripts/mutter-gamekit.sh release-notes 0.2.0 docs/releases/0.2.0.md
```

## Limites

- Schemas são pontos de partida; valide regras de negócio no jogo.
- O CSV simples não suporta vírgulas dentro do texto. Para diálogos longos, use chave de localização e conteúdo em arquivos dedicados.
- Os componentes são neutros e não assumem a arquitetura de um jogo; conecte sinais e persistência no nível apropriado.

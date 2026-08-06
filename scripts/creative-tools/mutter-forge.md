# Mutter Forge CLI

`scripts/mutter-forge.sh` é a porta de entrada para ferramentas de criação 2D, 3D, áudio, texto e IA da MutterGames.

## Exemplos

```bash
# Diagnóstico do ambiente
scripts/mutter-forge.sh doctor

# 2D e Godot
scripts/mutter-forge.sh 2d vfx forge assets/vfx/forge 256 12
scripts/mutter-forge.sh game component health scripts/components/health.gd

# 3D: exporta GLB low-poly via Blender em modo background
scripts/mutter-forge.sh 3d primitive sphere planet assets/3d/planet.glb 2EAFD7
scripts/mutter-forge.sh 3d render scenes/planet.blend outputs/planet.png 1

# IA OpenRouter
scripts/mutter-forge.sh ai-image generate --model <modelo> --prompt "..." --out assets/generated/item
scripts/mutter-forge.sh ai-game text --model <modelo> --kind lore --prompt "..." --out docs/lore.md
```

Defina `BLENDER_BIN` se o executável do Blender não estiver no `PATH`; para IA, configure `OPEN_ROUTER` no ambiente.

## MCP local

```bash
scripts/mutter-forge.sh mcp init .vscode/mcp.json
```

O comando escreve uma configuração `stdio` que inicia `tools/mutter-forge-mcp.mjs`. O servidor disponibiliza ferramentas 2D, game, 3D e IA. Ele recebe argumentos em arrays e usa `spawn` sem shell, reduzindo risco de injeção. Revise o `mcp.json` gerado antes de habilitá-lo, especialmente se o cliente MCP compartilhar permissões de arquivos ou `OPEN_ROUTER`.

## Limites

- O primitive cria formas base para prototipagem, não substitui modelagem/retopologia/art direction.
- O servidor MCP exige Node.js e Bash; o Blender só é chamado para operações 3D.
- Use modelos e parâmetros de OpenRouter após consultar as capacidades atuais; transparência, seed e referências dependem do endpoint escolhido.

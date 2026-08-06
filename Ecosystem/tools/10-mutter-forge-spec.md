# TOOL-13 — Mutter Forge

**Entrada:** `scripts/mutter-forge.sh`  
**Guia:** `scripts/creative-tools/mutter-forge.md`  
**Status:** Produção interna

## Objetivo

Uma CLI única para orquestrar ferramentas 2D, 3D, Blender, OpenRouter e scaffolds de jogo, com um servidor MCP `stdio` local para uso por clientes compatíveis.

## Comandos

| Grupo | Operações |
|---|---|
| `2d` | Delega para Creative Tools: VFX, spritesheet, SFX, música e recorte. |
| `game` | Delega para Game Kit: schemas, localização, componentes e releases. |
| `ai-image` / `ai-game` | Delega para os adaptadores OpenRouter. |
| `3d primitive` | Cria primitive low-poly e exporta GLB via Blender em background. |
| `3d render` | Renderiza frame de `.blend` sem abrir UI. |
| `mcp init` | Gera arquivo de configuração do servidor MCP local. |

## Dependências e segurança

- Obrigatórias: Bash; Node.js apenas para o servidor MCP.
- Opcionais: Blender (`BLENDER_BIN`), ImageMagick, FFmpeg e `OPEN_ROUTER`.
- O MCP passa argumentos por array para `spawn`, sem executar texto de shell arbitrário.
- Revise o `mcp.json` antes de conceder permissões de arquivos ou expor `OPEN_ROUTER` ao cliente.

## Critérios de aceite

- O comando `doctor` lista dependências e a presença (não o valor) de `OPEN_ROUTER`.
- `3d primitive` gera um GLB de cube, sphere ou cylinder com material simples.
- `mcp init` gera uma configuração `stdio` apontando para `tools/mutter-forge-mcp.mjs`.

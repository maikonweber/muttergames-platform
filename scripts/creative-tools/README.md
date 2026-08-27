# MutterGames Creative Tools

Kit Bash para acelerar a criação de assets em qualquer projeto do workspace. O ponto de entrada é:

```bash
scripts/mutter-creative.sh <comando>
```

**Spec formal (requisitos, contrato CLI, aceite e roadmap):**  
[`Ecosystem/tools/02-creative-tools-spec.md`](../../Ecosystem/tools/02-creative-tools-spec.md)

**Catálogo de todas as ferramentas do monorepo:**  
[`Ecosystem/tools/README.md`](../../Ecosystem/tools/README.md)

## Dependências

| Recurso | Dependência | Funções |
|---|---|---|
| Imagem | ImageMagick 7 (`magick`) | `crop`, `cutout`, `sheet`, `vfx` |
| Áudio | FFmpeg (`ffmpeg`) | `sfx`, `music` |
| Brief de IA | nenhuma | `prompt` |
| Geração de imagem (opcional) | OpenRouter + `curl`/`jq` | `scripts/openrouter-image.sh` — [guia](openrouter-image.md) · [spec](../../Ecosystem/tools/06-openrouter-image-spec.md) |
| Geração 3D (opcional) | Meshy + `curl`/`jq` | `scripts/meshy-asset.sh` — [guia](meshy-asset.md) · [spec](../../Ecosystem/tools/11-meshy-asset-spec.md) |
| Texto / voz (opcional) | OpenRouter | `scripts/openrouter-game.sh` — [guia](openrouter-game.md) · [spec](../../Ecosystem/tools/08-openrouter-game-spec.md) |
| Scaffolds de jogo | Bash apenas | `scripts/mutter-gamekit.sh` — [guia](gamekit.md) · [spec](../../Ecosystem/tools/09-gamekit-spec.md) |

No Windows, execute via WSL ou Git Bash. No Ubuntu/WSL:

```bash
sudo apt update
sudo apt install imagemagick ffmpeg
```

Verifique o ambiente:

```bash
scripts/mutter-creative.sh doctor
```

## Fluxo de trabalho rápido

```bash
# 1. Criar um brief que pode ser usado no gerador de imagens do Codex.
scripts/mutter-creative.sh prompt asset tmp/planet-brief.md "planeta oceânico com uma lua"

# 2. Remover o fundo magenta do PNG gerado.
scripts/mutter-creative.sh cutout tmp/planet-key.png assets/planets/planet-oceanic.png '#ff00ff'

# 3. Criar os frames e a spritesheet de uma forja.
scripts/mutter-creative.sh vfx forge assets/vfx/forge 256 12
scripts/mutter-creative.sh sheet assets/vfx/forge assets/vfx/forge-sheet.png 4

# 4. Criar áudio procedural.
scripts/mutter-creative.sh sfx forge assets/audio/forge.wav 0.6
scripts/mutter-creative.sh music ambient assets/music/space-loop.wav 24

# 5. Criar o recurso que o AnimatedSprite2D do Godot consome.
scripts/mutter-creative.sh spriteframes res://assets/vfx/forge-sheet.png assets/vfx/forge.tres 256 256 4 3 12

# 6. Catalogar e validar o pack antes do commit.
scripts/mutter-creative.sh manifest assets assets/manifest.json
scripts/mutter-creative.sh validate assets
```

## Comandos

- `crop`: normaliza qualquer imagem em uma dimensão final sem deformar o assunto.
- `cutout`: converte uma cor sólida de fundo em transparência de PNG. Use fundo `#FF00FF` para assets ciano/verdes.
- `sheet`: monta uma pasta de PNGs, ordenada pelo nome, em uma spritesheet.
- `vfx`: cria sequências PNG de `forge`, `nova` ou `collect`, que podem ser importadas no Godot como `SpriteFrames`.
- `sfx`: cria WAVs mono a 48 kHz para ações rápidas.
- `music`: cria loops WAV simples de ambientação. Eles são pontos de partida procedurais, não substituem composição musical final.
- `prompt`: cria um brief padronizado para geração assistida por IA. A geração visual pode ser feita diretamente no Codex; depois use `cutout` e `sheet`.
- `spriteframes`: cria um `.tres` de `SpriteFrames` para um atlas PNG. Passe o caminho da textura como `res://` para que Godot resolva o recurso.
- `manifest`: gera um catálogo JSON simples de imagens, áudio e SVGs de um pack.
- `validate`: verifica se PNGs e arquivos WAV/OGG podem ser lidos e informa suas dimensões/dados técnicos.
- `scaffold`: gera pontos de partida Godot para HUD, pickup de recurso ou VFX de execução única.

Para geração de imagem via OpenRouter, use o adaptador separado [openrouter-image.md](openrouter-image.md). Ele exige `OPEN_ROUTER` e nunca deve receber uma chave gravada em arquivo.

Para geração 3D via Meshy (Text/Image → GLB), use [meshy-asset.md](meshy-asset.md). Exige `MESHY_API_KEY` (plano Pro+) e nunca deve receber a chave gravada em arquivo.

Para textos de jogo, briefs de imagem/VFX/SFX/música, vozes TTS e remoção de fundo, use [openrouter-game.md](openrouter-game.md).

Para dados, localização, componentes Godot e checklists de release, use [gamekit.md](gamekit.md).

## Convenções

- Coloque outputs temporários em `tmp/` e assets finais em `assets/` do jogo que os consome.
- Nomeie sequências como `frame-00.png`, `frame-01.png` etc.; `vfx` já segue esse padrão.
- Salve seed/prompt/versão do gerador junto ao asset quando ele for procedural.
- Antes de versionar, valide tamanho, alpha, loop de áudio e licença do material de origem.

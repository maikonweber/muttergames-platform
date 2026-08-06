# OpenRouter Game Tools

**Spec formal:** [`Ecosystem/tools/08-openrouter-game-spec.md`](../../Ecosystem/tools/08-openrouter-game-spec.md)

`scripts/openrouter-game.sh` cria conteúdo de jogo e vozes usando `OPEN_ROUTER`; a chave nunca é gravada pelo script.

```bash
export OPEN_ROUTER='…'
```

Requer Bash, `curl` e `jq`. Para remoção de fundo, requer ImageMagick.

| Comando | Entrega | Tecnologia |
|---|---|---|
| `text` | diálogos, quests, lore, itens e NPCs em Markdown | Chat Completions |
| `brief` | brief técnico para imagem, VFX, SFX ou música | Chat Completions |
| `voice` | fala/narração em MP3 ou PCM | OpenRouter TTS |
| `audio-models` | modelos de fala disponíveis | Models API |
| `remove-bg` | PNG com fundo sólido removido | ImageMagick local |

## Texto e história

```bash
scripts/openrouter-game.sh text \
  --model openai/gpt-5.2 --kind quest \
  --prompt "missão inicial de um idle espacial" \
  --out docs/quests/first-orbit.md --language pt-BR
```

O comando salva também `<arquivo>.meta.json` com modelo, id e uso retornados pela API.

## Imagem, VFX, SFX e música

```bash
scripts/openrouter-game.sh brief \
  --model openai/gpt-5.2 --kind vfx \
  --prompt "supernova curta e legível em 128 px, 12 frames" \
  --out tmp/supernova-brief.md
```

Use o brief com `openrouter-image.sh generate` para imagens e com `mutter-creative.sh vfx`, `sfx` e `music` para produção procedural local. OpenRouter oferece TTS dedicado; este kit não afirma que exista uma API dedicada de música/SFX generativos quando os endpoints documentados são de fala e transcrição.

## Voz

```bash
scripts/openrouter-game.sh audio-models tmp/tts-models.json
scripts/openrouter-game.sh voice \
  --model openai/gpt-4o-mini-tts-2025-12-15 --voice nova \
  --text "Vida floresceu em Terra-02." --out assets/audio/life.mp3
```

Vozes e formatos dependem do modelo. Consulte a descoberta de modelos antes de escolher um padrão.

## Fundo PNG

```bash
scripts/openrouter-game.sh remove-bg assets/source/planet-key.png assets/planets/planet.png '#ff00ff'
```

Para transparência nativa, use `openrouter-image.sh generate --background transparent --format png` se o modelo escolhido suportar esses parâmetros.

O kit usa `POST /api/v1/chat/completions` para texto, `POST /api/v1/audio/speech` para fala e `GET /api/v1/models?output_modalities=speech` para descoberta. Consulte a documentação oficial de [TTS](https://openrouter.ai/docs/guides/overview/multimodal/tts), [Áudio](https://openrouter.ai/docs/guides/overview/multimodal/audio) e [Image Generation](https://openrouter.ai/docs/guides/overview/multimodal/image-generation).

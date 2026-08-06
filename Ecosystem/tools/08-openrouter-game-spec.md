# Spec — OpenRouter Game Tools (TOOL-11)

**Versão:** 1.0.0  
**Data:** 2026-08-05  
**Implementação:** `scripts/openrouter-game.sh`  
**Guia:** `scripts/creative-tools/openrouter-game.md`

## 1. Objetivo

Gerar conteúdo textual de jogo (quests, lore, diálogos), briefs técnicos e voz TTS via OpenRouter, sem persistir a chave no repositório.

## 2. Variável de ambiente

Usa `OPEN_ROUTER` (sessão). Não gravar em `.env` versionado.

> Nota: o adaptador de imagens (`openrouter-image.sh`) usa `OPENROUTER_API_KEY`. Manter as duas documentadas até unificação.

## 3. Requisitos

| ID | Requisito | Aceite |
|---|---|---|
| OG-RF-01 | `text` gera Markdown + `.meta.json` | Arquivos no path pedido |
| OG-RF-02 | `brief` gera brief para asset/vfx/sfx/music | Integrável com creative/image |
| OG-RF-03 | `voice` gera áudio TTS | MP3/PCM conforme modelo |
| OG-RF-04 | `audio-models` lista modelos de fala | JSON |
| OG-RF-05 | `remove-bg` remove cor sólida | Depende ImageMagick |
| OG-SEC-01 | Chave só em env de sessão | Sem log da chave |

## 4. Fluxo

```text
openrouter-game brief → openrouter-image generate → mutter-creative cutout/sheet
openrouter-game text  → dados do jogo / docs
openrouter-game voice → assets/audio
```

## 5. Critérios de aceite

1. Sem chave → erro claro.  
2. `text` e `brief` escrevem meta ao lado do output.  
3. Guia e script listam os mesmos comandos.

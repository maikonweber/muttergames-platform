# OpenRouter Image Tools

**Spec formal:** [`Ecosystem/tools/06-openrouter-image-spec.md`](../../Ecosystem/tools/06-openrouter-image-spec.md)

`scripts/openrouter-image.sh` é o adaptador de geração de imagem do kit MutterGames. Ele usa a API dedicada de imagens da OpenRouter, consulta modelos disponíveis e grava a resposta base64 como arquivos de asset locais.

## Pré-requisitos

- Bash (WSL, Git Bash ou Linux);
- `curl`, `jq` e `base64`;
- uma chave OpenRouter definida somente na sessão atual, em `OPEN_ROUTER`.

```bash
export OPEN_ROUTER='…'
scripts/openrouter-image.sh models tmp/openrouter-image-models.json
```

Nunca inclua a chave em `README`, `.env` versionado ou comando compartilhado. O script prioriza `OPEN_ROUTER` e aceita `OPENROUTER_API_KEY` somente como compatibilidade temporária. Os modelos e os parâmetros suportados mudam; consulte o endpoint de modelos antes de escolher `--size`, `--seed`, transparência ou múltiplas imagens.

## Gerar um asset

```bash
scripts/openrouter-image.sh generate \
  --model openai/gpt-image-2 \
  --prompt "2D game sprite: oceanic planet with a small moon, isolated, no text" \
  --out assets/planets/oceanic-428771 \
  --size 1K --aspect-ratio 1:1 --quality high \
  --format png --background transparent --seed 428771
```

O comando cria `oceanic-428771-01.png` e exibe os metadados de custo retornados pela API. Uma mesma seed só é determinística quando o modelo/end-point escolhido suporta `seed`; por isso o manifesto do projeto deve registrar modelo, prompt e parâmetros.

## Imagem de referência

Use `--reference` com URL pública ou arquivo local. Arquivos locais são enviados como `data:` URL e podem aumentar o custo/tamanho da requisição.

```bash
scripts/openrouter-image.sh generate \
  --model openai/gpt-image-2 \
  --prompt "preserve this planet silhouette; add early vegetation" \
  --reference assets/planets/oceanic-428771-01.png \
  --out assets/planets/oceanic-life --format png --background transparent
```

Em seguida, use o pipeline compartilhado:

```bash
scripts/mutter-creative.sh crop assets/planets/oceanic-life-01.png assets/planets/oceanic-life.png 512x512 center
scripts/mutter-creative.sh manifest assets assets/manifest.json
scripts/mutter-creative.sh validate assets
```

## Contrato da API

O adaptador usa `POST /api/v1/images`, que requer `model` e `prompt`; a resposta contém `data[].b64_json` e pode informar `media_type`. A descoberta é feita por `GET /api/v1/images/models`. O código aceita `size`, `aspect_ratio`, `quality`, `output_format`, `background`, `seed`, `n` e `input_references`, mas cada modelo pode suportar somente uma parte deles. Consulte a documentação oficial de [Image Generation](https://openrouter.ai/docs/guides/overview/multimodal/image-generation) e [Model Discovery](https://openrouter.ai/docs/api/api-reference/images/list-image-models).

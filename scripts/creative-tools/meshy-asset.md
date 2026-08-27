# Meshy Asset Tools

**Spec formal:** [`Ecosystem/tools/11-meshy-asset-spec.md`](../../Ecosystem/tools/11-meshy-asset-spec.md)

`scripts/meshy-asset.sh` é o adaptador de geração de assets 3D via [Meshy API](https://docs.meshy.ai/en/api/quick-start). Cria tarefas Text-to-3D / Image-to-3D, faz polling até `SUCCEEDED` e baixa o modelo (GLB por padrão) para o disco.

Chave da API: [meshy.ai/settings/api](https://www.meshy.ai/pt-BR/settings/api) (plano Pro ou superior).

## Pré-requisitos

- Bash (WSL, Git Bash ou Linux);
- `curl`, `jq` e `base64`;
- `MESHY_API` (preferido no monorepo / `.env` local) ou alias `MESHY_API_KEY`, só na sessão / `.env` não versionado.

```bash
# carrega do .env local sem ecoar a chave
set -a; source .env; set +a
scripts/meshy-asset.sh balance
```

Nunca grave a chave em README ou comando compartilhado. Assets gerados pela API ficam no servidor Meshy por **3 dias** (planos não-Enterprise) — baixe e versionize localmente o que importar.

## Text → 3D

Fluxo oficial em dois passos: **preview** (malha) + **refine** (textura). O script faz os dois por padrão.

```bash
scripts/meshy-asset.sh text-to-3d \
  --prompt "low-poly crystal sword, stylized fantasy game asset" \
  --out tmp/assets/crystal-sword \
  --model-type lowpoly \
  --ai-model latest \
  --format glb \
  --meta
```

Saídas típicas: `tmp/assets/crystal-sword.glb` e `tmp/assets/crystal-sword.meta.json`.

Só a malha (sem textura / sem refine):

```bash
scripts/meshy-asset.sh text-to-3d \
  --prompt "simple wooden crate" \
  --out tmp/assets/crate-preview \
  --preview-only
```

## Image → 3D

Aceita URL pública ou arquivo local (enviado como data URI).

```bash
scripts/meshy-asset.sh image-to-3d \
  --image assets/concepts/hero-front.png \
  --out tmp/assets/hero \
  --format glb \
  --pbr \
  --meta
```

## Status e download manuais

Útil com `--no-wait` ou para retomar uma tarefa:

```bash
scripts/meshy-asset.sh text-to-3d --prompt "…" --out tmp/x --no-wait
# → imprime { "id": "…", "mode": "preview", … }

scripts/meshy-asset.sh status --kind text --id <task_id>
scripts/meshy-asset.sh download --kind text --id <task_id> --out tmp/x.glb
```

Para Image-to-3D use `--kind image`.

## Via Mutter Forge

```bash
scripts/mutter-forge.sh meshy balance
scripts/mutter-forge.sh meshy text-to-3d --prompt "…" --out tmp/assets/item --meta
```

## Contrato da API

| Operação | Endpoint |
|---|---|
| Balance | `GET /openapi/v1/balance` |
| Text-to-3D preview/refine | `POST /openapi/v2/text-to-3d` |
| Text-to-3D status | `GET /openapi/v2/text-to-3d/:id` |
| Image-to-3D | `POST /openapi/v1/image-to-3d` |
| Image-to-3D status | `GET /openapi/v1/image-to-3d/:id` |

Auth: `Authorization: Bearer $MESHY_API` (alias: `MESHY_API_KEY`).

Documentação: [Quickstart](https://docs.meshy.ai/en/api/quick-start), [Text to 3D](https://docs.meshy.ai/en/api/text-to-3d), [Image to 3D](https://docs.meshy.ai/en/api/image-to-3d).

## Pack Taskbar Planets

```bash
set -a; source .env; set +a
scripts/taskbar-planets-meshy-core.sh   # Oceanico, Rochoso, Vulcanico, asteroid, sun
# ou pack completo dos arquétipos do design system:
scripts/taskbar-planets-meshy-pack.sh
```

Saída: `TaskBarPlanetsForger/task-bar-planet-forger/assets/meshy/`.

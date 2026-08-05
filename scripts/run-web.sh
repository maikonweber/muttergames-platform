#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="${ROOT_DIR}/apps/web"

if [ ! -d "${WEB_DIR}" ]; then
  echo "Web nao encontrado em ${WEB_DIR}"
  exit 1
fi

if [ ! -d "${ROOT_DIR}/node_modules" ] && [ ! -d "${WEB_DIR}/node_modules" ]; then
  echo "Dependencias nao instaladas. Rode scripts/init-all.sh primeiro."
  exit 1
fi

cd "${ROOT_DIR}"
exec pnpm --filter @muttergames/web dev

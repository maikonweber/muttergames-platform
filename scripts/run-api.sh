#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_DIR="${ROOT_DIR}/apps/api"

if [ ! -d "${API_DIR}" ]; then
  echo "API nao encontrada em ${API_DIR}"
  exit 1
fi

if [ ! -d "${ROOT_DIR}/node_modules" ] && [ ! -d "${API_DIR}/node_modules" ]; then
  echo "Dependencias nao instaladas. Rode scripts/init-all.sh primeiro."
  exit 1
fi

cd "${ROOT_DIR}"
exec pnpm --filter @muttergames/api start:dev

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "MutterGames bootstrap"
echo "Root: ${ROOT_DIR}"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm nao encontrado."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker nao encontrado."
  exit 1
fi

if ! command -v solana >/dev/null 2>&1; then
  echo "solana-cli nao encontrado. A parte local da rede Solana sera ignorada."
fi

cd "${ROOT_DIR}"

if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
  echo "Arquivo .env criado a partir do .env.example"
fi

pnpm install
docker compose up -d postgres prometheus loki alloy grafana

echo "Bootstrap concluido."
echo "Use os scripts abaixo para iniciar os apps:"
echo "  scripts/run-solana-local.sh"
echo "  scripts/run-api.sh"
echo "  scripts/run-web.sh"

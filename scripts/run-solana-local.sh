#!/usr/bin/env bash
set -euo pipefail

PORT="${SOLANA_LOCAL_RPC_PORT:-8899}"
WS_PORT="${SOLANA_LOCAL_WS_PORT:-8900}"
FUNDING_WALLET="${SOLANA_FUNDING_WALLET:-}"

if ! command -v solana-test-validator >/dev/null 2>&1; then
  echo "solana-test-validator nao encontrado."
  echo "Instale o Solana CLI antes de rodar este script."
  exit 1
fi

echo "Configurando Solana para localhost:${PORT}"
solana config set --url "http://127.0.0.1:${PORT}" >/dev/null

if [ -n "${FUNDING_WALLET}" ] && command -v solana >/dev/null 2>&1; then
  echo "Carteira de funding informada em SOLANA_FUNDING_WALLET."
fi

echo "Iniciando solana-test-validator..."
echo "RPC: http://127.0.0.1:${PORT}"
echo "WS:  ws://127.0.0.1:${WS_PORT}"

exec solana-test-validator \
  --ledger ./.solana-ledger \
  --rpc-port "${PORT}" \
  --websocket-port "${WS_PORT}" \
  --reset

#!/usr/bin/env bash
# Pack 2D de UI + planetas + VFX do TaskBar Planets Forger.
# Wrapper do Python (Windows-friendly via python3).
#
# Uso:
#   scripts/taskbar-planets-ui-assets.sh init
#   scripts/taskbar-planets-ui-assets.sh prompts
#   scripts/taskbar-planets-ui-assets.sh install --from-dir path/to/images
#   scripts/taskbar-planets-ui-assets.sh catalog
#   scripts/taskbar-planets-ui-assets.sh doctor
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="${PYTHON:-python3}"
if ! command -v "$PY" >/dev/null 2>&1; then
  PY=python
fi
exec "$PY" "$ROOT/scripts/taskbar-planets-ui-assets.py" "$@"

#!/bin/bash
set -euo pipefail

python3 -m http.server &
SERVER_PID=$!

cleanup() {
  kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

pytest -vv tests_emulator.py
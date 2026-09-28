#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_PATH="$ROOT_DIR/bin/double-arrow"

echo "==> Building"
mkdir -p "$ROOT_DIR/bin"
swiftc -O "$ROOT_DIR"/Sources/*.swift -o "$BIN_PATH"

"$ROOT_DIR/Scripts/install-agent.sh" "$BIN_PATH"

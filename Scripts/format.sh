#!/bin/zsh

set -euo pipefail

ROOT_DIR="${0:A:h:h}"

if ! command -v swiftformat >/dev/null 2>&1; then
    echo "error: swiftformat is required. Install it with: brew install swiftformat" >&2
    exit 127
fi

swiftformat "$ROOT_DIR/Apps" "$ROOT_DIR/Packages" --config "$ROOT_DIR/.swiftformat"


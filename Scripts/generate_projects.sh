#!/bin/zsh

set -euo pipefail

ROOT_DIR="${0:A:h:h}"

xcodegen generate --spec "$ROOT_DIR/Apps/MetalAnimationLabiOS/project.yml"
xcodegen generate --spec "$ROOT_DIR/Apps/MetalAnimationLabmacOS/project.yml"

echo "Generated UIKit and AppKit projects."

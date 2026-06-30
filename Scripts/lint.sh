#!/bin/zsh

set -euo pipefail

ROOT_DIR="${0:A:h:h}"

for command_name in swiftformat swiftlint; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "error: $command_name is required." >&2
        exit 127
    fi
done

swiftformat --lint "$ROOT_DIR/Apps" "$ROOT_DIR/Packages" --config "$ROOT_DIR/.swiftformat"
(
    cd "$ROOT_DIR"
    swiftlint lint --strict --config .swiftlint.yml
)


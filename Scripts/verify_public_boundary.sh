#!/bin/zsh

set -euo pipefail

ROOT_DIR="${0:A:h:h}"
cd "$ROOT_DIR"

for forbidden_path in \
    'docs/superpowers' \
    '.codex' \
    '.claude' \
    '.cursor' \
    '.windsurf' \
    'xcuserdata'; do
    if git ls-files | rg -q "(^|/)${forbidden_path}(/|$)"; then
        echo "error: tracked private development path: $forbidden_path" >&2
        exit 1
    fi
done

if git log --all --format='%H' -- docs/superpowers | rg -q .; then
    echo "error: docs/superpowers appears in reachable Git history" >&2
    exit 1
fi

if git grep -n -E 'SignatureMotionKit|/Users/xiaoxiao|\.\./SignatureMotionKit' -- \
    . ':(exclude)Scripts/verify_public_boundary.sh'; then
    echo "error: public files contain a private package or local path reference" >&2
    exit 1
fi

if git grep -n -E 'BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|gh[pousr]_[A-Za-z0-9]+' -- \
    . ':(exclude)Scripts/verify_public_boundary.sh'; then
    echo "error: possible secret material found" >&2
    exit 1
fi

echo "Public repository boundary verified."


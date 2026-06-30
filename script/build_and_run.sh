#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-run}"
APP_NAME="MetalAnimationLab"
BUNDLE_ID="com.liyafly.MetalAnimationLab.macOS"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/Apps/MetalAnimationLabmacOS/MetalAnimationLabmacOS.xcodeproj"
DERIVED_DATA="${TMPDIR:-/tmp}/MetalAnimationLab-run"
APP_BUNDLE="$DERIVED_DATA/Build/Products/Debug/$APP_NAME.app"
APP_BINARY="$APP_BUNDLE/Contents/MacOS/$APP_NAME"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

xcodebuild \
    -project "$PROJECT" \
    -scheme MetalAnimationLabmacOS \
    -destination 'platform=macOS' \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    build >/dev/null

open_app() {
    /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
    run)
        open_app
        ;;
    --debug | debug)
        lldb -- "$APP_BINARY"
        ;;
    --logs | logs)
        open_app
        /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
        ;;
    --telemetry | telemetry)
        open_app
        /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
        ;;
    --verify | verify)
        open_app
        for _ in {1..20}; do
            if pgrep -x "$APP_NAME" >/dev/null; then
                sleep 1
                echo "$APP_NAME is running."
                exit 0
            fi
            sleep 0.25
        done
        echo "error: $APP_NAME did not remain running." >&2
        exit 1
        ;;
    *)
        echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
        exit 2
        ;;
esac

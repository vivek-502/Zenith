#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use '|| exit 1' to terminate the handler if the picker is cancelled
"$SCRIPT_DIR/wal-wallpaper.sh" || exit 1

sleep 0.2
"$SCRIPT_DIR/apply-all.sh"
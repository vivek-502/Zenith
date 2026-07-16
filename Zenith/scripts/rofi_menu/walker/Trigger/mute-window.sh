#!/usr/bin/env bash
# hypr-rofi-toggle-mute.sh
# Uses rofi (walker.rasi) to pick a Hyprland window, then toggles PipeWire mute for that window's PID.

set -euo pipefail
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 1; }; }
need hyprctl
need jq
need wpctl
need rofi

RASI="${HOME}/.config/rofi/walker.rasi"

win_json="$(hyprctl clients -j)"

# rofi shows "PID: CLASS — TITLE" and we extract the PID from the selection
list="$(
  echo "$win_json" | jq -r '
    map(select(.pid != null and .pid != 0))
    | sort_by(.class, .title)
    | .[]
    | "\(.pid): \((.class // "unknown")) — \((.title // ""))"
  '
)"

sel="$(
  printf '%s\n' "$list" | rofi -dmenu -config "$RASI" -theme-str 'entry { placeholder: "Select..."; }') -p "Toggle mute"
)"

pid="$(printf '%s' "$sel" | sed -n 's/^\([0-9]\+\):.*/\1/p')"

[[ -n "${pid:-}" ]] || exit 0

wpctl set-mute --pid "$pid" toggle
echo "Toggled mute for PID: $pid" >&2

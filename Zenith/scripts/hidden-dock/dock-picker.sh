#!/usr/bin/env bash

set -euo pipefail

# 1. FIX: In the new Lua Zenithitecture, we pass the raw Lua string wrapper via hyprctl dispatch/eval
hyprctl eval "dofile('$HOME/.config/rofi/animations/Theme_selector_anim.lua')"

SPECIAL="magic"
CACHE_DIR="$HOME/.config/Zenith/.cache/dock-cache"
ROFI_THEME="$HOME/.config/rofi/theme-switcher.rasi"

mkdir -p "$CACHE_DIR"

CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

menu="$tmpdir/menu"

declare -a ADDRS=()

while IFS= read -r win; do
    addr=$(jq -r '.address' <<<"$win")
    class=$(jq -r '.class // "Unknown"' <<<"$win")
    title=$(jq -r '.title // ""' <<<"$win" | tr '\n' ' ')

    ADDRS+=("$addr")

    icon="$CACHE_DIR/${addr}.png"

    if [[ -f "$icon" ]]; then
        printf "%s - %s\0icon\x1f%s\n" \
            "$class" "$title" "$icon" >>"$menu"
    else
        printf "%s - %s\n" \
            "$class" "$title" >>"$menu"
    fi
done < <(
    hyprctl clients -j |
        jq -c --arg ws "special:$SPECIAL" \
        '.[] | select(.workspace.name == $ws)'
)

if ((${#ADDRS[@]} == 0)); then
    notify-send "Dock" "No windows in special workspace."
    exit 0
fi

index=$(
    rofi \
        -dmenu \
        -show-icons \
        -format i \
        -theme "$ROFI_THEME" \
        -p "Dock" \
        <"$menu"
)

[[ -z "$index" ]] && exit 0

addr="${ADDRS[$index]}"

# 2. FIX: Replaced "movetoworkspacesilent" with the new Lua table structure.
# We explicitly target the window address and set follow = false to prevent taking focus.
hyprctl dispatch "hl.dsp.window.move({ window = 'address:$addr', workspace = '$CURRENT_WS', follow = false })"

# Give Hyprland a moment to process the move.
sleep 0.05

# 3. FIX: Replaced "focuswindow" with the unified Lua dispatch structure.
hyprctl dispatch "hl.dsp.window.focus({ window = 'address:$addr' })"

# Delete cached screenshot.
rm -f "$CACHE_DIR/${addr}.png"

#!/usr/bin/env bash
# ~/.config/Zenith/scripts/workspace/save-workspace.sh

SCRIPT_DIR="$HOME/.config/Zenith/scripts/workspace"
CACHE_DIR="$HOME/.config/Zenith/.cache/workspace"
mkdir -p "$CACHE_DIR"

# 1. Ask the user for a workspace profile layout name
NAME=$(rofi -dmenu -i \
    -config ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Layout name"; }' \
    -p "Blur")


[ -z "$NAME" ] && exit 0

TARGET_DIR="$CACHE_DIR/$NAME"
mkdir -p "$TARGET_DIR"

# 2. Get current active workspace and monitor context
CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

# 3. Capture screenshot preview of the active monitor
grim -o "$MONITOR" "$TARGET_DIR/preview.png"

# 4. Extract active window properties on the current workspace
WINDOWS=$(hyprctl clients -j | jq --argjson ws "$CURRENT_WS" '
  map(select(.workspace.id == $ws)) |
  map({
    address: .address,
    class: .class,
    title: .title,
    workspace: .workspace.id,
    monitor: .monitor,
    floating: .floating,
    fullscreen: .fullscreen,
    at: .at,
    size: .size
  })
')

echo "$WINDOWS" > "$TARGET_DIR/workspace.json"

# 5. Notify that layout is saved (Applications are left untouched)
notify-send "Workspace Saved" "Layout '$NAME' has been saved successfully."


---------------------
---- MY PROGRAMS ----
---------------------

local mainMod       = "SUPER"
local terminal      = "kitty"
local fileManager   = "nautilus"
local browser       = "firefox"

local scripts       = os.getenv("HOME") .. "/.config/Zenith/scripts"
local menu           = os.getenv("HOME") .. "/.config/Zenith/scripts/rofi_menu/App_launcher.sh"

local wifi           = "kitty --class floating-terminal -e nmtui"
local sound_control = "kitty --class floating-terminal -e wiremix --tab output"

local install_menu           = os.getenv("HOME") .. "/.config/Zenith/scripts/rofi_menu/walker/Install/install.sh"
local main_walker_menu      = scripts .. "/rofi_menu/walker/walker.sh"
local notification_menu     = "swaync-client -t"

---------------------------------
---- KEYBINDINGS (Converted) ---
---------------------------------

-- Open terminal
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))

-- Open file manager
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(fileManager))

-- App launcher (rofi) fallback: "menu || killall rofi"
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu .. " || killall rofi"))

-- Browser
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser))

-- WiFi nmtui
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(wifi))

-- Sound control (wiremix)
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("kitty --class quick-terminal"))

-- Install menu
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(install_menu))

-- Walker menu
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd(main_walker_menu))

-- Notifications
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(notification_menu))

-- Wiremix
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(sound_control))

------------------------------------------------
-- Window Management / Layout (converted)
------------------------------------------------
-- Close focused window
hl.bind(mainMod .. " + W", hl.dsp.window.close())

-- Force kill a window
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("hyprctl kill"))

-- Toggle floating
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))

-- Toggle fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Dwindle: pseudo tiling
hl.bind(mainMod .. " + H", hl.dsp.layout("pseudo"))

-- Dwindle: togglesplit
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Send to dock scripts
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(scripts .. "/hidden-dock/send-to-dock.sh"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(scripts .. "/hidden-dock/dock-picker.sh"))

------------------------------------------------
-- Grouping
------------------------------------------------

-- Example Keybinds (using mainMod = "SUPER")
hl.bind(mainMod .. " + G", hl.dsp.group.toggle()) -- Toggle Group
hl.bind(mainMod .. " + TAB", hl.dsp.group.prev()) -- Next/Prev Window

------------------------------------------------
-- Focus & Movement (converted)
------------------------------------------------
-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move/resize via mouse drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize active window while holding CTRL + arrow keys
-- Set your modifier key (e.g., "SUPER") and resize step

-- Resize with SUPER + SHIFT + Arrow Keys (Holding enabled)
hl.bind(mainMod .. " + CTRL + Left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.resize({ x = 20,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + UP",  hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + DOWN", hl.dsp.window.resize({ x = 0,  y = 20, relative = true }), { repeating = true })

-- hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ dx = 10, dy = 0 }))
-- hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ dx = -10, dy = 0 }))
-- hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ dx = 0, dy = -10 }))
-- hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ dx = 0, dy = 10 }))

------------------------------------------------
-- Workspaces (1-10)
------------------------------------------------
-- Focus workspace
for i = 1, 10 do
  local key = i % 10 -- 10 -> 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  -- Move window to workspace
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
-- Example: Bind SUPER + SHIFT + S to send the active window 
-- to the default special workspace ("magic") silently.
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))
-- hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))


-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

------------------------------------------------
-- Hardware & Media Controls
------------------------------------------------
-- Volume (old config used pactl; keeping the same behavior)
hl.bind("XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
  { repeating = true, locked = true }
)
hl.bind("XF86AudioLowerVolume",
  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
  { repeating = true, locked = true }
)
hl.bind("XF86AudioMute",
  hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
  { repeating = true, locked = true }
)

-- Mic mute (old config)
hl.bind("XF86AudioMicMute",
  hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
  { repeating = true, locked = true }
)

-- Brightness
hl.bind("XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl set +10%"),
  { repeating = true, locked = true }
)
hl.bind("XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl set 10%-"),
  { repeating = true, locked = true }
)

-- Media keys (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Mute-window script
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/Zenith/scripts/rofi_menu/walker/Trigger/mute-window.sh"))

------------------------------------------------
-- System & Utilities
------------------------------------------------
-- Lock screen
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- Power menu
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(scripts .. "/rofi_menu/powermenu.sh"))

-- Power profile
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(scripts .. "/rofi_menu/walker/System/power-profile.sh"))

-- Toggle Waybar (killall -SIGUSR1 waybar)
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- Screenshot (no modifier)
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -z -m region"))

-- Workspace script
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(scripts .. "/workspace/workspace.sh"))

------------------------------------------------
-- Clipboard & Tools
------------------------------------------------
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(scripts .. "/rofi_menu/clipboard.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker | wl-copy"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(scripts .. "/rofi_menu/keybindings.sh"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(scripts .. "/rofi_menu/walker/Trigger/OCR4Linux.sh"))

------------------------------------------------
-- Theming & Custom Menus
------------------------------------------------
hl.bind(mainMod .. " + ALT + S",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/walker/Appearence/style.sh")
)
hl.bind(mainMod .. " + ALT + T",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/walker/Appearence/theme_by_wallpaper.sh")
)
hl.bind(mainMod .. " + ALT + B",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/theme_selector/choose-background.sh")
)
hl.bind(mainMod .. " + ALT + L",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/theme_selector/live-wallpaper.sh")
)
hl.bind("SUPER + SHIFT + W",
  hl.dsp.exec_cmd(scripts .. "/switch-waybar-pos.sh")
)
hl.bind("SUPER + ALT + H",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/walker/Appearence/hyprland.sh")
)
hl.bind(mainMod .. " + ALT + I",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/theme_selector/icons.sh")
)
hl.bind(mainMod .. " + ALT + F",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/theme_selector/font-selector.sh")
)
hl.bind(mainMod .. " + ALT + O",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/walker/Appearence/opacity.sh")
)
hl.bind(mainMod .. " + ALT + C",
  hl.dsp.exec_cmd(scripts .. "/rofi_menu/theme_selector/cursor.sh")
)
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See wiki.hypr.land for the exact semantics of the fields.

-- 1) suppress maximize requests from all apps
hl.window_rule({
  name  = "suppress-maximize-events",
  match = { class = ".*" },

  suppress_event = "maximize",
})

-- 2) Fix some dragging issues with XWayland
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

-- 3) Layer blur rules (layerrule)
-- (If your helper names this differently, tell me your hl helper API and I’ll adjust.)
hl.layer_rule({
  name = "blur-rofi",
  match = { namespace = "rofi" },
  blur = true,
  ignore_alpha = 0.05,
})

hl.layer_rule({
  name = "blur-swaync-control-center",
  match = { namespace = "swaync-control-center" },
  blur = true,
  ignore_alpha = 0.1,
})

hl.layer_rule({
  name = "blur-nm-applet",
  match = { namespace = "nm-applet" },
  blur = true,
  ignore_alpha = 0.1,
})

hl.layer_rule({
  name = "blur-waybar",
  match = { namespace = "waybar" },
  blur = true,
  ignore_alpha = 0.1,
})

-- 4) Float + size + center for a bunch of apps
hl.window_rule({
  match = {
    class = "(viewnior|mpv|xdg-desktop-portal-gtk|org.gnome.clocks|floating-terminal|org.gnome.eog|blueman-manager|Tk|brave|Open Files)"
  },

  size = "700 450",
  float = true,
  center = true,
})

-- 5) Center DesktopEditors
hl.window_rule({
  match = { class = "DesktopEditors" },
  center = true,
})

-- 6) Quick terminal (specific rule)
hl.window_rule({
  name  = "quick-terminal",
  match = { class = "quick-terminal" },

  float  = true,
  center = true,
  size   = "550 350",
})

-- 7) Fullscreen for Waydroid / wlroots
hl.window_rule({
  match = { class = "(Waydroid|wlroots)" },
  fullscreen = true,
})


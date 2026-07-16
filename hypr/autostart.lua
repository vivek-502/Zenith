-------------------
---- AUTOSTART ----
-------------------

-- Autostart processes (runs on hyprland start)
hl.on("hyprland.start", function ()
  hl.exec_cmd("waybar")
  hl.exec_cmd("awww-daemon")

  -- pkill swaync; swaync
  hl.exec_cmd("pkill swaync; swaync")

  hl.exec_cmd("hypridle")
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("nm-applet &")

  -- polkit authentication agent
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

  hl.exec_cmd("hyprctl setcursor Adwaita 24")
  hl.exec_cmd("bash ~/.config/hypr/first_run.sh")
end)

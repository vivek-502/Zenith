
-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 10,

        border_size = 3,

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 5,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.99,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 4,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})



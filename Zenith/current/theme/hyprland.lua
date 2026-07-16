
hl.config({

    general = {
        col = {
            active_border   = { colors = {'rgba(3A5887ee)', 'rgba(867B86ee)'}, angle = 45 },
            inactive_border = 'rgba(1a0f0aaa)',
        },
    },

    group = {
        -- Group border colors are now nested inside a 'col' sub-table
        col = {
            border_active = 'rgba(3A5887ee)',
            border_inactive = 'rgba(1a0f0aaa)',
            border_locked_active = 'rgba(867B86ee)',
            border_locked_inactive = 'rgba(1a0f0aaa)',
        },

        -- Group bar (tab) appearance
        groupbar = {
            enabled = true,
            font_size = 10,
            gradients = true,
            height = 14,
            render_titles = true,
            scrolling = true,

            -- Tab colors are also nested inside a 'col' sub-table
            col = {
                active = 'rgba(3A5887ee)',
                inactive = 'rgba(1a0f0aaa)',
                locked_active = 'rgba(867B86ee)',
                locked_inactive = 'rgba(1a0f0aaa)',
            },
        },
    },
})



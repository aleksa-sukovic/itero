local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- [[ Theme ]]
local theme_file = os.getenv("HOME") .. "/.local/share/itero/themes/current/wezterm.lua"
local ok, color_scheme = pcall(dofile, theme_file)
if not ok then
    color_scheme = "Catppuccin Mocha"
end

-- [[ General configuration ]]
config.initial_rows = 25
config.initial_cols = 140
config.window_close_confirmation = "NeverPrompt"
config.enable_kitty_keyboard = true

-- [[ Window configuration ]]
config.window_decorations = wezterm.target_triple:find("darwin") and "RESIZE" or "NONE"
config.window_background_opacity = 1.0
config.window_content_alignment = {
    horizontal = "Center",
    vertical = "Center",
}
config.window_padding = {
    left = 15,
    right = 15,
    top = 15,
    bottom = 15,
}

-- [[ Tab configuration ]]
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = true

-- [[ Font configuration ]]
config.font_size = 11.0
config.line_height = 1.0
config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "JetBrains Mono" })

-- [[ Color scheme ]]
config.color_scheme = color_scheme
config.colors = {
    cursor_bg = "{{ accent }}",
    tab_bar = {
        background = "{{ color0 }}",
        active_tab = {
            bg_color = "{{ accent }}",
            fg_color = "{{ background }}",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "{{ color15 }}",
            fg_color = "{{ background }}",
        },
        inactive_tab_hover = {
            bg_color = "{{ color15 }}",
            fg_color = "{{ background }}",
        },
        new_tab = {
            bg_color = "{{ color0 }}",
            fg_color = "{{ accent }}",
        },
        new_tab_hover = {
            bg_color = "{{ color0 }}",
            fg_color = "{{ accent }}",
        },
    },
}

-- [[ Key bindings ]]
config.keys = {
    {
        key = "{",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ActivateCopyMode,
    },
}

return config

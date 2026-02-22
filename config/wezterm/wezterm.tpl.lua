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

-- [[ Font configuration ]]
config.font_size = 10.0
config.line_height = 1.7
config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "JetBrains Mono" })

-- [[ Color scheme ]]
config.color_scheme = color_scheme
config.colors = {
    cursor_bg = "{{ accent }}",
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

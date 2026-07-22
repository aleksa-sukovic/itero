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
config.leader = {
    key = "s",
    mods = "CTRL|ALT",
    timeout_milliseconds = 1000,
}
config.keys = {
    {
        key = "c",
        mods = "LEADER",
        action = wezterm.action.SpawnTab("CurrentPaneDomain"),
    },
    {
        key = "w",
        mods = "LEADER",
        action = wezterm.action.CloseCurrentTab({ confirm = false }),
    },
    {
        key = "%",
        mods = "LEADER|SHIFT",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        key = '"',
        mods = "LEADER|SHIFT",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        key = "x",
        mods = "LEADER",
        action = wezterm.action.CloseCurrentPane({ confirm = false }),
    },
    {
        key = "h",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Left"),
    },
    {
        key = "j",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Down"),
    },
    {
        key = "k",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Up"),
    },
    {
        key = "l",
        mods = "LEADER",
        action = wezterm.action.ActivatePaneDirection("Right"),
    },
    {
        key = "[",
        mods = "LEADER",
        action = wezterm.action.ActivateCopyMode,
    },
    {
        key = "q",
        mods = "LEADER",
        action = wezterm.action.QuickSelect,
    },
    {
        key = "r",
        mods = "LEADER",
        action = wezterm.action.ReloadConfiguration,
    },
    {
        key = "1",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(0),
    },
    {
        key = "2",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(1),
    },
    {
        key = "3",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(2),
    },
    {
        key = "4",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(3),
    },
    {
        key = "5",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(4),
    },
    {
        key = "6",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(5),
    },
    {
        key = "7",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(6),
    },
    {
        key = "8",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(7),
    },
    {
        key = "9",
        mods = "LEADER",
        action = wezterm.action.ActivateTab(-1),
    },
}

return config

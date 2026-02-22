-- Dynamic colorscheme loader with file watcher for live theme switching.

local itero_dir = vim.fn.expand("~/.local/share/itero")
local theme_path = itero_dir .. "/themes/current/neovim.lua"
local fallback_path = itero_dir .. "/themes/catppuccin-frappe/neovim.lua"
local themes_dir = itero_dir .. "/themes"

local function resolve_opts(spec)
    if type(spec.opts) == "function" then
        return spec.opts()
    end
    return spec.opts
end

-- Re-read the theme file and apply the new configuration.
local function apply_theme()
    local ok, new_spec = pcall(dofile, theme_path)
    if not ok or not new_spec then
        return
    end

    if new_spec.config then
        new_spec.config(nil, resolve_opts(new_spec))
    end
end

-- Reload lualine with the updated palette and accent.
local function refresh_lualine()
    local ok, lualine = pcall(require, "lualine")
    if not ok then
        return
    end

    package.loaded["lualine.themes.catppuccin"] = nil
    local accent = require("itero").accent()
    local theme = require("lualine.themes.catppuccin")
    theme.normal.a.bg = accent
    theme.normal.b.fg = accent
    lualine.setup({ options = { theme = theme } })
end

-- Refresh the IteroAccent highlight used by the dashboard logo.
local function refresh_accent_highlight()
    local accent = require("itero").accent()
    vim.api.nvim_set_hl(0, "IteroAccent", { fg = accent })
end

-- Watch the themes directory for symlink changes and auto-reload.
local watcher = nil

local function watch_theme_changes()
    if watcher then return end
    watcher = vim.uv.new_fs_event()
    if not watcher then return end

    local function on_change(err, filename)
        if err or filename ~= "current" then
            return
        end
        watcher:stop()
        vim.defer_fn(function()
            apply_theme()
            refresh_lualine()
            refresh_accent_highlight()
            watcher:start(themes_dir, {}, vim.schedule_wrap(on_change))
        end, 500)
    end

    watcher:start(themes_dir, {}, vim.schedule_wrap(on_change))
end

local spec = dofile(vim.fn.filereadable(theme_path) == 1 and theme_path or fallback_path)
local original_config = spec.config

spec.config = function(plugin, opts)
    if original_config then
        original_config(plugin, opts)
    end
    watch_theme_changes()
end

return spec

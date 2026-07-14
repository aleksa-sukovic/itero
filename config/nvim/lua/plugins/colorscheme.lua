-- Dynamic colorscheme loader with file watcher for live theme switching.

local itero_dir = vim.fn.expand("~/.local/share/itero")
local theme_path = itero_dir .. "/themes/current/neovim.lua"
local themes_dir = itero_dir .. "/themes"

local function resolve_opts(spec)
    if type(spec.opts) == "function" then
        return spec.opts()
    end
    return spec.opts
end

local function load_theme()
    local ok, spec = pcall(dofile, theme_path)

    if not ok or type(spec) ~= "table" then
        return nil
    end

    return spec
end

-- Re-read the theme file and apply the new configuration.
local function apply_theme()
    local new_spec = load_theme()

    if not new_spec or not new_spec.config then
        return
    end

    new_spec.config(nil, resolve_opts(new_spec))
end

-- Reload Lualine with the theme supplied by the active Itero theme.
local function refresh_lualine()
    local ok, lualine = pcall(require, "lualine")

    if not ok then
        return
    end

    lualine.setup({ options = { theme = require("itero").lualine_theme() } })
end

-- Refresh the IteroAccent highlight used by the dashboard logo.
local function refresh_accent_highlight()
    vim.api.nvim_set_hl(0, "IteroAccent", { fg = require("itero").accent() })
end

-- Watch the themes directory for symlink changes and auto-reload.
local watcher = nil

local function watch_theme_changes()
    if watcher then
        return
    end
    watcher = vim.uv.new_fs_event()
    if not watcher then
        return
    end

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

local spec = load_theme()
if not spec then
    return {}
end

local original_config = spec.config

spec.config = function(plugin, opts)
    if original_config then
        original_config(plugin, opts)
    end
    watch_theme_changes()
end

return spec

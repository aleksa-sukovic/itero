-- Itero utility functions.
local M = {}

-- Returns the hex color of the configured theme accent.
function M.accent()
    return vim.g.itero_accent or "#ffffff"
end

-- Returns the Lualine theme supplied by the active Itero theme.
function M.lualine_theme()
    local theme_path = vim.fn.expand("~/.local/share/itero/themes/current/lualine.lua")

    if vim.fn.filereadable(theme_path) == 0 then
        return "auto"
    end

    local ok, theme = pcall(dofile, theme_path)
    if ok and theme then
        return theme
    end

    return "auto"
end

return M

-- Itero utility functions.
local M = {}

-- Returns the hex color of the configured accent from the catppuccin palette.
function M.accent()
    local palette = require("catppuccin.palettes").get_palette()
    return palette[vim.g.itero_accent]
end

return M

-- Customizable status bar.
-- See also: https://github.com/nvim-lualine/lualine.nvim
return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local accent = require("itero").accent()
        local theme = require("lualine.themes.catppuccin")

        theme.normal.a.bg = accent
        theme.normal.b.fg = accent

        require("lualine").setup({
            options = {
                theme = theme,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        symbols = {
                            modified = "",
                            readonly = "",
                            unnamed = "",
                            newfile = "",
                        },
                    },
                },
                lualine_x = {
                    "encoding",
                    "filetype",
                },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            extensions = { "lazy" },
        })
    end,
}

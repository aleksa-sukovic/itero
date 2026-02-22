return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "macchiato",
        custom_highlights = function(colors)
            local accent = colors.{{ accent_name }}
            return {
                TelescopeNormal = { bg = colors.base },
                TelescopePromptNormal = { bg = colors.base },
                TelescopeResultsNormal = { bg = colors.base },
                TelescopePreviewNormal = { bg = colors.base },
                TelescopePromptBorder = { bg = colors.base, fg = accent },
                TelescopeResultsBorder = { bg = colors.base, fg = accent },
                TelescopePreviewBorder = { bg = colors.base, fg = accent },
                TelescopePromptTitle = { bg = colors.base, fg = accent },
                TelescopeResultsTitle = { bg = colors.base, fg = accent },
                TelescopePreviewTitle = { bg = colors.base, fg = accent },
            }
        end,
        integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            treesitter = true,
            notify = true,
            mini = { enabled = true },
            telescope = { enabled = true },
            lsp_trouble = true,
            which_key = true,
        },
    },
    config = function(_, opts)
        vim.g.itero_accent = "{{ accent_name }}"
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}

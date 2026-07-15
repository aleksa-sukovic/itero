return {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
        variant = "main",
        highlight_groups = {
            TelescopeBorder = { fg = "{{ accent }}" },
            TelescopePromptBorder = { fg = "{{ accent }}" },
            TelescopeResultsBorder = { fg = "{{ accent }}" },
            TelescopePreviewBorder = { fg = "{{ accent }}" },
        },
    },
    config = function(_, opts)
        vim.g.itero_accent = "{{ accent }}"
        vim.o.background = "dark"
        require("rose-pine").setup(opts)
        vim.cmd.colorscheme("rose-pine-main")
    end,
}

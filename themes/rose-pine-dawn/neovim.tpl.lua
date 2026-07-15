return {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
        variant = "dawn",
        highlight_groups = {
            TelescopeBorder = { fg = "{{ accent }}" },
            TelescopePromptBorder = { fg = "{{ accent }}" },
            TelescopeResultsBorder = { fg = "{{ accent }}" },
            TelescopePreviewBorder = { fg = "{{ accent }}" },
        },
    },
    config = function(_, opts)
        vim.g.itero_accent = "{{ accent }}"
        vim.o.background = "light"
        require("rose-pine").setup(opts)
        vim.cmd.colorscheme("rose-pine-dawn")
    end,
}

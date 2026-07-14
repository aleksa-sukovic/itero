return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
        contrast = "medium",
        overrides = {
            TelescopeBorder = { fg = "{{ accent }}" },
            TelescopePromptBorder = { fg = "{{ accent }}" },
            TelescopeResultsBorder = { fg = "{{ accent }}" },
            TelescopePreviewBorder = { fg = "{{ accent }}" },
        },
    },
    config = function(_, opts)
        vim.g.itero_accent = "{{ accent }}"
        vim.o.background = "light"
        require("gruvbox").setup(opts)
        vim.cmd.colorscheme("gruvbox")
    end,
}

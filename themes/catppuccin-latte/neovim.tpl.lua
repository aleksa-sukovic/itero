return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "latte",
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
        vim.g.itero_accent = "{{ accent }}"
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}

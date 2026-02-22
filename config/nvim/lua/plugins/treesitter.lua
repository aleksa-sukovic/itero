-- Highlight, edit, and navigate code.
-- New languages are automatically installed upon start.
-- See `:help nvim-treesitter`.
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.config",
    opts = {
        ensure_installed = {
            "bash",
            "c",
            "diff",
            "html",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "query",
            "vim",
            "vimdoc",
            "toml",
            "rust",
            "python",
        },
        sync_install = true,
        auto_install = true,
        highlight = {
            enable = true,
            -- N.B. Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
            -- If experiencing weird indenting issues, add the language to the list below and to the disabled
            -- languages for indent.
            additional_vim_regex_highlighting = {},
        },
        indent = { enable = true, disable = {} },
    },
}

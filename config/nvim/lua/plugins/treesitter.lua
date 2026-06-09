-- Highlight, indent, and install tree-sitter parsers.
-- See `:help nvim-treesitter`.
return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local languages = {
            "bash",
            "c",
            "diff",
            "html",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "rust",
            "toml",
            "vim",
            "vimdoc",
        }

        local treesitter = require("nvim-treesitter")
        treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

        local installed_languages = {}
        for _, language in ipairs(treesitter.get_installed()) do
            installed_languages[language] = true
        end

        local missing_languages = {}
        for _, language in ipairs(languages) do
            if not installed_languages[language] then
                table.insert(missing_languages, language)
            end
        end

        if #missing_languages > 0 then
            treesitter.install(missing_languages, { summary = true }):wait(300000)
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("alsk-treesitter", { clear = true }),
            pattern = languages,
            callback = function()
                vim.treesitter.start()
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo.foldmethod = "expr"
                vim.wo.foldlevel = 99
                vim.o.foldlevelstart = 99
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}

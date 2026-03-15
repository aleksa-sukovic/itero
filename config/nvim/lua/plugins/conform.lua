-- Formatting configuration.
-- Uses dedicated formatters when available, otherwise falls back to LSP formatting.

-- Recursively checks for the presence of Ruff configuration files in the given path and its parent directories.
local function has_ruff_config(path)
    if vim.fs.find({ "ruff.toml", ".ruff.toml" }, { upward = true, path = path })[1] then
        return true
    end

    local dir = path

    while dir do
        local pyproject = dir .. "/pyproject.toml"
        local file = io.open(pyproject, "r")

        if file then
            local content = file:read("*a")
            file:close()

            if content:find("%[tool%.ruff%]") then
                return true
            end
        end

        local parent = vim.fs.dirname(dir)
        if not parent or parent == dir then
            break
        end

        dir = parent
    end

    return false
end

return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = { "n", "v" },
            desc = "[F]ormat buffer",
        },
    },
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            local disable_filetypes = { c = true, cpp = true }
            if disable_filetypes[vim.bo[bufnr].filetype] then
                return nil
            else
                return { timeout_ms = 500, lsp_format = "fallback" }
            end
        end,
        formatters_by_ft = {
            lua = { "stylua" },
            yaml = { "prettier" },
            json = { "prettier" },
            markdown = { "prettier" },
            html = { "prettier" },
            css = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            python = function(bufnr)
                local cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

                if has_ruff_config(cwd) and require("conform").get_formatter_info("ruff_format", bufnr).available then
                    return { "ruff_fix", "ruff_format", "ruff_organize_imports" }
                end

                return { "isort", "black" }
            end,
            ["*"] = { "editorconfig" },
        },
    },
}

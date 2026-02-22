-- Autoformat configuration.
-- Fallbacks to the formatter provided by LSP, unless a dedicated one is found.
-- Disabled for the following languages: C, C++ (see `:help filetypes` for a list of names).
-- N.B. Formatters can be run sequentially (e.g., `{ "isort", "black" }`). Additionally, set
-- the `stop_after_first = true` configuration to only run the first one.
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
                -- Check if a Ruff configuration file exists in the project
                local cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
                local ruff_config = vim.fs.find({ "ruff.toml", ".ruff.toml" }, { upward = true, path = cwd })[1]
                local pyproject = vim.fs.find({ "pyproject.toml" }, { upward = true, path = cwd })[1]

                local has_ruff_config = false

                if ruff_config then
                    -- If we found an explicit Ruff configuration file
                    has_ruff_config = true
                elseif pyproject then
                    -- Check if pyproject.toml actually contains a [tool.ruff] section
                    local file = io.open(pyproject, "r")
                    if file then
                        local content = file:read("*a")
                        file:close()
                        if content:find("%[tool%.ruff%]") then
                            has_ruff_config = true
                        end
                    end
                end

                if has_ruff_config and require("conform").get_formatter_info("ruff_format", bufnr).available then
                    -- If config exists and Ruff is installed, we us it
                    return { "ruff_fix", "ruff_format", "ruff_organize_imports" }
                else
                    -- Otherwise, we default to isort & black
                    return { "isort", "black" }
                end
            end,
            ["*"] = { "editorconfig" },
        },
    },
}

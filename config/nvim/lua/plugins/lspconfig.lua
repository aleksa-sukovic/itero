-- Main LSP Configuration
-- See `:help `
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        -- The package manager that downloads external software (LSPs, formatters, etc.)
        { "mason-org/mason.nvim", opts = {} },
        -- Automatically installs and updates LSPs and other tools
        { "WhoIsSethDaniel/mason-tool-installer.nvim", opts = {} },
        -- Useful status updates for LSP in the bottom-right corner
        { "j-hui/fidget.nvim", opts = {} },
        -- Allows extra capabilities provided by blink.cmp
        "saghen/blink.cmp",
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("alsk-lsp-attach", { clear = true }),
            callback = function(event)
                -- Helper function to define LSP-specific keymaps only for the current file (buffer).
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
                end

                -- Rename the variable under the cursor
                map("<leader>ln", vim.lsp.buf.rename, "[R]e[n]ame")
                -- Open a menu of available quick-fixes or refactors for the current code
                map("<leader>la", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
                -- Find references for the word under your cursor
                map("<leader>lr", require("telescope.builtin").lsp_references, "[R]eferences")
                -- Jump to the implementation of the word under your cursor
                map("<leader>li", require("telescope.builtin").lsp_implementations, "[I]mplementation")
                -- Jump to incoming/outgoing calls
                map("<leader>lI", require("telescope.builtin").lsp_incoming_calls, "[I]ncoming Calls")
                map("<leader>lO", require("telescope.builtin").lsp_outgoing_calls, "[O]utgoing Calls")
                -- Jump to the definition of the word under your cursor (jump back with <C-t>)
                map("<leader>ld", require("telescope.builtin").lsp_definitions, "[D]efinition")
                -- Jump to the declaration (e.g., header file in C language)
                map("<leader>lD", vim.lsp.buf.declaration, "[D]eclaration")
                -- Fuzzy find all the symbols (e.g., variables, functions, types, etc.) in the current document
                map("<leader>lo", require("telescope.builtin").lsp_document_symbols, "D[o]cument Symbols")
                -- Fuzzy find all the symbols in your current workspace
                map("<leader>lw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace Symbols")
                -- Jump to the type of the word under your cursor
                map("<leader>lt", require("telescope.builtin").lsp_type_definitions, "[T]ype Definition")

                -- Highlight all instances of the word under the cursor after a short pause
                -- See `:help CursorHold` for information about when this is executed
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                    local highlight_augroup = vim.api.nvim_create_augroup("alsk-lsp-highlight", { clear = false })

                    -- Trigger the highlight when the cursor stops moving
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    -- Remove highlights as soon as the cursor moves again
                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    -- Clean up all highlights and autocommands when the LSP shuts down
                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("alsk-lsp-detach", { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "alsk-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                -- Toggle ghost-text hints for parameter names and types directly in your code
                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                    map("<leader>lh", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, "Toggle Inlay [H]ints")
                end

                -- Toggle documentation
                map("K", vim.lsp.buf.hover, "[H]over Documentation")
            end,
        })

        -- Diagnostic Config
        -- See :help vim.diagnostic.Opts
        vim.diagnostic.config({
            severity_sort = true,
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = "󰅚 ",
                    [vim.diagnostic.severity.WARN] = "󰀪 ",
                    [vim.diagnostic.severity.INFO] = "󰋽 ",
                    [vim.diagnostic.severity.HINT] = "󰌶 ",
                },
            },
            virtual_text = false,
            float = { source = true, border = "rounded" },
        })

        -- LSP servers and clients are able to communicate to each other what features they support
        -- We pass here a list of additional capabilities that stem from blink.cmp
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        -- Request & enable language servers and additional formatters/tools
        -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            },
            basedpyright = {
                analysis = {
                    diagnosticMode = "openFilesOnly",
                },
            },
            ruff = {},
        }

        -- Ensure the servers and tools above are installed
        local mason_packages = {
            -- Lua
            "lua-language-server",
            "stylua",
            -- Python
            "basedpyright",
            "ruff",
            "black",
            "isort",
            "debugpy",
            -- JavaScript, TypeScript, HTML, CSS, JSON, YAML, Markdown
            "prettier",
            -- Rust
            "codelldb",
        }
        require("mason-tool-installer").setup({ ensure_installed = mason_packages })

        -- Enable LSPs
        for name, opts in pairs(servers) do
            opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})
            vim.lsp.config(name, opts)
            vim.lsp.enable(name, true)
        end
    end,
}

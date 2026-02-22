-- Fuzzy Finder (files, lsp, etc.).
return {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    event = "VimEnter",
    dependencies = {
        -- Utility library used throughout the plugin.
        "nvim-lua/plenary.nvim",
        -- Icon library (requires Nerd font).
        "nvim-tree/nvim-web-devicons",
        -- Replaces built-in selection menus (like Code Actions) with Telescope's fuzzy finder.
        "nvim-telescope/telescope-ui-select.nvim",
        -- High-performance C implementation of the fzf sorting algorithm.
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
        -- Live grep with args support.
        "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`

        local ignore_list = {
            { dir = ".git", pattern = "%.git/" },
            { dir = "node_modules", pattern = "node_modules/" },
            { dir = "__pycache__", pattern = "%__pycache__/" },
            { dir = "target", pattern = "%target/" },
            { dir = "dist", pattern = "%dist/" },
            { dir = ".pytest_cache", pattern = "%.pytest_cache/" },
            { dir = ".run", pattern = "%.run/" },
            { dir = ".mypy_cache", pattern = "%.mypy_cache/" },
            { dir = ".venv", pattern = "%.venv/" },
            { dir = ".ruff_cache", pattern = "%.ruff_cache/" },
            { dir = ".idea", pattern = "%.idea/" },
            { dir = ".hypothesis", pattern = "%.hypothesis/" },
        }

        -- Build fd command with excludes
        local fd_command = { "fd", "--type", "f", "--hidden", "--no-ignore", "--strip-cwd-prefix" }
        for _, item in ipairs(ignore_list) do
            table.insert(fd_command, "--exclude")
            table.insert(fd_command, item.dir)
        end

        -- Extract Lua patterns for Telescope
        local ignore_patterns = {}
        for _, item in ipairs(ignore_list) do
            table.insert(ignore_patterns, item.pattern)
        end

        require("telescope").setup({
            defaults = {
                file_ignore_patterns = ignore_patterns,
            },
            pickers = {
                find_files = {
                    find_command = fd_command,
                },
                live_grep = {
                    additional_args = { "--hidden", "--no-ignore" },
                },
                grep_string = {
                    additional_args = { "--hidden", "--no-ignore" },
                },
                colorscheme = {
                    enable_preview = true,
                },
            },
            extensions = {
                -- Force Neovim menus to use Telescope dropdown.
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown(),
                },
            },
        })

        -- Enable Telescope extensions.
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")
        pcall(require("telescope").load_extension, "live_grep_args")

        -- Set keymaps.
        -- See `:help telescope.builtin`
        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
        vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
        vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
        vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
        vim.keymap.set("n", "<leader>sG", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = "[S]earch by [G]rep" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
        vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find existing buffers" })

        vim.keymap.set("n", "<leader>uf", builtin.filetypes, { desc = "[F]ile T]ype" })

        vim.keymap.set("n", "<leader>/", function()
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "Fuzzily search in current buffer" })

        vim.keymap.set("n", "<leader>s/", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files",
            })
        end, { desc = "[S]earch [/] in Open Files" })

        vim.keymap.set("n", "<leader>sn", function()
            builtin.find_files({ cwd = vim.fn.stdpath("config") })
        end, { desc = "[S]earch [N]eovim files" })

        vim.keymap.set("n", "z=", builtin.spell_suggest, { desc = "Spell suggestions" })

        -- Buffer keybindings (reload, delete current)
        vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "[B]uffer [D]elete" })
        vim.keymap.set("n", "<leader>br", function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                    vim.api.nvim_buf_call(buf, function()
                        vim.cmd("checktime")
                    end)
                end
            end
        end, { desc = "[B]uffer [R]eload all" })
    end,
}

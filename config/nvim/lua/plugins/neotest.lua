-- Setup testing framework
return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
    },
    keys = {
        { "<leader>tr", desc = "[T]est [R]un nearest" },
        { "<leader>tf", desc = "[T]est [F]ile" },
        { "<leader>ta", desc = "[T]est [A]ll" },
        { "<leader>td", desc = "[T]est [D]ebug nearest" },
        { "<leader>ts", desc = "[T]est [S]ummary" },
        { "<leader>to", desc = "[T]est [O]utput" },
        { "<leader>tO", desc = "[T]est [O]utput Panel" },
        { "<leader>tS", desc = "[T]est [S]top" },
    },
    config = function()
        -- Define language-specific configurations
        local neotest_python_config = {
            dap = { justMyCode = false },
            runner = "pytest",
        }

        -- Setup Neotest
        local neotest_config = {
            adapters = {
                require("neotest-python")(neotest_python_config),
                require("rustaceanvim.neotest"),
            },
        }
        require("neotest").setup(neotest_config)

        -- Setup keymaps
        local neotest = require("neotest")

        -- Run tests
        vim.keymap.set("n", "<leader>tr", function()
            neotest.run.run()
        end, { desc = "[T]est [R]un nearest" })
        vim.keymap.set("n", "<leader>tf", function()
            neotest.run.run(vim.fn.expand("%"))
        end, { desc = "[T]est [F]ile" })
        vim.keymap.set("n", "<leader>ta", function()
            neotest.run.run(vim.loop.cwd())
        end, { desc = "[T]est [A]ll" })

        -- Debug tests
        vim.keymap.set("n", "<leader>td", function()
            neotest.run.run({ suite = false, strategy = "dap" })
        end, { desc = "[T]est [D]ebug nearest" })

        -- UI Controls
        vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, { desc = "[T]est [S]ummary" })
        vim.keymap.set("n", "<leader>to", function()
            neotest.output.open({ enter = true })
        end, { desc = "[T]est [O]utput" })
        vim.keymap.set("n", "<leader>tO", function()
            neotest.output_panel.toggle()
        end, { desc = "[T]est [O]utput Panel" })
        vim.keymap.set("n", "<leader>tS", neotest.run.stop, { desc = "[T]est [S]top" })
    end,
}

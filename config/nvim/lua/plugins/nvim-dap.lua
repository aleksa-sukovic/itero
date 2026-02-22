-- Debugging setup
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-dap-python",
    },
    keys = {
        { "<leader>db", desc = "Debug: Toggle [B]reakpoint" },
        { "<leader>dc", desc = "Debug: [C]continue / Start" },
        { "<leader>di", desc = "Debug: Step [I]nto" },
        { "<leader>do", desc = "Debug: Step [O]ver" },
        { "<leader>dO", desc = "Debug: Step [O]ut" },
        { "<leader>dt", desc = "Debug: [T]erminate Session" },
        { "<leader>dr", desc = "Debug: Open [R]EPL" },
        { "<leader>du", desc = "Debug: Toggle [U]I" },
        { "<leader>dB", desc = "Debug: Toggle Conditional [B]reakpoint" },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()

        -- Automatically open/close the UI when debugging starts/ends
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        -- Setup generic keymaps
        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle [B]reakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: [C]continue / Start" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step [I]nto" })
        vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step [O]ver" })
        vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step [O]ut" })
        vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: [T]erminate Session" })
        vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open [R]EPL" })
        vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle [U]I" })
        vim.keymap.set("n", "<leader>dB", function()
            require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, { desc = "Debug: Toggle Conditional [B]reakpoint" })

        -- Setup breakpoint styling
        vim.fn.sign_define("DapBreakpoint", {
            text = "●",
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = "",
        })
        vim.fn.sign_define("DapBreakpointCondition", {
            text = "",
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = "",
        })
        vim.fn.sign_define("DapStopped", {
            text = "",
            texthl = "DapStopped",
            linehl = "DapStoppedLine",
            numhl = "DapStopped",
        })

        -- Setup Python debugging
        local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        require("dap-python").setup(debugpy_path)

        -- N.B. We always require to define the debugging setup manually (e.g., via launch.json)
        dap.configurations.python = {}
    end,
}

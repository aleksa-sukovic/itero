return {
    "github/copilot.vim",
    lazy = false,
    config = function()
        vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", { desc = "Copilot Status" })
        vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", { desc = "Copilot Panel" })
        vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Copilot Disable" })
        vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Copilot Enable" })
    end,
}

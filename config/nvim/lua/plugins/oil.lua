-- File explorer that lets us edit your filesystem like a normal buffer.
-- See `:help oil`.
return {
    "stevearc/oil.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    priority = 1000,
    keys = {
        { "<leader>e", "<cmd>Oil<CR>", desc = "File [E]xplorer" },
    },
    config = function()
        require("oil").setup({
            watch_for_changes = true,
            default_file_explorer = true,
            skip_confirm_for_simple_edits = true,
            view_options = {
                show_hidden = true,
            },
        })
    end,
}

--- Find and replace across files.
return {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>ur", '<cmd>lua require("spectre").toggle()<CR>', mode = { "n", "v" }, desc = "Find and [R]eplace" },
    },
}

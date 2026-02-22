-- Utility plugin to show pending keybinds.
return {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
        delay = 0,
        spec = {
            -- Groups
            { "<leader>s", group = "[S]earch", icon = "" },
            { "<leader>t", group = "[T]est", icon = "󰙨" },
            { "<leader>d", group = "[D]ebug", icon = "" },
            { "<leader>g", group = "[G]it", icon = "" },
            { "<leader>b", group = "[B]uffer", icon = "" },
            { "<leader>l", group = "[L]anguage", icon = " " },
            { "<leader>u", group = "[U]tilities", icon = "󱌢" },
            { "<leader>c", group = "[C]opilot", icon = "" },
            -- Individual keymaps
            { "<leader>e", icon = "" },
            { "<leader>f", icon = "󰉠" },
            { "<leader>us", icon = "󱌢" },
        },
    },
}

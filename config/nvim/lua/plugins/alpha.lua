-- Dashboard for Neovim.
return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Set header highlight to accent color
        local accent = require("itero").accent()
        vim.api.nvim_set_hl(0, "IteroAccent", { fg = accent })

        -- Configure logo
        dashboard.section.header.opts.hl = "IteroAccent"
        dashboard.section.header.val = {
            "▗▄▄▄▖▗▄▄▄▖▗▄▄▄▖▗▄▄▖  ▗▄▖ ",
            "  █    █  ▐▌   ▐▌ ▐▌▐▌ ▐▌",
            "  █    █  ▐▛▀▀▘▐▛▀▚▖▐▌ ▐▌",
            "▗▄█▄▖  █  ▐▙▄▄▖▐▌ ▐▌▝▚▄▞▘",
            "                         ",
        }

        -- Set menu buttons
        dashboard.section.buttons.val = {
            dashboard.button("f", "󰈞  Find file", ":Telescope find_files <CR>"),
            dashboard.button("n", "󰝒  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("r", "󰄉  Recent files", ":Telescope oldfiles <CR>"),
            dashboard.button("g", "󰱼  Find text", ":Telescope live_grep <CR>"),
            dashboard.button("c", "󰒓  Config", ":e $MYVIMRC <CR>"),
            dashboard.button("q", "󰗼  Quit", ":qa<CR>"),
        }

        for _, button in ipairs(dashboard.section.buttons.val) do
            button.opts.hl = "Normal"
            button.opts.hl_shortcut = "Keyword"
        end

        -- Optional footer
        dashboard.section.footer.val = ""
        dashboard.section.footer.opts.hl = "Comment"

        alpha.setup(dashboard.opts)

        -- Disable folding on alpha buffer
        vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
}

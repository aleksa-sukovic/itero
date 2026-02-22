-- Adds git related signs to the gutter, as well as line blames.
-- See `:help gitsigns`.
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        current_line_blame = true,
        current_line_blame_opts = {
            delay = 250,
        },
        signs = {
            add = { text = "▎" },
            change = { text = "󰏫" },
            delete = { text = "▁" },
            topdelete = { text = "▔" },
            changedelete = { text = "󰍷" },
            untracked = { text = "󰋼" },
        },
        signs_staged = {
            add = { text = "┋" },
            change = { text = "" },
            delete = { text = "﹍" },
            topdelete = { text = "﹉" },
            changedelete = { text = "󱗛" },
        },
        on_attach = function(bufnr)
            local gitsigns = require("gitsigns")

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- Actions
            map("n", "<leader>gp", gitsigns.preview_hunk_inline, "Preview hunk")
            map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
            map("v", "<leader>gr", function()
                gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Reset hunk")
            map("n", "<leader>gs", gitsigns.stage_hunk, "Stage/unstage hunk")
            map("v", "<leader>gs", function()
                gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Stage hunk")
            map("n", "<leader>gb", gitsigns.toggle_current_line_blame, "Toggle line blame")
            map("n", "<leader>gd", gitsigns.diffthis, "Diff this")
            map("n", "<leader>gm", "<cmd>Gitsigns<CR>", "Open Gitsigns menu")
            map("n", "<leader>gl", function()
                gitsigns.detach(vim.api.nvim_get_current_buf())
                vim.schedule(function()
                    gitsigns.attach()
                end)
            end, "Force refresh git signs")

            -- Text object
            map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
        end,
    },
}

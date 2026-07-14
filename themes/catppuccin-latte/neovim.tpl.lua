return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "latte",
        color_overrides = {
            latte = {
                rosewater = "{{ rosewater }}",
                flamingo = "{{ flamingo }}",
                pink = "{{ pink }}",
                mauve = "{{ mauve }}",
                red = "{{ red }}",
                maroon = "{{ maroon }}",
                peach = "{{ peach }}",
                yellow = "{{ yellow }}",
                green = "{{ green }}",
                teal = "{{ teal }}",
                sky = "{{ sky }}",
                sapphire = "{{ sapphire }}",
                blue = "{{ blue }}",
                lavender = "{{ lavender }}",
                text = "{{ text }}",
                subtext1 = "{{ subtext1 }}",
                subtext0 = "{{ subtext0 }}",
                overlay2 = "{{ overlay2 }}",
                overlay1 = "{{ overlay1 }}",
                overlay0 = "{{ overlay0 }}",
                surface2 = "{{ surface2 }}",
                surface1 = "{{ surface1 }}",
                surface0 = "{{ surface0 }}",
                base = "{{ base }}",
                mantle = "{{ mantle }}",
                crust = "{{ crust }}",
            },
        },
        custom_highlights = function(colors)
            local accent = colors.{{ accent_name }}
            local panel = colors.mantle
            return {
                NormalFloat = { bg = panel },
                FloatBorder = { bg = panel, fg = colors.surface2 },
                Pmenu = { bg = panel },
                PmenuSel = { bg = colors.surface0, fg = colors.text },
                TelescopeNormal = { bg = panel },
                TelescopePromptNormal = { bg = panel },
                TelescopeResultsNormal = { bg = panel },
                TelescopePreviewNormal = { bg = panel },
                TelescopePromptBorder = { bg = panel, fg = accent },
                TelescopeResultsBorder = { bg = panel, fg = accent },
                TelescopePreviewBorder = { bg = panel, fg = accent },
                TelescopePromptTitle = { bg = panel, fg = accent },
                TelescopeResultsTitle = { bg = panel, fg = accent },
                TelescopePreviewTitle = { bg = panel, fg = accent },
            }
        end,
        integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            treesitter = true,
            notify = true,
            mini = { enabled = true },
            telescope = { enabled = true },
            lsp_trouble = true,
            which_key = true,
        },
    },
    config = function(_, opts)
        vim.g.itero_accent = "{{ accent }}"
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}

-- Autocompletion configuration.
return {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
        -- A massive collection of ready-made snippets for almost every language.
        "rafamadriz/friendly-snippets",
        -- Necessary for adding Neovim's own Lua API to the completion list.
        "folke/lazydev.nvim",
    },
    opts = {
        -- Allow use of <c-y> to accept. Additionally (goes for all presets), one can do:
        -- <c-space> (open menu/docs); <c-n>/<c-p> (next/previous item); <c-e> (hide menu);
        -- <c-k> (toggle signature help).
        keymap = {
            preset = "default",
        },

        -- Adjusts spacing for 'Nerd Font Mono' (or 'normal' for 'Nerd Font') so icons are aligned.
        appearance = { nerd_font_variant = "mono" },

        -- Documentation can be shown via <c-space>. With `auto_show = true` it's shown automatically.
        completion = {
            documentation = { auto_show = false, auto_show_delay_ms = 250 },
        },

        -- Define where suggestions come from and how they are handled.
        sources = {
            default = { "lsp", "path", "snippets", "lazydev" },
            providers = {
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
            },
        },

        -- Use Blink's built-in engine to expand templates.
        snippets = { preset = "default" },

        -- Use the high-performance Rust fuzzy matcher.
        -- See :h blink-cmp-config-fuzzy for more information.
        fuzzy = { implementation = "prefer_rust_with_warning" },

        -- Show function signatures (arguments) while you type.
        signature = { enabled = true },
    },
}

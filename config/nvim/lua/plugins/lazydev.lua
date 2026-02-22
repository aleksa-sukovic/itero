-- Makes Neovim understand its own Lua API (auto-complete 'vim.' commands).
-- N.B. We only load this in .lua files. System docs are loaded only when 'vim.uv' is used.
return {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
        library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}

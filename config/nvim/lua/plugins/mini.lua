-- Collection of various small independent plugins/modules.
return {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
        -- Extends text-objects (like digits, brackets, and quotes).
        -- Scans 500 lines to find targets and allows 'next'/'last' modifiers.
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup({ n_lines = 500 })

        -- Provides a grammar for managing surrounding pairs (brackets, quotes, tags).
        -- Examples:
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require("mini.surround").setup()
    end,
}

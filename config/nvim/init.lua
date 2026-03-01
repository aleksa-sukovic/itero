-- Set <space> as the leader key; see `:help mapleader`.
-- N.B. Must happen before plugins are loaded (otherwise wrong leader will be used).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Configure font support.
-- N.B. Make sure Nerd Fonts are installed and configured in the terminal emulator.
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o` and `help option-list` for a full list of options.

-- Show (relative) line numbers.
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode (e.g., useful when resizing splits).
vim.o.mouse = "a"

-- Don't show the mode, since it's already in the status line.
vim.o.showmode = false

-- Wrap long lines while maintaining their indentation level.
vim.o.breakindent = true

-- Save undo history between edits.
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Always show the line icon (e.g., git status).
vim.o.signcolumn = "yes"

-- Decrease update time.
vim.o.updatetime = 250

-- Decrease mapped sequence (multi-key shortcut) wait time.
vim.o.timeoutlen = 300

-- Configure how new splits should be opened.
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
-- See `:help 'list'` and `:help 'listchars'`
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as we type.
vim.o.inccommand = "split"

-- Highlights cursor line.
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Raise a confirmation dialog if performing an operation that fails due to unsaved changes.
-- See `:help 'confirm'`
vim.o.confirm = true

-- Auto-reload files when changed externally (e.g., git commit).
vim.o.autoread = true

-- Load per-project .nvim.lua files.
vim.o.exrc = true
vim.o.secure = true

-- Collapse the bottom bar when not in use.
vim.opt.cmdheight = 0

-- Global indentation defaults
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode.
-- See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps.
vim.keymap.set("n", "<leader>q", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Double-tap Escape to exit terminal mode and return to normal mode.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Toggle spell checking.
vim.keymap.set("n", "<leader>us", function()
    vim.o.spell = not vim.o.spell
end, { desc = "Toggle [S]pell checking" })

-- Disable unused providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text.
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("alsk-highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Check for external file changes when gaining focus or switching buffers.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    desc = "Check for external file changes",
    group = vim.api.nvim_create_augroup("alsk-checktime", { clear = true }),
    command = "checktime",
})

-- [[ Install `lazy.nvim` plugin manager ]]
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
-- Bootstrap lazy.nvim: downloads the manager if not found and adds it to the runtime path.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end

vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- Plugins are loaded from lua/plugins/ directory.
require("lazy").setup("plugins", {
    ui = {
        -- Use default Nerd Font icons (empty table {} triggers lazy.nvim's built-in icon set).
        icons = {},
    },
})

-- Modeline: force 4-space indentation for consistency with global settings (see `:help modeline`).
-- vim: ts=4 sts=4 sw=4 et

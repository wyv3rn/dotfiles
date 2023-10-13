-- TODO autoformat this
-- Plugin management with lazy
require("plugins")

-- Theming
vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin-frappe"

-- Line numbering
vim.opt.relativenumber = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.keymap.set('n', ';', '<cmd>nohlsearch<cr>', {desc = 'Clear highlightign'})

-- Line wrapping
vim.opt.wrap = true
vim.opt.breakindent = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Undo
vim.opt.undofile = true

-- System clipboard
vim.keymap.set({'v'}, '<C-c><C-c>', '"+y')
vim.keymap.set({'n', 'v'}, '<C-c><C-v>', '"+p')

-- Update and goto last file
vim.keymap.set({'n'}, '<tab>', '<cmd>update<cr><cmd>edit #<cr>')

-- WhichKey
local wk = require("which-key")
vim.g.mapleader = " "

wk.register({
    -- Space mode
    ["<leader>"] = {
        u = {"<cmd>update<cr>", "Write file iff modified"},
        x = {"<cmd>edit $MYVIMRC<cr>", "Open neovim config"},
        X = {"<cmd>update<cr><cmd>source $MYVIMRC<cr>", "Reload neovim config"},
        f = {"<cmd>Telescope find_files<cr>", "Find files"},
        b = {"<cmd>Telescope buffers<cr>", "Find buffers"},
        ["/"] = {"<cmd>Telescope live_grep<cr>", "Live grep"},
    }
})

-- TODO LSP setup and mappings (gd, <leader>t, ...)
-- TODO toggle comments
-- TODO .. including autoformat
-- TODO easymotions

-- System clipboard
vim.keymap.set({ 'v' }, '<C-c><C-c>', '"+y')
vim.keymap.set({ 'n', 'v' }, '<C-c><C-v>', '"+p')

-- Update and goto last file
vim.keymap.set({ 'n' }, '<tab>', '<cmd>update<cr><cmd>edit #<cr>')

-- Jumps
vim.keymap.set('n', '<C-t>', '<C-o>')

-- Compiling
vim.keymap.set('n', '<F4>', '<cmd>update<cr><cmd>!sh hemux-last<cr><cr>')
vim.keymap.set('n', '<F8>', '<cmd>update<cr><cmd>!sh hemux autobuild --mode check<cr><cr>')
vim.keymap.set('n', '<F9>', '<cmd>update<cr><cmd>!sh hemux autobuild --mode release<cr><cr>')
vim.keymap.set('n', '<F10>', '<cmd>update<cr><cmd>!sh hemux autobuild --mode debug<cr><cr>')
vim.keymap.set('n', '<F11>', '<cmd>update<cr><cmd>!sh hemux autobuild --mode test<cr><cr>')

-- Toggle comments in visual mode (normal mode -> WhichKey)
-- TODO can we make this during WhichKey register?
vim.keymap.set('v', '<leader>cc', ":CommentToggle<cr>", { desc = 'Toggle comments' })

-- Configure the rest with WhichKey
local wk = require("which-key")
local telescope = require("telescope.builtin")
local harpoon_ui = require("harpoon.ui")
local terminal = require("toggleterm.terminal").Terminal
local lazygit = terminal:new({
    cmd = "lazygit",
    hidden = true,
    direction = "float",
})

local lazygit_dotfiles = terminal:new({
    cmd = "lazygit --git-dir ~/.dotfiles.git/ --work-tree ~/",
    hidden = true,
    direction = "float"
})

wk.register({
    -- Space mode
    ["<leader>"] = {
        name = "Space mode",
        u = { "<cmd>update<cr>", "Write file iff modified" },
        x = { "<cmd>edit $MYVIMRC<cr>", "Open neovim config" },
        X = { "<cmd>update<cr><cmd>source $MYVIMRC<cr>", "Reload neovim config" },
        f = { telescope.find_files, "Find files" },
        b = { telescope.buffers, "Find buffers" },
        s = { telescope.lsp_dynamic_workspace_symbols, "Find symbols in workspace" },
        ["/"] = { telescope.live_grep, "Live grep" },
        ["*"] = { telescope.grep_string, "Grep string under cursor" },
        ["<leader>"] = { "<cmd>nohlsearch<cr>", "Clear everything!" },

        -- harpoon
        n = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", "Harpoon One" },
        r = { "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", "Harpoon Two" },
        t = { "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", "Harpoon Three" },
        d = { "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", "Harpoon Four" },

        -- Code mode
        c = {
            name = "Code mode",
            f = { "<cmd>lua vim.lsp.buf.format()<cr><cmd>update<cr>", "Format buffer" },
            h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show symbol information in hover" },
            a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Perform code action" },
            c = { "<cmd>CommentToggle<cr>", "Toggle comment" },
            r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename symbol under cursor" },
        },

        -- Toggle mode
        T = {
            name = "Toggle mode",
            w = { "<cmd>StripWhitespace<cr>", "Strip trailing whitespaces" }
        },

        -- Git
        g = {
            name = "Git mode",
            g = { function() lazygit:toggle() end, "Toggle lazygit terminal" },
            d = { function() lazygit_dotfiles:toggle() end, "Toggle lazygit terminal for dotfiles" },
            b = { "<cmd>ToggleBlame<cr>", "Toggle git blame" },
        },

        --  More harpoon
        h = {
            h = { harpoon_ui.toggle_quick_menu, "Harpoon menu" },
            a = { require("harpoon.mark").add_file, "Add current file" },
        },
    },

    -- GoTo mode
    g = {
        name = "GoTo mode",
        d = { telescope.lsp_definitions, "GoTo definition" },
        r = { telescope.lsp_references, "GoTo references" },
        t = { telescope.lsp_type_definitions, "GoTo type definition" },
        i = { telescope.lsp_implementations, "GoTo implementation" },
    },

    -- Prev/next
    ["]"] = {
        d = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "GoTo next diagnostic" },
    },

    ["["] = {
        d = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "GoTo prev diagnostic" },
    }
})

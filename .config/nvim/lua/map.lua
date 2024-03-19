-- More leaders! (Note: does not seem to work with vim.keymap.set)
vim.cmd("nmap <cr> <leader>")
vim.cmd("vmap <cr> <leader>")

-- TODO use more vim.cmd and function () ... end instead of "<cmd>....<cr>"
-- System clipboard
vim.keymap.set({ 'v' }, '<leader>y', '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = "Paste from system clipboard" })

-- Repeated pasting in visual mode
vim.keymap.set({ 'x' }, 'p', '"_dP', { desc = "Fearless paste in visual mode" })

-- Jumps
vim.keymap.set('n', '<C-i>', '<C-i>zz')
vim.keymap.set('n', '<C-t>', '<C-o>zz')

-- Better half-page scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Compiling
vim.keymap.set('n', '<F4>', '<cmd>update<cr><cmd>!hemux-last<cr><cr>')
vim.keymap.set('n', '<F8>', '<cmd>update<cr><cmd>!hemux autobuild --mode check<cr><cr>')
vim.keymap.set('n', '<F9>', '<cmd>update<cr><cmd>!hemux autobuild --mode release<cr><cr>')
vim.keymap.set('n', '<F10>', '<cmd>update<cr><cmd>!hemux autobuild --mode debug<cr><cr>')
vim.keymap.set('n', '<F11>', '<cmd>update<cr><cmd>!hemux autobuild --mode test<cr><cr>')

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
        x = { "<cmd>edit $MYVIMRC<cr>", "Open neovim config" },
        X = { "<cmd>update<cr><cmd>source $MYVIMRC<cr>", "Reload neovim config" },
        f = { telescope.find_files, "Find files" },
        b = { telescope.buffers, "Find buffers" },
        s = { telescope.lsp_dynamic_workspace_symbols, "Find symbols in workspace" },
        u = { vim.cmd.UndotreeToggle, "Toggle undo tree" },
        ["/"] = { telescope.live_grep, "Live grep" },
        ["*"] = { telescope.grep_string, "Grep string under cursor" },
        ["?"] = { telescope.help_tags, "Find help" },
        ["<Tab>"] = { "<cmd>update<cr><cmd>edit #<cr>", "Go to last file" },
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
            w = { "<cmd>StripWhitespace<cr>", "Strip trailing whitespaces" },
        },

        -- Git
        g = {
            name = "Git mode",
            g = { function() lazygit:toggle() end, "Toggle lazygit terminal" },
            d = { function() lazygit_dotfiles:toggle() end, "Toggle lazygit terminal for dotfiles" },
            b = { "<cmd>ToggleBlame virtual<cr>", "Toggle git blame" },
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
        d = { telescope.lsp_definitions, "Go to definition" },
        D = { telescope.lsp_type_definitions, "Go to type definition" },
        r = { telescope.lsp_references, "Go to references" },
        i = { telescope.lsp_implementations, "Go to implementation" },
        h = { "<cmd>ClangdSwitchSourceHeader<cr>", "Go to header/source file" },
        w = { "<C-w><C-p>", "Go to previous window" },
        ["<Left>"] = { "<C-w>h", "Go to left window" },
        ["<Right>"] = { "<C-w>l", "Go to right window" },
        ["<Up>"] = { "<C-w>k", "Go to upper window" },
        ["<Down>"] = { "<C-w>j", "Go to lower window" },
    },

    -- Prev/next
    ["]"] = {
        d = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "GoTo next diagnostic" },
    },

    ["["] = {
        d = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "GoTo prev diagnostic" },
    }
})

-- System clipboard
vim.keymap.set({ 'v' }, '<C-c><C-c>', '"+y')
vim.keymap.set({ 'n', 'v' }, '<C-c><C-v>', '"+p')

-- Update and goto last file
vim.keymap.set({ 'n' }, '<tab>', '<cmd>update<cr><cmd>edit #<cr>')

-- Remove search highlighting
vim.keymap.set('n', ';', '<cmd>nohlsearch<cr>', { desc = 'Clear highlighting' })

-- Jumps
vim.keymap.set('n', '<C-t>', '<C-o>')

-- Compiling
vim.keymap.set('n', '<F4>', '<cmd>!sh hemux-last<cr><cr>')
vim.keymap.set('n', '<F8>', '<cmd>!sh hemux autobuild --check<cr><cr>')
vim.keymap.set('n', '<F9>', '<cmd>!sh hemux autobuild --release<cr><cr>')
vim.keymap.set('n', '<F10>', '<cmd>!sh hemux autobuild --debug<cr><cr>')
vim.keymap.set('n', '<F11>', '<cmd>!sh hemux autobuild --test<cr><cr>')

-- Toggle comments in visual mode (normal mode -> WhichKey)
-- TODO can we make this during WhichKey register?
vim.keymap.set('v', '<leader>cc', ":CommentToggle<cr>", { desc = 'Toggle comments' })

-- Configure the rest with WhichKey
local wk = require("which-key")
local telescope = require("telescope.builtin")

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
        h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show symbol information in hover" },
        ["/"] = { telescope.live_grep, "Live grep" },
        ["*"] = { telescope.grep_string, "Grep string under cursor" },

        -- Code mode
        c = {
            name = "Code mode",
            f = { "<cmd>lua vim.lsp.buf.format()<cr><cmd>update<cr>", "Format buffer" },
            s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature information in hover" },
            a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Perform code action" },
            c = { "<cmd>CommentToggle<cr>", "Toggle comment" },
            r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename symbol under cursor" },
        },

        -- Toggle mode
        t = {
            name = "Toggle mode",
            b = { "<cmd>ToggleBlame<cr>", "Toggle git blame" },
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

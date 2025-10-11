-- More leaders! (Note: does not seem to work with vim.keymap.set)
vim.cmd("nmap <cr> <leader>")
vim.cmd("vmap <cr> <leader>")

-- TODO use more vim.cmd and function () ... end instead of "<cmd>....<cr>"

-- Jumps
vim.keymap.set('n', '<C-i>', '<C-i>zz')
vim.keymap.set('n', '<C-t>', '<C-o>zz')

-- Better half-page scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Easier built-in completion and snippets
local function cmap(from, menu, snippet, default)
   vim.keymap.set("i", from, function()
      if vim.fn.pumvisible() == 1 then
         return menu
      elseif vim.snippet.active() then
         return snippet or from
      else
         return default or from
      end
   end, { expr = true })
end

local snippet_jump_fwd = "<Cmd>lua vim.snippet.jump(1)<CR>"
local snippet_jump_bwd = "<Cmd>lua vim.snippet.jump(-1)<CR>"

cmap("<Tab>", "<C-y>")
cmap("<C-g>", "<C-y>", "<C-x><C-o>", "<C-x><C-o>")
cmap("<C-f>", snippet_jump_fwd, snippet_jump_fwd)
cmap("<C-b>", "<C-b>", snippet_jump_bwd)
cmap("<C-l>", "<C-y>", "<C-x><C-l>", "<C-x><C-l>")

-- Compiling
local async_make = require("async_make")
vim.keymap.set("n", "<F8>", function() async_make.make("autobuild --no-tty --mode check", { autosave = true }) end)
vim.keymap.set("n", "<F9>", function() async_make.make("autobuild --no-tty --mode release", { autosave = true }) end)
vim.keymap.set("n", "<F10>", function() async_make.make("autobuild --no-tty --mode debug", { autosave = true }) end)
vim.keymap.set("n", "<F11>", function() async_make.make("autobuild --no-tty --mode test", { autosave = true }) end)

-- Builtin terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Configure the rest with WhichKey
local wk = require("which-key")
local telescope = require("telescope.builtin")
local terminal = require("toggleterm.terminal").Terminal
local oil = require("oil")

local scratch_term = terminal:new({
   hidden = true,
   direction = "float",
})

local calc_term = terminal:new({
   cmd = "ghci",
   hidden = true,
   direction = "float",
})


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

local next_diagnostic = function() vim.diagnostic.jump({ count = 1, float = true }) end
local prev_diagnostic = function() vim.diagnostic.jump({ count = -1, float = true }) end

wk.add({
   { "<leader>",         group = "Space mode" },
   { "<leader><Esc>",    "<cmd>nohlsearch<cr>",                              desc = "Clear everything!" },
   { "<leader>f",        telescope.find_files,                               desc = "Find files" },
   { "<leader>*",        telescope.grep_string,                              desc = "Grep string under cursor" },
   { "<leader>/",        telescope.live_grep,                                desc = "Live grep" },
   { "<leader><Tab>",    "<cmd>update<cr><cmd>edit #<cr>",                   desc = "Go to last buffer" },
   { "<leader>?",        telescope.help_tags,                                desc = "Find help" },
   { "<leader>b",        telescope.buffers,                                  desc = "Find buffers" },
   { "<leader>u",        vim.cmd.UndotreeToggle,                             desc = "Toggle undo tree" },
   { "<leader>-",        oil.open_float,                                     desc = "Open Oil in directory of current buffer" },
   { "<leader>_",        function() oil.open_float(vim.uv.cwd()) end,        desc = "Open Oil in cwd" },
   { "<leader>h",        vim.lsp.buf.hover,                                  desc = "Show symbol information in hover" },
   { "<leader><leader>", "<cmd>lua vim.lsp.buf.format()<cr><cmd>update<cr>", desc = "Format buffer" },

   { "<leader>g",        group = "Git mode" },
   { "<leader>gb",       "<cmd>ToggleBlame virtual<cr>",                     desc = "Toggle git blame" },
   { "<leader>gg",       function() lazygit:toggle() end,                    desc = "Toggle lazygit terminal" },
   { "<leader>gd",       function() lazygit_dotfiles:toggle() end,           desc = "Toggle lazygit terminal for dotfiles" },

   { "g",                group = "GoTo mode" },
   { "gd",               telescope.lsp_definitions,                          desc = "Go to definition" },
   { "gy",               telescope.lsp_type_definitions,                     desc = "Go to type definition" },
   { "gh",               "<cmd>LspClangdSwitchSourceHeader<cr>",             desc = "Go to header/source file" },
   { "grr",              telescope.lsp_references,                           desc = "Go to references" },
   { "gs",               telescope.lsp_document_symbols,                     desc = "Find symbols in buffer" },
   { "gS",               telescope.lsp_dynamic_workspace_symbols,            desc = "Find symbols in workspace" },
   { "gD",               telescope.diagnostics,                              desc = "Find diagnostics" },
   { "ga",               vim.lsp.buf.code_action,                            desc = "Perform code action" },
   { "gq",               "<cmd>tab copen<cr>",                               desc = "Open quickfix list in new tab" },

   { "<leader>t",        group = "Toggle mode" },
   { "<leader>tt",       function() scratch_term:toggle() end,               desc = "Toggle floating scratch terminal" },
   { "<leader>tc",       function() calc_term:toggle() end,                  desc = "Toggle floating calculator terminal" },
   { "<leader>tw",       "<cmd>StripWhitespace<cr>",                         desc = "Strip trailing whitespaces" },


   { "[d",               prev_diagnostic,                                    desc = "GoTo prev diagnostic" },
   { "]d",               next_diagnostic,                                    desc = "GoTo next diagnostic" },
   { "[c",               "<cmd>cprev<cr>",                                   desc = "GoTo prev quickfix" },
   { "]c",               "<cmd>cnext<cr>",                                   desc = "GoTo next quickfix" },
   { "[b",               "<cmd>update<cr><cmd>bprev<cr>",                    desc = "Go to previous buffer" },
   { "]b",               "<cmd>update<cr><cmd>bnext<cr>",                    desc = "Go to next buffer" },
})

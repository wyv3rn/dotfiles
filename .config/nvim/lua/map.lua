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
      if vim.fn.pumvisible() ~= 0 then
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
cmap("<C-f>", snippet_jump_fwd, snippet_jump_fwd)
cmap("<C-b>", "<C-b>", snippet_jump_bwd)
cmap("<C-l>", "<C-y>", "<C-x><C-l>", "<C-x><C-l>")

-- Compiling
local async_make = require("async_make")
vim.keymap.set("n", "<F8>", function() async_make.make("autobuild --no-tty --mode check", { autosave = true }) end)
vim.keymap.set("n", "<F9>", function() async_make.make("autobuild --no-tty --mode release", { autosave = true }) end)
vim.keymap.set("n", "<F10>", function() async_make.make("autobuild --no-tty --mode debug", { autosave = true }) end)
vim.keymap.set("n", "<F11>", function() async_make.make("autobuild --no-tty --mode open", { autosave = true }) end)

-- Builtin terminal
vim.keymap.set('t', '<C-g>', '<C-\\><C-n>')

-- Configure the rest with WhichKey
local wk = require("which-key")
local telescope = require("telescope.builtin")
local terminal = require("toggleterm.terminal").Terminal
local oil = require("oil")
local conform = require("conform")

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

-- Jumping to diagnostics with [d, ]d is basically default, but w want auto-hover (float = true), too
local next_diagnostic = function() vim.diagnostic.jump({ count = 1, float = true }) end
local prev_diagnostic = function() vim.diagnostic.jump({ count = -1, float = true }) end

local format_and_save = function()
   conform.format()
   vim.cmd("update")
end

local toggle_inlay_hints = function()
   vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

-- Avoid anonymous function boilerplate while mapping complex vim.cmd
-- And as a bonus: allow chained commands via varargs
local function vimcmd(...)
   local arg = { ... }
   return function()
      for _, cmd in ipairs(arg) do
         vim.cmd(cmd)
      end
   end
end

wk.add({
   { "<leader>",         group = "Space mode" },
   { "<leader><Esc>",    vim.cmd.nohlsearch,                          desc = "Clear everything!" },
   { "<leader>f",        telescope.find_files,                        desc = "Find files" },
   { "<leader>*",        telescope.grep_string,                       desc = "Grep string under cursor" },
   { "<leader>/",        telescope.live_grep,                         desc = "Live grep" },
   { "<leader><Tab>",    vimcmd("update", "edit #"),                  desc = "Go to last buffer" },
   { "<leader>?",        telescope.help_tags,                         desc = "Find help" },
   { "<leader>b",        telescope.buffers,                           desc = "Find buffers" },
   { "<leader>r",        telescope.oldfiles,                          desc = "Find in recent files" },
   { "<leader>-",        oil.open_float,                              desc = "Open Oil in directory of current buffer" },
   { "<leader>_",        function() oil.open_float(vim.uv.cwd()) end, desc = "Open Oil in cwd" },
   { "<leader>h",        vim.lsp.buf.hover,                           desc = "Show symbol information in hover" },
   { "<leader><leader>", format_and_save,                             desc = "Format buffer" },

   { "<leader>g",        group = "Git mode" },
   { "<leader>gb",       vimcmd("ToggleBlame virtual"),               desc = "Toggle git blame" },
   { "<leader>gg",       function() lazygit:toggle() end,             desc = "Toggle lazygit terminal" },
   { "<leader>gd",       function() lazygit_dotfiles:toggle() end,    desc = "Toggle lazygit terminal for dotfiles" },

   { "g",                group = "GoTo mode" },
   { "gd",               telescope.lsp_definitions,                   desc = "Go to definition" },
   { "gy",               telescope.lsp_type_definitions,              desc = "Go to type definition" },
   { "gh",               vimcmd("LspClangdSwitchSourceHeader"),       desc = "Go to header/source file" },
   { "grr",              telescope.lsp_references,                    desc = "Go to references" },
   { "gs",               telescope.lsp_document_symbols,              desc = "Find symbols in buffer" },
   { "gS",               telescope.lsp_dynamic_workspace_symbols,     desc = "Find symbols in workspace" },
   { "gD",               telescope.diagnostics,                       desc = "Find diagnostics" },
   { "ga",               vim.lsp.buf.code_action,                     desc = "Perform code action" },
   { "gq",               vimcmd("tab copen"),                         desc = "Open quickfix list in new tab" },

   { "<leader>t",        group = "Toggle mode" },
   { "<leader>tw",       vimcmd("StripWhitespace"),                   desc = "Strip trailing whitespaces" },
   { "<leader>ti",       toggle_inlay_hints,                          desc = "Toggle inlay hints" },

   { "[d",               prev_diagnostic,                             desc = "GoTo prev diagnostic" },
   { "]d",               next_diagnostic,                             desc = "GoTo next diagnostic" },
})

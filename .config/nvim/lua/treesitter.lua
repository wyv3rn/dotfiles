local treesitter = require("nvim-treesitter")
local langs = {
   "c",
   "lua",
   "rust",
   "bash",
   "python",
   "javascript",
   "typescript",
   "go",
   "bibtex",
}

-- TODO make it work on windows (install C++ toolchain -> cargo install tree-sitter)
if vim.fn.has("windows") == 0 then
   treesitter.install(langs)
end

table.insert(langs, 1, "tex")
table.insert(langs, 1, "bib")

vim.api.nvim_create_autocmd("FileType", {
   pattern = langs,
   callback = function() vim.treesitter.start() end
})

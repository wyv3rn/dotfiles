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

treesitter.install(langs)

table.insert(langs, 1, "tex")
table.insert(langs, 1, "bib")

vim.api.nvim_create_autocmd("FileType", {
   pattern = langs,
   callback = function() vim.treesitter.start() end
})

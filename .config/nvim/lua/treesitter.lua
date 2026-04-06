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
}

treesitter.install(langs)

table.insert(langs, 1, "tex")
vim.api.nvim_create_autocmd("FileType", {
   pattern = langs,
   callback = function() vim.treesitter.start() end
})

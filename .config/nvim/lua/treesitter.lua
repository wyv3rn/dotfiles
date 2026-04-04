local treesitter = require("nvim-treesitter")
local langs = {
   "c",
   "lua",
   "vim",
   "vimdoc",
   "query",
   "comment",
   "rust",
   "bash",
   "python",
   "javascript",
   "typescript",
   "nu",
}

treesitter.setup({
   ensure_installed = langs,
   highlight = {
      enable = true,
   },
   indent = {
      enable = true,
   },
})

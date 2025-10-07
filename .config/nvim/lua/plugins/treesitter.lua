return {
   "nvim-treesitter/nvim-treesitter",
   dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects"
   },
   build = ":TSUpdate",
   config = function()
      local treesitter = require("nvim-treesitter.configs")
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
      if vim.loop.os_uname().sysname ~= "Windows_NT" then
         table.insert(langs, "latex")
      end
      treesitter.setup({
         ensure_installed = langs,
         sync_install = false,
         auto_install = true,
         ignore_install = {},
         highlight = {
            enable = true,
         },
         indent = {
            enable = true,
         },
         textobjects = {
            select = {
               enable = true,
               lookahead = true,
               keymaps = {
                  ["af"] = { query = "@function.outer", desc = "function" },
                  ["if"] = { query = "@function.inner", desc = "function" },
                  ["ac"] = { query = "@class.outer", desc = "class" },
                  ["ic"] = { query = "@class.inner", desc = "class" },
               },
            },
         }
      })
   end
}

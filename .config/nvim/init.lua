-- Plugins
vim.pack.add({
   "https://github.com/catppuccin/nvim",
   "https://github.com/nvim-lualine/lualine.nvim",
   "https://github.com/nvim-lua/plenary.nvim", -- required for telescope
   "https://github.com/nvim-telescope/telescope.nvim",
   "https://github.com/folke/which-key.nvim",
   "https://github.com/stevearc/oil.nvim",
   "https://github.com/barreiroleo/ltex_extra.nvim",
   "https://github.com/neovim/nvim-lspconfig",
   "https://github.com/stevearc/conform.nvim",
   "https://github.com/nvim-treesitter/nvim-treesitter", -- note: requires :TSUpdate on update
   "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
   "https://github.com/ntpeters/vim-better-whitespace",
   "https://github.com/farmergreg/vim-lastplace",
   "https://github.com/miversen33/sunglasses.nvim",
   "https://github.com/wyv3rn/latex-abbrify.nvim",
   { src = "https://github.com/wyv3rn/blame.nvim", version = "fix-cwd" }
})

-- Basic vim config
require("set")

-- Self explaining
require("autocmd")

-- colorscheme, lualine and sunglasses :)
vim.opt.termguicolors = true
vim.cmd.colorscheme("catppuccin-frappe")
require("lualine").setup()
require("sunglasses").setup({
   filter_type = "SHADE",
   filter_percent = 0.07,
   excluded_filetypes = {},
   excluded_highlights = {
      { "lualine_.*", glob = true },
   }
})

require("telescope").setup({
   defaults = {
      layout_config = {
         horizontal = { width = 9001, height = 9001 }
      }
   }
})

require("oil").setup({
   float = {
      padding = 3,
   },
   view_options = {
      show_hidden = true,
   }
})

require("blame").setup({
   virtual_style = "right_aligned",
   merge_consecutive = false,
})

require('latex-abbrify').setup()

-- plugins with more complex config
require("lsp")
require("treesitter")

-- Key mapping
require("map")

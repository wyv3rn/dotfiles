return {
   "catppuccin/nvim",
   lazy = false,
   priority = 1000,
   config = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme "catppuccin-frappe"
   end,
}

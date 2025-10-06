return {
   'nvim-telescope/telescope.nvim',
   dependencies = {
      'nvim-lua/plenary.nvim',
   },
   config = function()
      require("telescope").setup({
         defaults = {
            layout_config = {
               horizontal = { width = 9001, height = 9001 }
            }
         }
      })
   end
}

return {
   "wyv3rn/blame.nvim",
   branch = "fix-cwd",
   config = function()
      require("blame").setup({
         virtual_style = "right_aligned",
         merge_consecutive = false,
      })
   end
}

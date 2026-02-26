vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
   pattern = { "*.typ" },
   callback = function()
      vim.cmd "silent write"
   end,
})

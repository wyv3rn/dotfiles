vim.api.nvim_create_autocmd("BufEnter", {
   buffer = 0,
   command = "wincmd L",
})

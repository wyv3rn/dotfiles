-- Autoclose
local pairs = {
   ["{"] = "{}",
   ["("] = "()",
   ["["] = "[]",
}
vim.api.nvim_create_autocmd("InsertCharPre", {
   callback = function()
      local pair = pairs[vim.v.char]
      if pair then
         local keys = vim.api.nvim_replace_termcodes("<Left>", true, false, true)
         vim.api.nvim_feedkeys(keys, "n", false)
         vim.v.char = pair
      end
   end
})

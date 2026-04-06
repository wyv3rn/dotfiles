-- Maximum scrollback
vim.opt.scrollback = 1000000

-- Why would you not want to start in insert mode for terminals?
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
   pattern = { "*" },
   callback = function()
      if vim.opt.buftype:get() == "terminal" then
         vim.cmd(":startinsert")
      end
   end
})

-- Yes, really close it
-- (but save the window by switching away from the terminal buffer first)
vim.api.nvim_create_autocmd("TermClose", {
   callback = function()
      if vim.opt.buftype:get() == "terminal" then
         local term_buf = vim.api.nvim_get_current_buf()
         vim.cmd("e #")
         vim.cmd("bdel! " .. term_buf)
      end
   end
})

local quickterm_size = 24
local exclude_term_patterns = { "typst watch" }

local M = {}

function M.open_quickterm()
   for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      local buffer_name = vim.api.nvim_buf_get_name(buffer)
      if (string.sub(buffer_name, 1, 7) == "term://") then
         for _, pattern in pairs(exclude_term_patterns) do
            if string.find(buffer_name, pattern) ~= nil then
               goto continue
            end
         end
         vim.cmd(quickterm_size .. "split #" .. buffer)
         return
      end
      ::continue::
   end
   vim.cmd(quickterm_size .. "split | term")
end

return M

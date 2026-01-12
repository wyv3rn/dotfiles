-- Autoclose
local open_to_pair = {
   ["{"] = "{}",
   ["("] = "()",
   ["["] = "[]",
}

local close_to_pair = {
   ["}"] = "{}",
   [")"] = "()",
   ["]"] = "[]",
}

local function str_at(s, i)
   return s:sub(i, i)
end

local function feed_keys(str)
   local keys = vim.api.nvim_replace_termcodes(str, true, false, true)
   vim.api.nvim_feedkeys(keys, "n", false)
end

-- get some info about where we are at
local function pos()
   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
   local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
   local line_len = #line
   local at_line_end = col == line_len

   local in_ac = false
   if at_line_end and col >= 3 then
      in_ac = line:sub(col - 2, col) == "\\ac" or line:sub(col - 3, col) == "\\acp"
   end

   local in_pair = false
   local next_char = nil
   if col > 0 and col < line_len then
      next_char = str_at(line, col + 1)
      for _, pair in pairs(open_to_pair) do
         if str_at(line, col) == str_at(pair, 1) and str_at(line, col + 1) == str_at(pair, 2) then
            in_pair = true
         end
      end
   end
   return at_line_end, in_pair, in_ac, next_char
end

-- autoclose
vim.api.nvim_create_autocmd("InsertCharPre", {
   callback = function()
      local at_line_end, in_pair, in_ac, next_char = pos()
      local pair = open_to_pair[vim.v.char]

      local autoclose = pair ~= nil and (at_line_end or in_pair) and not in_ac
      local skip_closing = close_to_pair[vim.v.char] ~= nil and next_char == vim.v.char

      if skip_closing then
         feed_keys("<Right>")
         vim.v.char = ''
         return
      elseif autoclose then
         feed_keys("<Left>")
         vim.v.char = pair
      end
   end
})

-- smart newline matching autoclose
local function smart_newline()
   if vim.fn.pumvisible() ~= 0 then
      feed_keys("<C-e>")
   end
   feed_keys("<CR>")
   local _, in_pair, _, _ = pos()
   if in_pair then
      feed_keys("<C-o>O")
   end
end

vim.keymap.set("i", "<CR>", smart_newline)

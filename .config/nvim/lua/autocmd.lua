-- Autoclose
local open_to_close = {
   ["{"] = "}",
   ["("] = ")",
   ["["] = "]",
}

local function str_at(s, i)
   return s:sub(i, i)
end

local function feed_keys(str)
   local keys = vim.api.nvim_replace_termcodes(str, true, false, true)
   vim.api.nvim_feedkeys(keys, "n", false)
end

-- get some info about where we are at, mainly related to autoclose pairs
local function pos()
   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
   local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
   local line_len = #line

   local line_end_missing_closing = nil
   if col == line_len then
      line_end_missing_closing = open_to_close[str_at(line, col)]
   end

   local in_pair = false
   if col > 0 and col < line_len then
      for open, close in pairs(open_to_close) do
         if str_at(line, col) == open and str_at(line, col + 1) == close then
            in_pair = true
         end
      end
   end
   return in_pair, line_end_missing_closing
end

-- smart newline with autoclose
local function smart_newline()
   if vim.fn.pumvisible() ~= 0 then
      feed_keys("<C-e>")
   end
   local in_pair, line_end_missing_closing = pos()

   if line_end_missing_closing then
      feed_keys(line_end_missing_closing .. "<Left>")
   end

   feed_keys("<CR>")

   if in_pair or line_end_missing_closing then
      feed_keys("<C-o>O")
   end
end

vim.keymap.set("i", "<CR>", smart_newline)

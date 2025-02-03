return {
   'm4xshen/autoclose.nvim',
   config = function()
      require("autoclose").setup({
         keys = {
            ["'"] = { escape = true, close = false, pair = "''" },
            ["$"] = { escape = true, close = true, pair = "$$", enabled_filetypes = { "tex", "markdown" } },
         },
         options = {
            disable_when_touch = true,
            touch_regex = "[%w%s=%(%)%[%]{}\"]"
         }
      })
   end
}

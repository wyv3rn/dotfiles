return {
   'm4xshen/autoclose.nvim',
   config = function()
      require("autoclose").setup({
         keys = {
            ["'"] = { escape = true, close = false, pair = "''"},
         },
         options = {
            disable_when_touch = true,
            touch_regex = "[%w%s=%(%[%]%)\"]"
         }
      })
   end
}

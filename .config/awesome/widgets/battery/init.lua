local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local timer = require("gears.timer")

local setmetatable = setmetatable
local textbattery = { mt = {} }

local function new()
   local w = textbox()

   local function textbattery_update_cb()
      awful.spawn.easy_async("avg-battery", function(stdout)
         w:set_markup(stdout)
      end
      )
   end
   timer { timeout = 30, call_now = true, autostart = true, callback = textbattery_update_cb }
   return w
end

function textbattery.mt:__call(...)
   return new(...)
end

return setmetatable(textbattery, textbattery.mt)

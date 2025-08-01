local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local timer = require("gears.timer")

local setmetatable = setmetatable
local textbattery = { mt = {} }

local function new(cmd, timeout)
   local w = textbox()
   local function textbattery_update_cb()
      awful.spawn.easy_async(cmd, function(stdout)
         w:set_markup(stdout)
      end)
   end
   timer { timeout = timeout, call_now = true, autostart = true, callback = textbattery_update_cb }
   return w
end

function textbattery.mt:__call(...)
   return new(...)
end

return setmetatable(textbattery, textbattery.mt)

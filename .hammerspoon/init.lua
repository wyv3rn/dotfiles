package.path = package.path .. ";../.config/lwm/?.lua"

-- implement LWM API
local wm = {}

function wm.notify(msg)
   hs.alert(msg)
end

function wm.os()
   return "darwin"
end

function wm.bind(mods, key, fun, fallback_mod)
   hs.hotkey.bind(mods, key, fun)

   if fallback_mod then
      local fallback_modifiers = {}
      for i, val in ipairs(mods) do
         fallback_modifiers[i] = val
      end
      table.insert(fallback_modifiers, fallback_mod)
      hs.hotkey.bind(fallback_modifiers, key, function()
         hs.eventtap.keyStroke(mods, key, 0, hs.application.frontmostApplication())
      end)
   end
end

function wm.keystroke_to_app(mods, key, except, alt_mods, alt_key)
   except = except or {}
   local app = hs.application.frontmostApplication()
   if app == nil then
      return
   end
   for _, e in ipairs(except) do
      if app:name() == e then
         hs.eventtap.keyStroke(alt_mods, alt_key, 0, app)
         return
      end
   end
   hs.eventtap.keyStroke(mods, key, 0, app)
end

function wm.execute(cmd)
   return hs.execute(cmd, true)
end

function wm.window_id(win)
   return win:id()
end

function wm.window_title(win)
   return win:title()
end

function wm.window_app_name(win)
   local app = win:application()
   if app == nil then
      return "unknown"
   else
      return app:name()
   end
end

function wm.position(win)
   local frame = win:frame()
   return { x = frame.x, y = frame.y, width = frame.w, height = frame.h }
end

function wm.work_area(win)
   local sframe = win:screen():frame()
   return {
      x = sframe.x,
      y = sframe.y,
      width = sframe.w,
      height = sframe.h
   }
end

function wm.move_win(win, pos)
   local frame = hs.geometry({ x = pos.x, y = pos.y, w = pos.width, h = pos.height })
   win:setFrame(frame)
end

function wm.all_windows()
   return hs.window.allWindows()
end

function wm.ordered_windows()
   return hs.window.orderedWindows()
end

function wm.focused_win()
   return hs.window.focusedWindow()
end

function wm.windows_at_focused()
   local windows = {}
   local focused_screen_id = hs.window.focusedWindow():screen():id()
   local space_filter = hs.window.filter.defaultCurrentSpace
   for _, win in ipairs(space_filter:getWindows()) do
      if win:screen():id() == focused_screen_id then
         table.insert(windows, win)
      end
   end
   return windows
end

function wm.close(win)
   win:close()
end

function wm.focus_and_raise(win)
   win:raise()
   win:focus()
end

function wm.focus_and_raise_app(app_name)
   local app = hs.application.find(app_name)
   if app == nil then return end
   app:activate()
   return app:focusedWindow()
end

function wm.maximize(win)
   win:maximize()
end

function wm.restart()
   hs.reload()
end

-- Disable animations
hs.window.animationDuration = 0

-- hotfixing hs.window:setFrame, see https://github.com/Hammerspoon/hammerspoon/issues/3224
local function axHotfix(win)
   local fallback = function() end
   if not win then return fallback end
   local axApp = hs.axuielement.applicationElement(win:application())
   if not axApp then return fallback end

   local wasEnhanced = axApp.AXEnhancedUserInterface
   axApp.AXEnhancedUserInterface = false

   return function()
      hs.timer.doAfter(hs.window.animationDuration * 2, function()
         axApp.AXEnhancedUserInterface = wasEnhanced
      end)
   end
end

local function withAxHotfix(fn, win_arg_idx)
   if not win_arg_idx then win_arg_idx = 1 end
   return function(...)
      local revert = axHotfix(select(win_arg_idx, ...))
      fn(...)
      revert()
   end
end

local window_mt = hs.getObjectMetatable("hs.window")
if window_mt ~= nil then
   window_mt.setFrame = withAxHotfix(window_mt.setFrame)
end
-- end of hotfixing

-- Spoon for LSP support
hs.loadSpoon("EmmyLua")

local lwm = require("lwm").new(wm, 0.45)
require("keymap").map(lwm)

lwm:notify("Hammerspoon!")

package.path = package.path .. ";../.config/lwm/?.lua"

-- implement LWM API
Wm = {}

function Wm.notify(msg)
   hs.alert(msg)
end

function Wm.os()
   return "darwin"
end

function Wm.bind(mods, key, fun, fallback_mod)
   hs.hotkey.bind(mods, key, fun)

   if fallback_mod then
      local fallback_modifiers = {}
      for i, val in ipairs(mods) do
         fallback_modifiers[i] = val
      end
      table.insert(fallback_modifiers, fallback_mod)
      hs.hotkey.bind(fallback_modifiers, key, function()
         local app = hs.application.frontmostApplication()
         if app ~= nil then
            hs.eventtap.keyStroke(mods, key, 0, app)
         end
      end)
   end
end

function Wm.keystroke_to_app(mods, key, except, alt_mods, alt_key)
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

function Wm.spawn(cmd, with_user_env)
   with_user_env = with_user_env or true
   -- TODO not ideal, because this actually blocks
   return hs.execute(cmd, with_user_env)
end

function Wm.callback_on_create(fun)
   hs.window.filter.defaultCurrentSpace:subscribe(hs.window.filter.windowInCurrentSpace, fun)
end

function Wm.screen_id(screen)
   if not screen then
      return nil
   else
      return screen:id()
   end
end

function Wm.window_id(win)
   return win:id()
end

function Wm.window_title(win)
   return win:title()
end

function Wm.window_app_name(win)
   local app = win:application()
   if app == nil then
      return "unknown"
   else
      return app:name()
   end
end

function Wm.position(win)
   local frame = win:frame()
   return { x = frame.x, y = frame.y, width = frame.w, height = frame.h }
end

function Wm.work_area(win)
   local sframe = win:screen():frame()
   return {
      x = sframe.x,
      y = sframe.y,
      width = sframe.w,
      height = sframe.h
   }
end

function Wm.move_win(win, pos)
   local frame = hs.geometry({ x = pos.x, y = pos.y, w = pos.width, h = pos.height })
   win:setFrame(frame)
end

function Wm.toggle_fullscreen(win)
   win:toggleFullScreen()
end

function Wm.focused_screen()
   return hs.screen.mainScreen()
end

function Wm.get_window(win_id)
   return hs.window.find(win_id)
end

function Wm.focused_win()
   return hs.window.focusedWindow()
end

function Wm.windows_at_focused()
   local focused_screen_id = hs.window.focusedWindow():screen():id()
   local filter = hs.window.filter.new()
   filter:setOverrideFilter({ currentSpace = true, allowScreens = focused_screen_id, visible = true })
   return filter:getWindows()
end

function Wm.callback_on_focus(fun)
   hs.window.filter.defaultCurrentSpace:subscribe(hs.window.filter.windowFocused, fun)
end

function Wm.hide(win)
   win:application():hide()
end

function Wm.close(win)
   win:close()
end

function Wm.raise(win)
   win:raise()
end

function Wm.focus_and_raise(win)
   win:raise()
   win:focus()
end

function Wm.focus_and_raise_app(app_name)
   local app = hs.application.open(app_name)
   if app == nil then return end
   app:activate()
   return app:focusedWindow()
end

function Wm.restart()
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

-- Rewire media keys to mpc
local mpc_commands = { PLAY = "toggle", NEXT = "next", PREVIOUS = "prev" }
-- Note: global variable to avoid garbage collection
Mpc_tap = hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(event)
   local sys_key_event = event:systemKey()
   if not sys_key_event or not sys_key_event.down then
      return false
   elseif mpc_commands[sys_key_event.key] and not sys_key_event['repeat'] then
      hs.execute("mpc " .. mpc_commands[sys_key_event.key], true)
   end
   return false -- propagate to other apps, too
end)
Mpc_tap:start()

-- Spoon for LSP support
hs.loadSpoon("EmmyLua")

Lwm = require("lwm").new(Wm, 0.55, 9)

require("keymap").map(Lwm)

Lwm:notify("Hammerspoon!")

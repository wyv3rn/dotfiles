-- implement LWM API

local wm = {}

function wm.notify(msg)
   hs.alert(msg)
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

function wm.maximize(win)
   win:maximize()
end

local lwm = require("lwm").new(wm, 0.45)

local home = os.getenv("HOME")

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

-- Helper for rebinding with a fallback
local function rebind(modifiers, character, fallback_modifier, fun)
   hs.hotkey.bind(modifiers, character, fun)

   local fallback_modifiers = {}
   for i, val in ipairs(modifiers) do
      fallback_modifiers[i] = val
   end
   table.insert(fallback_modifiers, fallback_modifier)
   hs.hotkey.bind(fallback_modifiers, character, function()
      hs.eventtap.keyStroke(modifiers, character, 0, hs.application.frontmostApplication())
   end)
end

-- Activate specific applications by key combination
local apps = {
   ["Ghostty"] = "T",
   ["qutebrowser"] = "N",
   ["Thunderbird"] = "D",
   ["sioyek"] = "R",
}

for app, key in pairs(apps) do
   rebind({ "cmd" }, key, "shift", function()
      local a = hs.application.find(app)
      if a == nil then return end
      a:activate(app)
      local win = a:focusedWindow()
      lwm:fill_if_required(win)
   end)
end

-- fzf all other windows
hs.hotkey.bind({ "cmd" }, "Z", function()
   local task = hs.task.new(home .. "/.local/bin/mwm", nil, { "fzf-win" })
   local env = task:environment()
   if task == nil or env == nil then
      hs.alert("Could not create task")
      return
   end
   env["PATH"] = env["PATH"] .. ":/opt/homebrew/bin:" .. env["HOME"] .. "/.local/bin"
   task:setEnvironment(env)
   task:start()
end)

hs.hotkey.bind({ "cmd" }, "Y", function()
   lwm:fzf_win()
end)

-- library
hs.hotkey.bind({ "cmd", "shift" }, "A", function()
   hs.execute("rlg fzf --gui", true)
end)

-- Close window with Cmd-Q and kill application with Cmd-Shift-Q
rebind({ "cmd" }, "Q", "Shift", function()
   lwm:close_focused()
end)

hs.hotkey.bind({ "cmd" }, "M", function()
   lwm:maximize_focused()
end)

hs.hotkey.bind({ "cmd", "shift" }, "H", function()
   lwm:snap_focused("left")
end)

hs.hotkey.bind({ "cmd", "shift" }, "L", function()
   lwm:snap_focused("right")
end)

-- Resize both left and right snaps at the same time
hs.hotkey.bind({ "cmd", }, "H", function()
   lwm:shift_snaps(0.05, "left")
end)

hs.hotkey.bind({ "cmd", }, "L", function()
   lwm:shift_snaps(0.05, "right")
end)

-- Config reload
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
   hs.reload()
end)

-- Spoon for LSP support
hs.loadSpoon("EmmyLua")

-- Enable IPC API,too
hs.ipc.cliInstall()

-- Resnap
for _, win in ipairs(hs.window.allWindows()) do
   if lwm:is_snapped(win, "left") then
      lwm:snap(win, "left")
   elseif lwm:is_snapped(win, "right") then
      lwm:snap(win, "right")
   end
end

hs.alert.show("Hammerspoon!")

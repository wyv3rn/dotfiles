-- implement LWM API

local wm = {}

function wm.notify(msg)
   hs.alert(msg)
end

function wm.pos(win)
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

local lwm = require("lwm").new(wm)

-- some "forward declarations"
local fill_if_required

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

local function withAxHotfix(fn, position)
   if not position then position = 1 end
   return function(...)
      local revert = axHotfix(select(position, ...))
      fn(...)
      revert()
   end
end

local window_mt = hs.getObjectMetatable("hs.window")
if window_mt ~= nil then
   window_mt.setFrame = withAxHotfix(window_mt.setFrame)
end
-- end of hotfixing

local function print_all_windows()
   for _, win in ipairs(hs.window.allWindows()) do
      local app = win:application()
      if app ~= nil then
         print(app:name() .. ";" .. win:title() .. ";" .. win:id())
      end
   end
end

local function focus_window(hint)
   local win = hs.window.find(hint)
   if win ~= nil then
      win:raise()
      win:focus()
      fill_if_required(win)
   end
end

-- Keep track of the split ratio
local left_split = 0.45

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

-- helpers for finding window that are on the same space as the focused one
local function windows_at_focused()
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

local function snap_focused(fraction, direction)
   local win = hs.window.focusedWindow()
   lwm:snap(win, fraction, direction)
end

local function shift_snaps(fraction_step, direction)
   if direction == "left" then
      left_split = left_split - fraction_step
   else
      left_split = left_split + fraction_step
   end
   for _, win in ipairs(windows_at_focused()) do
      if lwm:is_snapped(win, "left") then
         lwm:snap(win, left_split, "left")
      elseif lwm:is_snapped(win, "right") then
         lwm:snap(win, 1.0 - left_split, "right")
      end
   end
end

local function try_fill(direction)
   for _, win in ipairs(hs.window.allWindows()) do
      -- TODO check if it is filled already
      if lwm:is_snapped(win, direction) then
         win:raise()
      end
   end
end

fill_if_required = function(win)
   if win == nil then return end
   if lwm:is_snapped(win, "left") then
      try_fill("right")
   elseif lwm:is_snapped(win, "right") then
      try_fill("left")
   end
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
      fill_if_required(win)
   end)
end

-- fzf all other windows
hs.hotkey.bind({ "cmd" }, "Y", function()
   local task = hs.task.new(home .. "/.local/bin/mwm", nil, { "fzf-win" })
   local env = task:environment()
   if task == nil or env == nil then
      hs.alert("Could not create task")
      return
   end
   env["PATH"] = env["PATH"] .. ":/opt/homebrew/bin:" .. env["HOME"] .. "/.local/bin"
   task:setEnvironment(env)
   task:start()
   task:waitUntilExit()
end)

-- library
hs.hotkey.bind({ "cmd", "shift" }, "A", function()
   hs.execute("rlg fzf --gui", true)
end)

-- Close window with Cmd-Q and kill application with Cmd-Shift-Q
rebind({ "cmd" }, "Q", "Shift", function()
   local win = hs.window.focusedWindow()
   win:close()
end)

-- Maximize
hs.hotkey.bind({ "cmd" }, "M", function()
   hs.window.focusedWindow():maximize()
end)

-- Snap to left
hs.hotkey.bind({ "cmd", "shift" }, "H", function()
   snap_focused(left_split, "left")
end)

-- Snap to right
hs.hotkey.bind({ "cmd", "shift" }, "L", function()
   snap_focused(1.0 - left_split, "right")
end)

-- Resize both left and right snaps at the same time
hs.hotkey.bind({ "cmd", }, "H", function()
   shift_snaps(0.05, "left")
end)

hs.hotkey.bind({ "cmd", }, "L", function()
   shift_snaps(0.05, "right")
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
      lwm:snap(win, left_split, "left")
   elseif lwm:is_snapped(win, "right") then
      lwm:snap(win, 1.0 - left_split, "right")
   end
end

MWM = {}
MWM.print_all_windows = print_all_windows
MWM.focus_window = focus_window

hs.alert.show("Hammerspoon!")

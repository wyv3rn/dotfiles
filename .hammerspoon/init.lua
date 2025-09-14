local home = os.getenv("HOME")

-- Disable animations
hs.window.animationDuration = 0

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

-- helpers for finding windows
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


-- Helpers for snap left/right and resizing
local function snap(win, fraction, direction)
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()

   f.y = max.y
   f.h = max.h
   if direction == "left" then
      f.w = math.floor(max.w * fraction)
      f.x = max.x
   else
      f.w = math.ceil(max.w * fraction)
      f.x = max.x + max.w - f.w
   end

   win:setFrame(f)
end

local function snap_focused(fraction, direction)
   local win = hs.window.focusedWindow()
   snap(win, fraction, direction)
end

local function is_snapped(win, direction)
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()

   if f.y ~= max.y or f.h ~= max.h or f.w == max.w then
      return false
   end

   if direction == "left" then
      return f.x == max.x
   else
      return f.x == max.x + max.w - f.w
   end
end

local function shift_snaps(fraction_step, direction)
   if direction == "left" then
      left_split = left_split - fraction_step
   else
      left_split = left_split + fraction_step
   end
   for _, win in ipairs(windows_at_focused()) do
      if is_snapped(win, "left") then
         snap(win, left_split, "left")
      elseif is_snapped(win, "right") then
         snap(win, 1.0 - left_split, "right")
      end
   end
end

local function move_focused_to_space(space_idx)
   local win = hs.window.focusedWindow()
   local screen = win:screen()
   local src_space = hs.spaces.activeSpaceOnScreen(screen)
   local dst_space = hs.spaces.spacesForScreen(screen)[space_idx]
   local result = hs.spaces.moveWindowToSpace(win, dst_space, true)
   if result == true then
      hs.alert.show("Moved window from space id = " ..
         src_space .. " to space id = " .. dst_space)
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
      hs.application.find(app):activate(app)
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

for i = 1, 7 do
   hs.hotkey.bind({ "cmd", "shift" }, tostring(i), function()
      move_focused_to_space(i)
   end)
end

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
   if is_snapped(win, "left") then
      snap(win, left_split, "left")
   elseif is_snapped(win, "right") then
      snap(win, 1.0 - left_split, "right")
   end
end

MWM = {}
MWM.print_all_windows = print_all_windows
MWM.focus_window = focus_window

hs.alert.show("Hammerspoon!")

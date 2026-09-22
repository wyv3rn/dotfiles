-- TODO this is hardcoded for running hammerchisel inside the project directory
package.path = package.path .. ";../../.config/lwm/?.lua"

local hc = hc

print(package.path)

-- TODO global or change name
local Wm = {}

function Wm.notify(msg)
   print(msg)
end

function Wm.os()
   return "windows"
end

function Wm.bind(mods, key, fun, _)
   local ok, err = hc.bind(mods, key, fun)
   if not ok then
      Wm.notify("Failed to bind " .. mods .. ", " .. key .. ": " .. err)
   end
end

function Wm.focused_win()
   local win, err = hc.getFocusedWindow()
   if not win then
      Wm.notify("Failed to find focused window: " .. err)
      return nil
   end
   return win
end

function Wm.windows_at_focused()
   local focused = Wm.focused_win()
   if not focused then
      Wm.notify("No focused window")
      return nil
   end
   local focused_screen_id = hc.monitorId(hc.monitorFromWindow(focused))
   if not focused_screen_id then
      Wm.notify("Failed to get screen id for focused window")
      return nil
   end
   local all, err = hc.getAllWindows()
   if not all then
      Wm.notify("Failed to get all windows: " .. err)
      return nil
   end
   local at_focused = {}
   for _, win in ipairs(all) do
      local screen_id = hc.monitorId(hc.monitorFromWindow(win))
      if screen_id and screen_id == focused_screen_id then
         table.insert(at_focused, win)
      end
   end
   return at_focused
end

function Wm.window_id(win)
   local id, err = hc.getWindowId(win)
   if not id then
      Wm.notify("Failed to find window id: " .. err)
      return nil
   end
   return id
end

function Wm.get_window(id)
   -- TODO we probably could just return id here because its the same thing, only "casted" !?
   local win, err = hc.getWindowFromId(id)
   if not win then
      Wm.notify("Failed to get window by id: " .. err)
      return nil
   end
   return win
end

function Wm.window_title(win)
   return hc.getWindowTitle(win)
end

function Wm.window_app_name(win)
   return hc.getApplicationName(win)
end

function Wm.position(win)
   local frame, err = hc.getWindowFrame(win)
   if not frame then
      Wm.notify("Failed to get window position: " .. err)
      return nil
   end
   return frame
end

function Wm.raise(win)
   local ok, err = hc.raiseWindow(win)
   if not ok then
      Wm.notify("Failed to raise window: " .. err)
   end
end

function Wm.focus(win)
   local ok, err = hc.focusWindow(win)
   if not ok then
      Wm.notify("Failed to focus window: " .. err)
   end
end

function Wm.focus_and_raise(win)
   Wm.raise(win)
   Wm.focus(win)
end

function Wm.hide(win)
   local ok, err = hc.minimizeWindow(win)
   if not ok then
      Wm.notify("Failed to minimize window: " .. err)
   end
end

function Wm.window_screen(win)
   local mon, err = hc.monitorFromWindow(win)
   if not mon then
      Wm.notify("Failed to find monitor for window: " .. err)
      return nil
   end
   return mon
end

function Wm.screen_id(screen)
   local id, err = hc.monitorId(screen)
   if not id then
      Wm.notify("Failed to find monitor id: " .. err)
      return nil
   end
   return id
end

function Wm.work_area(win)
   local area, err = hc.getWindowWorkArea(win)
   if not area then
      Wm.notify("Failed to find work area for window: " .. err)
      return nil
   end
   return area
end

function Wm.move_win(win, pos)
   local ok, err = hc.setWindowArea(win, pos)
   if not ok then
      Wm.notify("Failed to move window: " .. err)
   end
end

function Wm.focus_and_raise_app(app_name)
   local all, err = hc.getAllWindows()
   if not all then
      Wm.notify("Failed to get all windows: " .. err)
      return
   end
   Wm.notify("Application name candidates:")
   for _, win in ipairs(all) do
      local canditate = hc.getApplicationName(win)
      print("  " .. canditate)
      -- TODO handle multiple windows of same app
      if canditate == app_name then
         Wm.notify("Trying to focus and raise " .. canditate)
         -- TODO does not (reliably) work without minimizing first
         Wm.hide(win)
         Wm.raise(win)
         Wm.focus(win)
         return
      end
   end
end

function Wm.callback_on_focus(fun)
   local function wrapped(win)
      fun(win)
      Wm.notify(Wm.window_app_name(win))
   end
   local ok, err = hc.onWindowFocus(wrapped)
   if not ok then
      Wm.notify("Failed to register callback: " .. err)
   end
end

function Wm.close(win)
   hc.closeWindow(win)
end

function Wm.restart()
   hc.restart()
end

function Wm.kill()
   hc.kill()
end

Lwm = require("lwm").new(Wm, 0.5, 5)

Lwm:notify("Hammerchisel!")

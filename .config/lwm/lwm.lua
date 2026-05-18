local Lwm = {}
Lwm.__index = Lwm

local api_funs = {
   "notify",
   "os",
   "bind",
   "keystroke_to_app",
   "position",
   "work_area",
   "callback_on_create",
   "move_win",
   "focused_win",
   "windows_at_focused",
   "hide",
   "close",
   "toggle_fullscreen",
   "raise",
   "focus_and_raise",
   "focus_and_raise_app",
   "focused_screen",
   "screen_id",
   "get_window",
   "window_id",
   "window_title",
   "window_app_name",
   "window_screen",
   "spawn",
   "callback_on_focus",
   "restart",
}

setmetatable(Lwm, {
   __call = function(cls, ...) return cls.new(...) end
})

function Lwm.new(wm, master_split, win_border)
   local self = setmetatable({}, Lwm)
   local api_as_set = {}
   for _, fun_name in ipairs(api_funs) do
      api_as_set[fun_name] = true
      if wm[fun_name] ~= nil then
         self[fun_name] = function(_, ...) return wm[fun_name](...) end
      else
         self:notify("Oh no, your wm does not implement " .. fun_name)
      end
   end
   for fun_name, _ in pairs(wm) do
      if not api_as_set[fun_name] then
         self:notify("Warning: Your wm does not need to implement " .. fun_name)
      end
   end
   self.default_master_split = master_split or 0.5
   self.master_splits = {} -- map screens to split
   self.pre_zen_positions = nil
   self.pre_zen_master_split = self.default_master_split
   self.win_border = win_border or 0

   if self.callback_on_create then
      self:callback_on_create(function(new)
         -- TODO; probably use this for "window rules"
         print("Hello, new one!")
         local wins = self:windows_at_focused()
         print("You are not alone, there are " .. #wins - 1 .. " others")
         for _, win in ipairs(wins) do
            if self:window_id(new) ~= self:window_id(win) then
               local app_name = self:window_app_name(win) or "N/A"
               print(".." .. app_name)
            end
         end
      end)
   end

   if self.callback_on_focus then
      self:callback_on_focus(function(win)
         self:fill_if_required(win)
      end)
   end
   return self
end

function Lwm:rebind_in_apps(from_mods, from_key, to_mods, to_key, except)
   self:bind(from_mods, from_key, function() self:keystroke_to_app(to_mods, to_key, except, from_mods, from_key) end)
end

function Lwm:close_focused()
   local win = self:focused_win()
   if win == nil then
      self:notify("Did not find a focused window!")
      return
   end
   self:close(win)
end

function Lwm:maximize(win)
   if not win then
      return
   end
   self:raise(win)
   self:snap(win, "max")
end

function Lwm:maximize_focused()
   self:maximize(self:focused_win())
end

function Lwm:toggle_fullscreen_focused()
   self:toggle_fullscreen(self:focused_win())
end

function Lwm:snap(win, direction)
   if not win then
      return
   end

   local screen_id = self:screen_id(self:window_screen(win))
   if not screen_id then
      return
   end
   local work_area = self:work_area(win)
   local y = work_area.y + self.win_border
   local h = work_area.height - 2 * self.win_border

   local master_split = (self.master_splits[screen_id] or self.default_master_split)
   local left_split = 1.0 - master_split

   local w, x
   local mid = math.floor(work_area.width * left_split)
   if direction == "left" then
      w = mid - 2 * self.win_border
      x = work_area.x + self.win_border
   elseif direction == "right" then
      w = (work_area.width - mid) - 2 * self.win_border
      x = work_area.x + mid + self.win_border
   elseif direction == "middle" then
      w = math.ceil(work_area.width * master_split) - 2 * self.win_border
      x = work_area.x + math.ceil(0.5 * work_area.width - 0.5 * w)
   elseif direction == "max" then
      w = work_area.width - 2 * self.win_border
      x = work_area.x + self.win_border
   end

   local pos = { x = x, y = y, width = w, height = h }
   self:move_win(win, pos)
end

function Lwm:snap_focused(direction)
   local win = self:focused_win()
   if not win then
      return
   end
   local win_id = self:window_id(win)

   if self.pre_zen_positions then
      local was_snapped = self.pre_zen_positions[win_id] ~= nil
      self:toggle_zen()
      if was_snapped then
         return
      end
   end

   if direction == "next" then
      if self:snapped_direction(win) == "left" then
         direction = "right"
      else
         direction = "left"
      end
   end
   self:snap(win, direction)
   self:focus_and_raise(win)
   self:fill_if_required(win)
end

function Lwm:toggle_zen()
   local win = self:focused_win()
   if not win then
      return
   end
   local screen_id = self:screen_id(self:focused_screen())

   if not self.pre_zen_positions then
      self:raise(win) -- make sure to raise before moving to avoid border glitches
      self.pre_zen_positions = {}
      self.pre_zen_master_split = self.master_splits[screen_id]

      for _, other in ipairs(self:windows_at_focused()) do
         local other_id = self:window_id(other)
         local d = self:snapped_direction(other)
         if d then
            self.pre_zen_positions[other_id] = d
            self:snap(other, "middle")
         elseif other ~= win then
            self:hide(win)
         end
      end
      self:snap(win, "middle")
   else
      self.master_splits[screen_id] = self.pre_zen_master_split
      for win_id, direction in pairs(self.pre_zen_positions) do
         local other = self:get_window(win_id)
         if other then
            self:snap(other, direction)
         end
      end
      self.pre_zen_positions = nil
   end
end

function Lwm:snapped_direction(win)
   local pos = self:position(win)
   local work_area = self:work_area(win)
   if pos.y ~= work_area.y + self.win_border or pos.height + 2 * self.win_border < 0.95 * work_area.height then
      return nil
   end

   if pos.width >= 0.95 * work_area.width - 2 * self.win_border then
      return "max"
   elseif pos.x == work_area.x + self.win_border and pos.width < 0.95 * work_area.width - 2 * self.win_border then
      return "left"
   elseif pos.x >= 0.95 * (work_area.x + work_area.width - pos.width - 2 * self.win_border) then
      return "right"
   else
      return "middle"
   end
end

function Lwm:increase_master_split(increment)
   local screen_id = self:screen_id(self:focused_screen())
   if not screen_id then
      return
   end
   if not self.master_splits[screen_id] then
      self.master_splits[screen_id] = self.default_master_split
   end
   self.master_splits[screen_id] = self.master_splits[screen_id] + increment
   for _, win in ipairs(self:windows_at_focused()) do
      local d = self:snapped_direction(win)
      if d and d ~= "max" then
         self:snap(win, d)
      end
   end
end

function Lwm:decrease_master_split(increment)
   self:increase_master_split(-increment)
end

function Lwm:fill_if_required(other_win)
   if other_win == nil then return end
   local d = self:snapped_direction(other_win)
   if d == "left" then
      self:try_fill("right")
   elseif d == "right" then
      self:try_fill("left")
   end
end

function Lwm:try_fill(direction)
   local filled = false
   for _, win in ipairs(self:windows_at_focused()) do
      local d = self:snapped_direction(win)
      if d == direction then
         if not filled then
            self:raise(win)
            filled = true
         end
      end
      if (not d == "left" and not d == "right") or d == "max" then
         self:hide(win)
      end
   end
end

function Lwm:switch_to_app(app_name)
   -- TODO implement this in lwm itself
   local win = self:focus_and_raise_app(app_name)
   if win == nil then
      return
   end
   self:fill_if_required(win)
end

return Lwm

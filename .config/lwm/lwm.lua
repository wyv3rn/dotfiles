local Lwm = {}
Lwm.__index = Lwm

local api_funs = {
   "notify",
   "os",
   "bind",
   "keystroke_to_app",
   "position",
   "work_area",
   "move_win",
   "all_windows",
   "focused_win",
   "windows_at_focused",
   "ordered_windows",
   "close",
   "maximize",
   "focus_and_raise",
   "focus_and_raise_app",
   "window_id",
   "window_title",
   "window_app_name",
   "execute",
   "restart",
}

setmetatable(Lwm, {
   __call = function(cls, ...) return cls.new(...) end
})

function Lwm.new(wm, left_split)
   local self = setmetatable({}, Lwm)
   for _, fun_name in ipairs(api_funs) do
      if wm[fun_name] ~= nil then
         self[fun_name] = function(_, ...) return wm[fun_name](...) end
      else
         self:notify("Oh no, your wm does not implement " .. fun_name)
      end
   end
   self.left_split = left_split or 0.5
   return self
end

function Lwm:rebind_in_apps(from_mods, from_key, to_mods, to_key, except)
   self:bind(from_mods, from_key, function() self:keystroke_to_app(to_mods, to_key, except, from_mods, from_key) end)
end

function Lwm:fzf_win()
   local input = ""
   local wins = self:all_windows()
   for i, win in ipairs(wins) do
      local app_name = self:window_app_name(win):gsub("%s+", "")
      local title = self:window_title(win):gsub("%s+", "_")
      input = input .. app_name .. "\\\\t" .. title .. "\\\\t" .. i
      if i ~= #wins then
         input = input .. "\\\\n"
      end
   end
   local output = self:execute("gfzf \"" .. input .. "\"")
   local found, _, selected_idx_str = output:find(".*\t(%d+)$")
   if not found then
      return
   end
   local selected_idx = tonumber(selected_idx_str)
   local selected_win = wins[selected_idx]
   self:focus_and_raise(selected_win)
end

function Lwm:close_focused()
   self:close(self:focused_win())
end

function Lwm:maximize_focused()
   self:maximize(self:focused_win())
end

function Lwm:snap(win, direction)
   local work_area = self:work_area(win)
   local y = work_area.y
   local h = work_area.height

   local w, x
   if direction == "left" then
      w = math.floor(work_area.width * self.left_split)
      x = work_area.x
   else
      w = math.ceil(work_area.width * (1.0 - self.left_split))
      x = work_area.x + work_area.width - w
   end

   local pos = { x = x, y = y, width = w, height = h }
   self:move_win(win, pos)
end

function Lwm:snap_focused(direction)
   local win = self:focused_win()
   if win ~= nil then
      if direction == "next" then
         if self:is_snapped(win, "left") then
            direction = "right"
         else
            direction = "left"
         end
      end
      self:snap(win, direction)
   else
      self:notify("Did not find a focused window!")
   end
end

function Lwm:is_snapped(win, direction)
   local pos = self:position(win)
   local work_area = self:work_area(win)

   if pos.y ~= work_area.y or pos.height ~= work_area.height or pos.width == work_area.width then
      return false
   end

   if direction == "left" then
      return pos.x == work_area.x
   else
      return pos.x == work_area.x + work_area.width - pos.width
   end
end

function Lwm:shift_snaps(fraction_step, direction)
   if direction == "left" then
      self.left_split = self.left_split - fraction_step
   else
      self.left_split = self.left_split + fraction_step
   end
   for _, win in ipairs(self:windows_at_focused()) do
      if self:is_snapped(win, "left") then
         self:snap(win, "left")
      elseif self:is_snapped(win, "right") then
         self:snap(win, "right")
      end
   end
end

function Lwm:fill_if_required(other_win)
   if other_win == nil then return end
   if self:is_snapped(other_win, "left") then
      self:try_fill(other_win, "right")
   elseif self:is_snapped(other_win, "right") then
      self:try_fill(other_win, "left")
   end
end

function Lwm:try_fill(other_win, direction)
   local win_ids_at_focused = {}
   for _, win in ipairs(self:windows_at_focused(other_win)) do
      win_ids_at_focused[self:window_id(win)] = true
   end

   for _, win in ipairs(self:ordered_windows()) do
      if win_ids_at_focused[self:window_id(win)] and self:is_snapped(win, direction) then
         win:raise()
         return
      end
   end
end

function Lwm:switch_to_app(app_name)
   local win = self:focus_and_raise_app(app_name)
   self:fill_if_required(win)
end

return Lwm

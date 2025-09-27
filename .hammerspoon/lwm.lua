local Lwm = {}
Lwm.__index = Lwm

local api_funs = {
   "position",
   "work_area",
   "move_win",
   "focused_win",
   "windows_at_focused",
}

setmetatable(Lwm, {
   __call = function(cls, ...) return cls.new(...) end
})

function Lwm.new(wm, left_split)
   local self = setmetatable({}, Lwm)
   self.wm = {}
   self.wm.notify = wm.notify
   for _, fun in ipairs(api_funs) do
      self["wm"][fun] = wm[fun] or self.notify("Oh no, your wm does not implement wm." .. fun)
   end
   self.left_split = left_split or 0.5
   return self
end

function Lwm:snap(win, direction)
   local work_area = self.wm.work_area(win)
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
   self.wm.move_win(win, pos)
end

function Lwm:snap_focused(direction)
   local win = self.wm.focused_win()
   if win ~= nil then
      self:snap(win, direction)
   else
      self.wm.notify("Did not find a focused window!")
   end
end

function Lwm:is_snapped(win, direction)
   local pos = self.wm.position(win)
   local work_area = self.wm.work_area(win)

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
   for _, win in ipairs(self.wm.windows_at_focused()) do
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
   for _, win in ipairs(self.wm.windows_at_focused(other_win)) do
      -- TODO check if it is filled already
      if self:is_snapped(win, direction) then
         win:raise()
      end
   end
end

return Lwm

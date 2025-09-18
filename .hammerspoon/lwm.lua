local Lwm = {}
Lwm.__index = Lwm

local api_funs = {
   "pos",
   "work_area",
   "move_win",
}

setmetatable(Lwm, {
   __call = function(cls, ...) return cls.new(...) end
})

function Lwm.new(wm)
   local self = setmetatable({}, Lwm)
   self.notify = wm.notify
   for _, fun in ipairs(api_funs) do
      self[fun] = wm[fun] or self.notify("Oh no, your wm does not implement wm." .. fun)
   end
   return self
end

function Lwm:snap(win, fraction, direction)
   local work_area = self.work_area(win)
   local y = work_area.y
   local h = work_area.height

   local w, x
   if direction == "left" then
      w = math.floor(work_area.width * fraction)
      x = work_area.x
   else
      w = math.ceil(work_area.width * fraction)
      x = work_area.x + work_area.width - w
   end

   local pos = { x = x, y = y, width = w, height = h }
   self.move_win(win, pos)
end

function Lwm:is_snapped(win, direction)
   local pos = self.pos(win)
   local work_area = self.work_area(win)

   if pos.y ~= work_area.y or pos.height ~= work_area.height or pos.width == work_area.width then
      return false
   end

   if direction == "left" then
      return pos.x == work_area.x
   else
      return pos.x == work_area.x + work_area.width - pos.width
   end
end

return Lwm

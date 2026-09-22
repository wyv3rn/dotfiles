local m = {}

local function area(rec)
   return rec.width * rec.height
end

function m.init(lwm)
   lwm:set_on_create(function(win)
      local win_area = area(lwm:position(win))
      local total_area = area(lwm:work_area(win))
      if (win_area > 0.9 * total_area) then
         lwm:maximize(win)
      end
   end)
end

return m

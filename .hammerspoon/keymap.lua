local m = {}

-- Activate specific applications by key combination
local apps = {
   ["Ghostty"] = "T",
   ["qutebrowser"] = "N",
   ["Thunderbird"] = "D",
   ["sioyek"] = "R",
}

function m.map(lwm)
   for app, key in pairs(apps) do
      lwm:bind({ "cmd" }, key, function() lwm:switch_to_app(app) end, "Shift")
   end

   lwm:bind({ "cmd" }, "Y", function() lwm:fzf_win() end)
   lwm:bind({ "cmd", "shift" }, "A", function() lwm:execute("rlg fzf --gui", true) end)
   lwm:bind({ "cmd" }, "Q", function() lwm:close_focused() end, "Shift")
   lwm:bind({ "cmd" }, "M", function() lwm:maximize_focused() end)
   lwm:bind({ "cmd", "shift" }, "L", function() lwm:snap_focused("left") end)
   lwm:bind({ "cmd", "shift" }, "H", function() lwm:snap_focused("right") end)
   lwm:bind({ "cmd", }, "H", function() lwm:shift_snaps(0.05, "left") end)
   lwm:bind({ "cmd", }, "L", function() lwm:shift_snaps(0.05, "right") end)
   lwm:bind({ "cmd", "alt", "ctrl" }, "R", function() lwm:restart() end)
end

return m

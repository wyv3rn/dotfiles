local m = {}

local browser = "qutebrowser"
local pdf_viewer = "sioyek"
local terminal = "WezTerm"
local mail_client = "Thunderbird"

function m.map(lwm)
   if lwm:os() == "linux" then
      pdf_viewer = "Zathura"
      terminal = "wezterm"
      mail_client = "thunderbird"
   end

   -- Activate specific applications by key combination
   local apps = {
      [browser] = "n",
      [pdf_viewer] = "r",
      [terminal] = "t",
      [mail_client] = "d",
   }

   for app, key in pairs(apps) do
      lwm:bind({ "cmd" }, key, function() lwm:switch_to_app(app) end, "Shift")
   end

   lwm:bind({ "cmd" }, "y", function() lwm:fzf_win() end)
   lwm:bind({ "cmd" }, "a", function() lwm:spawn("rlg open --gui") end)
   lwm:bind({ "cmd" }, "q", function() lwm:close_focused() end, "Shift")
   lwm:bind({ "cmd" }, "m", function() lwm:maximize_focused() end)
   lwm:bind({ "cmd" }, "f", function() lwm:toggle_fullscreen_focused() end)
   lwm:bind({ "cmd" }, "s", function() lwm:snap_focused("next") end)
   lwm:bind({ "cmd" }, "h", function() lwm:shift_snaps(0.05, "left") end)
   lwm:bind({ "cmd" }, "l", function() lwm:shift_snaps(0.05, "right") end)
   lwm:bind({ "cmd", "alt", "ctrl" }, "r", function() lwm:restart() end)

   if lwm:os() == "darwin" then
      lwm:rebind_in_apps({ "ctrl" }, "s", { "cmd" }, "s", { terminal })
      lwm:rebind_in_apps({ "ctrl" }, "c", { "cmd" }, "c", { terminal })
      lwm:rebind_in_apps({ "ctrl" }, "v", { "cmd" }, "v", { terminal })
      lwm:rebind_in_apps({ "ctrl" }, "x", { "cmd" }, "x", { terminal })
      lwm:rebind_in_apps({ "ctrl" }, "z", { "cmd" }, "z", { terminal })
      lwm:rebind_in_apps({ "ctrl" }, "a", { "cmd" }, "a", { terminal })
      lwm:rebind_in_apps({ "ctrl" }, "f", { "cmd" }, "f", { terminal })
   end
end

return m

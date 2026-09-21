local m = {}

local cmd = "cmd"
local hyper = { cmd, "alt", "ctrl" }

function m.map(lwm)
   if lwm:os() == "windows" then
      cmd = "f13"
      hyper = { cmd, "ctrl" }
   end

   local app_names = require("apps").init(lwm)

   -- Activate specific applications by key combination
   local apps = {
      [app_names.browser] = "n",
      [app_names.alt_browser] = "b",
      [app_names.pdf_viewer] = "r",
      [app_names.terminal] = "t",
      [app_names.mail_client] = "d",
      [app_names.smerge] = "g",
      [app_names.signal] = "c",
      [app_names.drawio] = "v",
      [app_names.xournalpp] = "x",
   }

   for app, key in pairs(apps) do
      lwm:bind({ cmd }, key, function() lwm:switch_to_app(app) end, "Shift")
   end

   -- Sane default key bindings for macos
   local except = app_names.all_terminals
   if lwm:os() == "darwin" then
      lwm:rebind_in_apps({ "ctrl" }, "s", { cmd }, "s", except)
      lwm:rebind_in_apps({ "ctrl" }, "c", { cmd }, "c", except)
      lwm:rebind_in_apps({ "ctrl" }, "v", { cmd }, "v", except)
      lwm:rebind_in_apps({ "ctrl" }, "x", { cmd }, "x", except)
      lwm:rebind_in_apps({ "ctrl" }, "z", { cmd }, "z", except)
      lwm:rebind_in_apps({ "ctrl" }, "a", { cmd }, "a", except)
      lwm:rebind_in_apps({ "ctrl" }, "f", { cmd }, "f", except)
      lwm:rebind_in_apps({ "ctrl" }, "p", { cmd }, "p", except)
   end

   -- Actual window management
   lwm:bind({ cmd }, "q", function() lwm:close_focused() end, "Shift")
   lwm:bind({ cmd }, "f", function() lwm:toggle_fullscreen_focused() end, "Shift")
   lwm:bind({ cmd }, "a", function() lwm:spawn("rlg open --gui") end)
   lwm:bind({ cmd }, "p", function() lwm:spawn("p --gui") end)

   lwm:bind({ cmd }, "m", function() lwm:maximize_focused() end)
   lwm:bind({ cmd }, "s", function() lwm:snap_focused("next") end)
   lwm:bind({ cmd }, "z", function() lwm:toggle_zen() end)
   lwm:bind({ cmd }, "h", function() lwm:increase_master_split(0.05) end, "shift")
   lwm:bind({ cmd }, "l", function() lwm:decrease_master_split(0.05) end)

   lwm:bind(hyper, "s", function() lwm:do_on_create_all() end)
   lwm:bind(hyper, "r", function() lwm:restart() end)
   lwm:bind(hyper, "q", function() lwm:kill() end)
end

return m

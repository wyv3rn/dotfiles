local m = {}

local browser = "qutebrowser"
local pdf_viewer = "Preview"
local terminal = "Alacritty"
local mail_client = "Thunderbird"
local smerge = "Sublime Merge"
local all_terminals = { "Alacritty", "WezTerm", "Ghostty" }

function m.map(lwm)
   if lwm:os() == "linux" then
      pdf_viewer = "Zathura"
      smerge = "Sublime_merge"
   end

   -- Activate specific applications by key combination
   local apps = {
      [browser] = "n",
      [pdf_viewer] = "r",
      [terminal] = "t",
      [mail_client] = "d",
      [smerge] = "g",
   }

   for app, key in pairs(apps) do
      lwm:bind({ "cmd" }, key, function() lwm:switch_to_app(app) end, "Shift")
   end

   -- Sane default key bindings for macos
   local except = all_terminals
   if lwm:os() == "darwin" then
      lwm:rebind_in_apps({ "ctrl" }, "s", { "cmd" }, "s", except)
      lwm:rebind_in_apps({ "ctrl" }, "c", { "cmd" }, "c", except)
      lwm:rebind_in_apps({ "ctrl" }, "v", { "cmd" }, "v", except)
      lwm:rebind_in_apps({ "ctrl" }, "x", { "cmd" }, "x", except)
      lwm:rebind_in_apps({ "ctrl" }, "z", { "cmd" }, "z", except)
      lwm:rebind_in_apps({ "ctrl" }, "a", { "cmd" }, "a", except)
      lwm:rebind_in_apps({ "ctrl" }, "f", { "cmd" }, "f", except)
      lwm:rebind_in_apps({ "ctrl" }, "p", { "cmd" }, "p", except)
   end

   -- Actual window management
   lwm:bind({ "cmd" }, "q", function() lwm:close_focused() end, "Shift")
   lwm:bind({ "cmd" }, "f", function() lwm:toggle_fullscreen_focused() end, "Shift")
   lwm:bind({ "cmd" }, "a", function() lwm:spawn("rlg open --gui") end)
   lwm:bind({ "cmd" }, "p", function() lwm:spawn("p --gui") end)
   lwm:bind({ "cmd", "alt", "ctrl" }, "r", function() lwm:restart() end)

   lwm:bind({ "cmd" }, "m", function() lwm:maximize_focused() end)
   lwm:bind({ "cmd" }, "s", function() lwm:snap_focused("next") end)
   lwm:bind({ "cmd" }, "h", function() lwm:shift_snaps(0.05, "left") end, "shift")
   lwm:bind({ "cmd" }, "l", function() lwm:shift_snaps(0.05, "right") end)
end

return m

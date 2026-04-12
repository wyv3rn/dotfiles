local m = {}

local browser = "qutebrowser"
local pdf_viewer = "sioyek"
local terminal = "WezTerm"
local mail_client = "Thunderbird"
local smerge = "Sublime Merge"

function m.map(lwm, pwm)
   if lwm:os() == "linux" then
      pdf_viewer = "Zathura"
      terminal = "wezterm"
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
   local except = { terminal }
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
   lwm:bind({ "cmd" }, "y", function() lwm:fzf_win() end)
   lwm:bind({ "cmd" }, "q", function() lwm:close_focused() end, "Shift")
   lwm:bind({ "cmd" }, "f", function() lwm:toggle_fullscreen_focused() end)
   lwm:bind({ "cmd" }, "a", function() lwm:spawn("rlg open --gui") end)
   lwm:bind({ "cmd" }, "p", function() lwm:spawn("p --gui") end)
   lwm:bind({ "cmd", "alt", "ctrl" }, "r", function() lwm:restart() end)

   if pwm then
      pwm:bindHotkeys({
         focus_left = { { "cmd" }, "i" },
         focus_right = { { "cmd" }, "e" },
         swap_left = { { "cmd", "shift" }, "i" },
         swap_right = { { "cmd", "shift" }, "e" },
         split_screen = { { "cmd" }, "s" },
         center_window = { { "cmd", "shift" }, "c" },
         toggle_floating = { { "cmd", "shift" }, "f" },
         full_width = { { "cmd" }, "m" },
         increase_width = { { "cmd" }, "h" },
         decrease_width = { { "cmd" }, "l" },
      })
   else
      lwm:bind({ "cmd" }, "m", function() lwm:maximize_focused() end)
      lwm:bind({ "cmd" }, "s", function() lwm:snap_focused("next") end)
      lwm:bind({ "cmd" }, "h", function() lwm:shift_snaps(0.05, "left") end)
      lwm:bind({ "cmd" }, "l", function() lwm:shift_snaps(0.05, "right") end)
   end
end

return m

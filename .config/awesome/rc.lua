package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/lwm/?.lua"

-- Global to local to silence some LSP warnings down the road
local awesome = awesome
local client = client
local root = root
local mouse = mouse

-- Standard awesome library
local awful = require("awful")
require("awful.autofocus")

-- init theme
local beautiful = require("beautiful")
beautiful.init(awful.util.getdir("config") .. "themes/catppuccin/theme.lua")

-- Notification library
local naughty = require("naughty")

-- implement LWM API
local wm = {}

function wm.notify(msg)
   naughty.notify({ text = msg, position = "bottom_middle" })
end

function wm.os()
   return "linux"
end

local bindings = {}
function wm.bind(mods, key, fun, fallback_mod)
   local translate = {
      cmd = "Mod4",
      alt = "Mod1",
      ctrl = "Control",
      shift = "Shift",
   }
   local tmods = {}
   for _, mod in ipairs(mods) do
      table.insert(tmods, translate[mod])
   end
   bindings = awful.util.table.join(bindings, awful.key(tmods, key, fun))
end

function wm.focused_win()
   return client.focus
end

function wm.windows_at_focused()
   return client.focus.screen.clients
end

function wm.all_windows()
   local wins = {}
   for win in awful.client.iterate(function(_) return true end) do
      table.insert(wins, win)
   end

   return wins
end

function wm.ordered_windows()
   -- TODO actually order them (according to visibility)
   return wm.all_windows()
end

function wm.window_id(win)
   return win.window
end

function wm.window_title(win)
   return win.name
end

function wm.window_app_name(win)
   return win.class
end

function wm.work_area(win)
   return win.screen.workarea
end

function wm.position(win)
   return { x = win.x, y = win.y, width = win.width, height = win.height }
end

function wm.move_win(win, pos)
   win.x = pos.x
   win.y = pos.y
   win.width = pos.width
   win.height = pos.height
end

function wm.focus_and_raise(win)
   win:raise()
   client.focus = win
end

function wm.maximize(win)
   awful.placement.maximize(win, { honor_workarea = true })
end

function wm.close(win)
   win:kill()
end

function wm.focus_and_raise_app(app_name)
   awful.spawn.with_shell("mwm focus-or-spawn " .. app_name)
   -- WIP this should return the window in order for lwm to do filling
end

function wm.execute(cmd)
   -- WIP
   local output = ""
   local waiting = true
   awful.spawn.easy_async_with_shell(cmd, function(stdout, _, _, _)
      output = stdout
      waiting = false
      wm.notify(output)
   end)
   local i = 0
   while waiting and i < 5 do
      os.execute("sleep 1")
      i = i + 1
   end
   wm.notify("Done")
   return output
end

function wm.keystroke_to_app(_, _, _, _, _)
   wm.notify("Why would you need keystroke_to_app on linux?")
end

function wm.restart()
   awesome.restart()
end

-- start lwm
local lwm = require("lwm").new(wm, 0.5)
require("keymap").map(lwm)

-- WIP legacy down below

-- Widget and layout library
local wibox = require("wibox")

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- our helpers
local cmd_to_txt = require("widgets/cmd-to-txt")


-- 3rd party imports
local volume_ctrl = require("widgets/volume-control")
local volumecfg = volume_ctrl({})
local calendar = require("widgets/calendar")
local mytextclock = wibox.widget.textclock(" %a %d %b, %H:%M:%S ", 1)
calendar({}):attach(mytextclock)
local battery_widget = cmd_to_txt("avg-battery", 30)
local switcher = require("widgets/awesome-switcher-macstyle")
switcher.settings.preview_box_delay = 250
switcher.settings.cycle_raise_client = false
switcher.settings.preview_box_title_font_size_factor = 1.3
switcher.settings.preview_box_bg = "#ffffff99"
switcher.settings.swap_with_master = false

-- init simple separator for widgets
local vert_sep = wibox.widget {
   widget = wibox.widget.separator,
   orientation = "vertical",
   forced_width = 20,
   color = "#aaaaaa",
   span_ratio = 0.7,
   thickness = 1.5,
}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors
   })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function(err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true

      naughty.notify({
         preset = naughty.config.presets.critical,
         title = "Oops, an error happened!",
         text = tostring(err)
      })
      in_error = false
   end)
end
-- }}}


-- This is used later as the default terminal and editor to run.
local terminal = "wezterm"

-- Default modkey. For reference: Mod4 = OS key, Mod1 = Alt
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.floating,
}

-- {{{ Helper functions
local function client_menu_toggle_fn()
   local instance = nil

   return function()
      if instance and instance.wibox.visible then
         instance:hide()
         instance = nil
      else
         instance = awful.menu.clients({ theme = { width = 250 } })
      end
   end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end },
   { "restart", awesome.restart },
   { "quit",    function() awesome.quit() end }
}

local mymainmenu = awful.menu({
   items = { { "awesome", myawesomemenu,    beautiful.awesome_icon },
      { "open terminal", terminal },
      { "hibernate",     "systemctl hibernate" },
      { "suspend",       "systemctl suspend" },
      { "reboot",        "reboot" },
      { "shutdown",      "shutdown now" }
   }
})

local mymenu = awful.widget.launcher({
   image = beautiful.awesome_icon,
   menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
   awful.button({}, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
      if client.focus then
         client.focus:move_to_tag(t)
      end
   end),
   awful.button({}, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
      if client.focus then
         client.focus:toggle_tag(t)
      end
   end),
   awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
   awful.button({}, 1, function(c)
      if c == client.focus then
         c.minimized = true
      else
         -- Without this, the following
         -- :isvisible() makes no sense
         c.minimized = false
         if not c:isvisible() and c.first_tag then
            c.first_tag:view_only()
         end
         -- This will also un-minimize
         -- the client, if needed
         client.focus = c
         c:raise()
      end
   end),
   awful.button({}, 3, client_menu_toggle_fn()),
   awful.button({}, 4, function()
      awful.client.focus.byidx(1)
   end),
   awful.button({}, 5, function()
      awful.client.focus.byidx(-1)
   end))

awful.screen.connect_for_each_screen(function(s)
   -- Each screen has its own tag table.
   awful.tag({ "a", "w", "e", "s", "o", "m", "e" }, s, awful.layout.layouts[1])

   -- Create a promptbox for each screen
   s.mypromptbox = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   s.mylayoutbox = awful.widget.layoutbox(s)
   s.mylayoutbox:buttons(awful.util.table.join(
      awful.button({}, 1, function() awful.layout.inc(1) end),
      awful.button({}, 3, function() awful.layout.inc(-1) end),
      awful.button({}, 4, function() awful.layout.inc(1) end),
      awful.button({}, 5, function() awful.layout.inc(-1) end)))
   -- Create a taglist widget
   s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

   -- Create a tasklist widget
   s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

   -- Create the wibox
   s.mywibox = awful.wibar({ position = "top", screen = s })

   -- Add widgets to the wibox
   s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
         layout = wibox.layout.fixed.horizontal,
         mymenu,
         s.mytaglist,
         s.mypromptbox,
      },
      s.mytasklist, -- Middle widget
      {             -- Right widgets
         layout = wibox.layout.fixed.horizontal,
         wibox.widget.systray(),
         vert_sep,
         volumecfg.widget,
         vert_sep,
         battery_widget,
         vert_sep,
         mytextclock,
         s.mylayoutbox,
      },
   }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
   awful.button({}, 3, function() mymainmenu:toggle() end),
   awful.button({}, 4, awful.tag.viewnext),
   awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = awful.util.table.join(
   awful.key({ modkey, }, "Left", awful.tag.viewprev,
      { description = "view previous", group = "tag" }),
   awful.key({ modkey, }, "Right", awful.tag.viewnext,
      { description = "view next", group = "tag" }),
   awful.key({ modkey, "Shift" }, "Tab", awful.tag.history.restore,
      { description = "go back", group = "tag" }),

   awful.key({ modkey, }, "j",
      function()
         awful.client.focus.byidx(1)
      end,
      { description = "focus next by index", group = "client" }
   ),
   awful.key({ modkey, }, "k",
      function()
         awful.client.focus.byidx(-1)
      end,
      { description = "focus previous by index", group = "client" }
   ),
   awful.key({ modkey, }, "w", function() mymainmenu:show() end,
      { description = "show main menu", group = "awesome" }),

   -- Layout manipulation
   awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
      { description = "swap with next client by index", group = "client" }),
   awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
      { description = "swap with previous client by index", group = "client" }),

   -- Screen navigation
   awful.key({ modkey, }, "o", function() awful.screen.focus_relative(1) end,
      { description = "focus the next screen", group = "screen" }),
   awful.key({ modkey, }, "i", function() awful.screen.focus_relative(-1) end,
      { description = "focus the previous screen", group = "screen" }),
   awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
      { description = "jump to urgent client", group = "client" }),
   awful.key({ modkey }, "Tab",
      function()
         switcher.switch(1, "Super_L", "Tab", "ISO_Left_Tab")
      end),

   -- Launch terminal
   awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
      { description = "open a terminal", group = "launcher" }),

   -- Prompt
   awful.key({ modkey, "Shift" }, "r", function() awful.screen.focused().mypromptbox:run() end,
      { description = "run prompt", group = "launcher" }),

   -- Launcher
   awful.key({ modkey }, "space", function() menubar.show() end,
      { description = "show the menubar", group = "launcher" }),
   awful.key({ modkey }, "e", function() menubar.show() end,
      { description = "show the menubar", group = "launcher" }),

   -- lock screen
   awful.key({ modkey, "Control" }, ".", function() awful.spawn("xscreensaver-command -lock") end),

   -- volume ctrl
   awful.key({}, "XF86AudioRaiseVolume", function() volumecfg:up() end),
   awful.key({}, "XF86AudioLowerVolume", function() volumecfg:down() end),
   awful.key({}, "XF86AudioMute", function() volumecfg:toggle() end),
   awful.key({}, "XF86AudioMicMute", function() awful.spawn("amixer set Capture toggle") end),

   -- brightness ctrl
   awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("set-backlight 10 --dec") end),
   awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("set-backlight 10 --inc") end),

   -- player ctrl (once for keyboards without XF86Audio* keys)
   awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end),
   awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end),
   awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end),

   -- toggle wibox
   awful.key({ modkey }, "F11", function() mouse.screen.mywibox.visible = not mouse.screen.mywibox.visible end),

   -- Quit awesome
   awful.key({ modkey, "Control", "Mod1" }, "q", awesome.quit,
      { description = "quit awesome", group = "awesome" })
)

-- custom launchers
local launchers = {
   ["rlg fzf --gui"] = "a",
}
for launcher, key in pairs(launchers) do
   globalkeys = awful.util.table.join(globalkeys,
      awful.key({ modkey }, key, function() awful.spawn.with_shell(launcher) end,
         { description = launcher, group = "launcher" }))
end

local clientkeys = awful.util.table.join(
   awful.key({ modkey, "Shift" }, "f",
      function(c)
         c.fullscreen = not c.fullscreen
         c:raise()
      end,
      { description = "toggle fullscreen", group = "client" }),
   awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
      { description = "move to screen", group = "client" }),
   awful.key({ modkey, "Shift", }, "n",
      function(c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end,
      { description = "minimize", group = "client" }),
   awful.key({ modkey, }, "m",
      function(c)
         c.maximized = not c.maximized
         c:raise()
      end,
      { description = "maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 7.
for i = 1, 7 do
   globalkeys = awful.util.table.join(globalkeys,
      -- View tag only.
      awful.key({ modkey }, "#" .. i + 9,
         function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         { description = "view tag #" .. i, group = "tag" }),

      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
         function()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
         { description = "move focused client to tag #" .. i, group = "tag" })
   )
end

local clientbuttons = awful.util.table.join(
   awful.button({}, 1, function(c)
      client.focus = c; c:raise()
   end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
globalkeys = awful.util.table.join(globalkeys, bindings)
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
   -- All clients will match this rule.
   {
      rule = {},
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = true,
         keys = clientkeys,
         buttons = clientbuttons,
         screen = awful.screen.preferred,
         placement = awful.placement.no_offscreen + awful.placement.centered,
         size_hints_honor = true
      }
   },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
   if awesome.startup and
       not c.size_hints.user_position
       and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
   -- buttons for the titlebar
   local buttons = awful.util.table.join(
      awful.button({}, 1, function()
         client.focus = c
         c:raise()
         awful.mouse.client.move(c)
      end),
      awful.button({}, 3, function()
         client.focus = c
         c:raise()
         awful.mouse.client.resize(c)
      end)
   )

   awful.titlebar(c):setup {
      { -- Left
         awful.titlebar.widget.iconwidget(c),
         buttons = buttons,
         layout  = wibox.layout.fixed.horizontal
      },
      {    -- Middle
         { -- Title
            align  = "center",
            widget = awful.titlebar.widget.titlewidget(c)
         },
         buttons = buttons,
         layout  = wibox.layout.flex.horizontal
      },
      { -- Right
         awful.titlebar.widget.floatingbutton(c),
         awful.titlebar.widget.maximizedbutton(c),
         awful.titlebar.widget.stickybutton(c),
         awful.titlebar.widget.ontopbutton(c),
         awful.titlebar.widget.closebutton(c),
         layout = wibox.layout.fixed.horizontal()
      },
      layout = wibox.layout.align.horizontal
   }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
   if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
       and awful.client.focus.filter(c) then
      client.focus = c
   end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

wm.notify("Awesome!")


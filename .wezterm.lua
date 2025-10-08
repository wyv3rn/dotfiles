local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

local os = "linux"
if wezterm.target_triple:find("windows") then
   os = "windows"
elseif wezterm.target_triple:find("darwin") then
   os = "darwin"
end

if os == "windows" then
   config.default_prog = { "nu.exe" }
end

config.color_scheme = "Catppuccin Frappe"
config.hide_tab_bar_if_only_one_tab = true

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 700
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.colors = {
   cursor_bg = "#8caaee",
   cursor_border = "#8caaee",
}

config.font_size = 12
if os == "darwin" then config.font_size = 14 end

config.warn_about_missing_glyphs = false

config.use_dead_keys = false

local function fix_voyager(key, mods)
   if key == "mapped:\"" then
      return "phys:2", mods .. "|SHIFT"
   elseif key == "mapped:%" then
      return "phys:5", mods .. "|SHIFT"
   elseif key == "mapped:/" then
      return "phys:7", mods .. "|SHIFT"
   end
   return nil
end

local function bind(mods, key, action, use_leader)
   use_leader = use_leader or false
   local mods_with_leader = mods
   if use_leader then
      mods_with_leader = "LEADER|" .. mods
   end
   table.insert(config.keys, { key = key, mods = mods_with_leader, action = action })

   -- fix voyager
   local k_key, k_mods = fix_voyager(key, mods)
   if k_key then
      bind(k_mods, k_key, action, use_leader)
   end
end

local function lbind(mods, key, action)
   bind(mods, key, action, true)
end

-- Lead my way and empty table to start with
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {}

-- actual mappings without leader
bind("CTRL", "y", act.ActivatePaneDirection("Next"))
bind("CTRL", "Tab", act.ActivatePaneDirection("Next"))
for i = 1, 9 do
   bind("CTRL", tostring(i), act.ActivateTab(i - 1))
end

-- actual mappings with leader
lbind("", "c", act.SpawnCommandInNewTab)
lbind("", "mapped:[", act.ActivateCopyMode)
lbind("", "mapped:\"", act.SplitVertical({ domain = "CurrentPaneDomain" }))
lbind("", "mapped:%", act.SplitHorizontal({ domain = "CurrentPaneDomain" }))
lbind("", "mapped:/", act.Search({ CaseInSensitiveString = "" }))
lbind("", "f", act.QuickSelect)
lbind("CTRL", "a", act.SendKey({ key = "a", mods = "CTRL" }))
lbind("", "mapped:{", act.PaneSelect({ mode = "SwapWithActive" }))

local resize_step = 10
lbind("", "h", act.AdjustPaneSize({ "Left", resize_step }))
lbind("", "j", act.AdjustPaneSize({ "Down", resize_step }))
lbind("", "k", act.AdjustPaneSize({ "Up", resize_step }))
lbind("", "l", act.AdjustPaneSize({ "Right", resize_step }))

wezterm.on("update-right-status", function(win, pane)
   local status = ""
   if win:leader_is_active() then
      status = status .. " Leader detected, awaiting input ..."
   end
   win:set_right_status(status)
end)

return config

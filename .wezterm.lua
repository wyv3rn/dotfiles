local wezterm = require("wezterm")
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
   config.default_prog = { "powershell.exe" }
end
config.color_scheme = "Catppuccin Frappe"
config.hide_tab_bar_if_only_one_tab = true

config.default_cursor_style = "BlinkingBar"
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.colors = {
   cursor_bg = "#8caaee",
   cursor_border = "#8caaee"
}

config.font_size = 14

-- Lead my way
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
   {
      key = "c",
      mods = "LEADER",
      action = wezterm.action.SpawnCommandInNewTab,
   },
}

-- split vertical
for key, mod in pairs({
   ["phys:2"] = "|SHIFT",
   ["mapped:\""] = "",
}) do
   table.insert(config.keys, {
      key = key,
      mods = "LEADER" .. mod,
      action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })
   })
end

-- split horizontal
for key, mod in pairs({
   ["phys:5"] = "|SHIFT",
   ["mapped:%"] = "",
}) do
   table.insert(config.keys, {
      key = key,
      mods = "LEADER" .. mod,
      action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })
   })
end

-- copy mode
for key, mod in pairs({
   ["mapped:["] = "",
}) do
   table.insert(config.keys, {
      key = key,
      mods = "LEADER" .. mod,
      action = wezterm.action.ActivateCopyMode,
   })
end

-- search mode
for key, mod in pairs({
   ["phys:7"] = "|SHIFT",
   ["mapped:/"] = "",
}) do
   table.insert(config.keys, {
      key = key,
      mods = "LEADER" .. mod,
      action = wezterm.action.Search({ CaseInSensitiveString = "" })
   })
end

-- switch panes
for _, key in ipairs({ "y", "Tab" }) do
   table.insert(config.keys, {
      key = key,
      mods = "CTRL",
      action = wezterm.action.ActivatePaneDirection("Next"),
   })
end

-- switch tabs
for i = 1, 9 do
   table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL',
      action = wezterm.action.ActivateTab(i - 1),
   })
end

return config

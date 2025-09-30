local wezterm = require("wezterm")
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
   config.default_prog = { "powershell.exe" }
end
config.color_scheme = "Catppuccin Frappe"
config.hide_tab_bar_if_only_one_tab = true
config.default_cursor_style = "SteadyBar"

-- Lead my way
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
   {
      key = '"',
      mods = "LEADER|SHIFT",
      action = wezterm.action.SplitVertical,
   },
   {
      key = "%",
      mods = "LEADER|SHIFT",
      action = wezterm.action.SplitHorizontal,
   },
   {
      key = "c",
      mods = "LEADER",
      action = wezterm.action.SpawnCommandInNewTab,
   },
}

for _, key  in ipairs({ "y", "Tab" }) do
   table.insert(config.keys, {
      key = key,
      mods = "CTRL",
      action = wezterm.action.ActivatePaneDirection("Next"),
   })
end

for i = 1, 9 do
   table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL',
      action = wezterm.action.ActivateTab(i - 1),
   })
end

return config

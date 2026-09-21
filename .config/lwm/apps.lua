local m = {}

function m.init(lwm)
   local apps = {}
   apps.browser = "qutebrowser"
   apps.alt_browser = "Brave"
   apps.pdf_viewer = "Preview"
   apps.terminal = "Alacritty"
   apps.mail_client = "Thunderbird"
   apps.smerge = "Sublime Merge"
   apps.signal = "signal"
   apps.drawio = "draw.io"
   apps.xournalpp = "xournal++"
   apps.all_terminals = { "Alacritty", "WezTerm", "Ghostty" }

   if lwm:os() == "linux" then
      apps.alt_browser = "Chromium"
      apps.pdf_viewer = "zathura"
      apps.smerge = "Sublime_merge"
      apps.drawio = "draw-io"
      apps.xournalpp = "xournalpp"
   end

   if lwm:os() == "windows" then
      apps.alt_browser = "brave"
      apps.smerge = "sublime_merge"
      apps.terminal = "wezterm-gui"
      for type, app in pairs(apps) do
         if type ~= "all_terminals" then
            apps[type] = app .. ".exe"
         end
      end
      print(apps.terminal)
   end

   return apps
end

return m

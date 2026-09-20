local m = {}

function m.init(lwm)
   m.browser = "qutebrowser"
   m.alt_browser = "Brave"
   m.pdf_viewer = "Preview"
   m.terminal = "Alacritty"
   m.mail_client = "Thunderbird"
   m.smerge = "Sublime Merge"
   m.signal = "signal"
   m.drawio = "draw.io"
   m.xournalpp = "xournal++"
   m.all_terminals = { "Alacritty", "WezTerm", "Ghostty" }

   if lwm:os() == "linux" then
      m.alt_browser = "Chromium"
      m.pdf_viewer = "zathura"
      m.smerge = "Sublime_merge"
      m.drawio = "draw-io"
      m.xournalpp = "xournalpp"
   end

   if lwm:os() == "windows" then
      m.smerge = "sublime_merge"
      m.terminal = "wezterm"
   end

   return m
end

return m

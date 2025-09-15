import platform
import os
from os.path import expanduser

config.load_autoconfig(False)

# general settings
c.url.searchengines = {
    "DEFAULT": "https://search.brave.com/search?q={}",
    "di": "https://dict.cc/?s={}",
    "gs": "https://scholar.google.com/scholar?q={}",
    "doi": "https://doi.org/{}",
}
c.url.start_pages = ["about:blank"]
c.colors.webpage.preferred_color_scheme = "dark"
c.tabs.last_close = "startpage"
c.spellcheck.languages = ["de-DE", "en-US"]
c.downloads.position = "bottom"
with config.pattern("*.prakinf.tu-ilmenau.de/*") as p:
    p.content.notifications.enabled = True

### key bindings
# reload config
config.bind("<Space>x", "config-source")

# don't close tab by accident
config.unbind("d")

# make some custom keybinds work for neo2 with Karabiner
config.bind("<Alt-d>", "cmd-set-text :")
config.bind("<Alt-i>", "cmd-set-text /")
config.bind("<Alt-s>", "cmd-set-text ?")
config.bind("<Alt-b>", "zoom-in")
config.bind("<Alt-t>", "zoom-out")
config.bind("<Alt-c><Alt-c>", "navigate next")
config.bind("<Alt-l><Alt-l>", "navigate prev")

# history
config.bind("<Ctrl-t>", "back")
config.bind("<Ctrl-i>", "forward")

# scrolling
config.bind("{", "scroll-page 0 -0.5")
config.bind("}", "scroll-page 0 0.5")
config.bind("<Alt-a>", "scroll-page 0 -0.5")
config.bind("<Alt-e>", "scroll-page 0 0.5")

# tabs
config.bind("gl", "tab-focus last")
config.bind("<Space><Tab>", "tab-focus last")
config.bind("<Return><Tab>", "tab-focus last")
config.bind("gt", "tab-next")
config.bind("gT", "tab-prev")
for i in range(1, 10):
    config.bind(f"g{i}", f"tab-focus {i}")
    config.bind(f"<Ctrl-{i}>", f"tab-focus {i}")

# search primary selected text
config.bind("sd", "open -t di {primary}")
config.bind("ss", "open -t gs {primary}")

# yank primary selected text to clipboard
config.bind("ys", "yank selection")
### end of key bindings

# set PATH on macos
system = platform.system()
if system == "Darwin":
    home_dir = expanduser("~")
    path = os.environ["PATH"]
    path += os.pathsep + home_dir + "/.local/bin"
    path += os.pathsep + "/opt/homebrew/bin"
    os.environ["PATH"] = path

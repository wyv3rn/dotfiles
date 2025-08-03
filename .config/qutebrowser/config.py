config.load_autoconfig(False)

# general settings
c.url.searchengines = {"DEFAULT": "search.brave.com/search?q={}"}
c.url.start_pages = ["about:blank"]

# key bindings
# reload config
config.bind("<Space>x", "config-source")

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
config.bind("<Alt-a>", "scroll-page 0 -0.5")
config.bind("<Alt-e>", "scroll-page 0 0.5")

# tabs
config.bind("gl", "tab-focus last")
config.bind("<Space><Tab>", "tab-focus last")
config.bind("gt", "tab-next")
config.bind("gT", "tab-prev")
for i in range(1, 10):
    config.bind(f"g{i}", f"tab-focus {i}")
    config.bind(f"<Ctrl-{i}>", f"tab-focus {i}")

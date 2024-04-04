-- Helper for rebinding with a fallback

local function rebind(modifiers, character, fallback_modifier, fun)
    hs.hotkey.bind(modifiers, character, fun)

    local fallback_modifiers = {}
    for i, val in ipairs(modifiers) do
        fallback_modifiers[i] = val
    end
    table.insert(fallback_modifiers, fallback_modifier)
    hs.hotkey.bind(fallback_modifiers, character, function()
        hs.eventtap.keyStroke(modifiers, character, 0, hs.application.frontmostApplication())
    end)
end

-- Open or activate specific applications by key combination
local apps = {
    ["Alacritty"] = "T",
    ["Firefox"] = "N",
    ["Thunderbird"] = "D",
    ["Spotify"] = "Y",
    ["Sublime Merge"] = "G",
    ["draw.io"] = "I",
    ["sioyek"] = "R",
    ["Zotero"] = "Z",
}

for app, key in pairs(apps) do
    rebind({ "cmd" }, key, "shift", function()
        hs.application.open(app)
    end)
end

-- Close window with Cmd-Q and kill application with Cmd-Shift-Q
rebind({ "cmd" }, "Q", "Shift", function()
    local win = hs.window.focusedWindow()
    win:close()
end)

-- Maximize
hs.hotkey.bind({ "cmd" }, "M", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
end)

-- Snap to left
hs.hotkey.bind({ "cmd", "shift" }, "H", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end)

-- Snap to right
hs.hotkey.bind({ "cmd", "shift" }, "L", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + max.w / 2
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end)

-- Config reload
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
    hs.reload()
end)

hs.alert.show("Hammerspoon!")

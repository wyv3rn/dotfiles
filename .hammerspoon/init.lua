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

-- Helpers for snap left/right and resizing
local function snap(win, fraction, direction)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.y = max.y
    f.h = max.h
    if direction == "left" then
        f.w = math.floor(max.w * fraction)
        f.x = max.x
    else
        f.w = math.ceil(max.w * fraction)
        f.x = max.x + max.w - f.w
    end

    win:setFrame(f)
end

local function snap_focused(fraction, direction)
    local win = hs.window.focusedWindow()
    snap(win, fraction, direction)
end

local function is_snapped(win, direction)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if f.y ~= max.y or f.h ~= max.h or f.w == max.w then
        return false
    end

    if direction == "left" then
        return f.x == max.x
    else
        return f.x == max.x + max.w - f.w
    end
end

local function snap_fraction(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    return math.floor(f.w / max.w * 100 + 0.5) / 100
end

local function shift_snaps(fraction_step, direction)
    local focused_screen_id = hs.window.focusedWindow():screen():id()
    local space_filter = hs.window.filter.defaultCurrentSpace
    for _, win in ipairs(space_filter:getWindows()) do
        if win:screen():id() == focused_screen_id then
            if is_snapped(win, "left") then
                if direction == "left" then
                    snap(win, snap_fraction(win) - fraction_step, "left")
                else
                    snap(win, snap_fraction(win) + fraction_step, "left")
                end
            elseif is_snapped(win, "right") then
                if direction == "left" then
                    snap(win, snap_fraction(win) + fraction_step, "right")
                else
                    snap(win, snap_fraction(win) - fraction_step, "right")
                end
            end
        end
    end
end

-- Open or activate specific applications by key combination
local apps = {
    ["Alacritty"] = "T",
    ["Brave Browser"] = "N",
    ["Zed"] = "D",
    ["Preview"] = "R",
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
    snap_focused(1.0, "left")
end)

-- Snap to left
hs.hotkey.bind({ "cmd", "shift" }, "H", function()
    snap_focused(0.5, "left")
end)

-- Snap to right
hs.hotkey.bind({ "cmd", "shift" }, "L", function()
    snap_focused(0.5, "right")
end)

-- Resize both left and right snaps at the same time
hs.hotkey.bind({ "cmd", }, "H", function()
    shift_snaps(0.05, "left")
end)

hs.hotkey.bind({ "cmd", }, "L", function()
    shift_snaps(0.05, "right")
end)

-- Config reload
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
    hs.reload()
end)

hs.alert.show("Hammerspoon!")

local battery_widget = require("widgets/battery-widget")

bat_limits = {
    { 10, "red"   },
    { 30, "orange"},
    {100, "green" }
}

battery0 = battery_widget {
    adapter = "BAT0",
    limits = bat_limits,
    widget_text = "${AC_BAT}${color_on}${percent}%${color_off}"
}

battery1 = battery_widget {
    adapter = "BAT1",
    limits = bat_limits,
    widget_text = " ${AC_BAT}${color_on}${percent}%${color_off}"
}


local m = {}

function m.init(lwm)
   local app_names = require("apps").init(lwm)
   lwm:set_default_on_create(function(win) lwm:maximize(win) end)
   lwm:set_on_create(app_names.terminal, function(win) lwm:snap(win, "right") end)
   lwm:set_on_create(app_names.browser, function(win) lwm:snap(win, "left") end)
end

return m

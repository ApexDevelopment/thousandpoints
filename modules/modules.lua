local modules = {}

function load_module(name)
	local module = require("modules." .. name)
	modules[name] = module
end

load_module("mainmenu")
load_module("testmodule")
load_module("pong")

return modules

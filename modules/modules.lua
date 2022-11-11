local modules = {}

local function load_module(name)
	local module = require("modules." .. name)
	modules[name] = module
end

load_module("mainmenu")
load_module("settings")
load_module("testmodule")
load_module("pong")
load_module("spaceinvaders")
load_module("breakout")

return modules

local modules = {}

local function load_module(name)
	local module = require("modules." .. name)
	modules[name] = module
end

-- Menu modules
--load_module("testmodule")
load_module("mainmenu")
load_module("settings")
-- Game modules
load_module("pong")
load_module("spaceinvaders")
load_module("breakout")
load_module("tetris")

return modules

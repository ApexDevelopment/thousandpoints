local modules = {}

local function load_module(name)
	local module = require("modules." .. name)
	modules[name] = module

	if module.load then
		module.load()
	end
end

-- Menu modules
--load_module("testmodule")
load_module("mainmenu")
load_module("settings")
load_module("gameover")
load_module("about")
-- Game modules
load_module("pong")
load_module("spaceinvaders")
load_module("breakout")
load_module("tetris")

return modules

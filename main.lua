local modules = require("modules.modules")
local util = require("util")

local game = {
	util = util,
	points = 0,
	current_module = nil,
	switch_module = function(self, new_module)
		if type(new_module) == "string" then new_module = modules[new_module] end
		
		if self.current_module and self.current_module.stop then
			self.current_module.stop()
		end

		self.current_module = new_module
		
		if new_module and new_module.start then
			new_module.start()
		end
	end,
	show_main_menu = function(self)
		self.points = 0
		self:switch_module(modules.mainmenu)
	end
}

function love.load()
	print("Thousand points launched.")

	print("Loading font...")
	love.graphics.setNewFont("resources/fonts/upheavtt.ttf", 24)
	print("Font loaded.")

	print("Starting main menu...")
	game:show_main_menu()
end

function love.update(dt)
	if game.current_module then
		game.current_module.update(dt, game)
	end
end

function love.draw()
	if game.current_module then
		game.current_module.draw(game)
	end
end
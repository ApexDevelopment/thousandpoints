local modules = require("modules.modules")
local util = require("util")

local game = {
	settings = {
		PIXEL_SIZE = 10
	},
	util = util,
	points = 0,
	current_module = nil,
	switch_module = function(self, new_module)
		if type(new_module) == "string" then new_module = modules[new_module] end
		
		if self.current_module and self.current_module.stop then
			self.current_module.stop(self)
		end

		self.current_module = new_module
		
		if new_module and new_module.start then
			new_module.start(self)
		end
	end,
	show_main_menu = function(self)
		self.points = 0
		self:switch_module(modules.mainmenu)
	end
}
--[[
local events = {
	register = function(self, event, handler)
		if not self[event] then self[event] = {} end
		local connection = {
			event = event,
			handler = handler,
			disconnect = function(self2)
				for i, v in ipairs(self[self2.event]) do
					if v == self2 then
						table.remove(self[self2.event], i)
						break
					end
				end
			end
		}
		table.insert(self[event], connection)
		return connection
	end,
	fire = function(self, event, ...)
		if self[event] then
			for _, handler in ipairs(self[event]) do
				handler(...)
			end
		end
	end
}

game.events = events
]]
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

function love.keypressed(key)
	-- If they press escape, intercept it and show the settings menu.
	if key == "escape" then
		--game:switch_module(modules.settings)
		-- For now we'll just change the pixel size
		game.settings.PIXEL_SIZE = game.settings.PIXEL_SIZE + 1

		if game.settings.PIXEL_SIZE > 12 then
			game.settings.PIXEL_SIZE = 1
		end
		-- If the current module has a settings update function, call it
		if game.current_module and game.current_module.settings_update then
			game.current_module.settings_update(game.settings)
		end
		return
	end

	if game.current_module and game.current_module.keypressed then
		game.current_module.keypressed(key, game)
	end
end

function love.keyreleased(key)
	if game.current_module and game.current_module.keyreleased then
		game.current_module.keyreleased(key, game)
	end
end

function love.mousepressed(x, y, button)
	if game.current_module and game.current_module.mousepressed then
		game.current_module.mousepressed(x, y, button, game)
	end
end

function love.mousereleased(x, y, button)
	if game.current_module and game.current_module.mousereleased then
		game.current_module.mousereleased(x, y, button, game)
	end
end

function love.mousemoved(x, y, dx, dy)
	if game.current_module and game.current_module.mousemoved then
		game.current_module.mousemoved(x, y, dx, dy, game)
	end
end

function love.quit()
	if game.current_module and game.current_module.stop then
		game.current_module.stop()
	end
end
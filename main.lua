local moonshine = require("moonshine")
local modules = require("modules.modules")
local util = require("util")
math.randomseed(os.time())

local game = {
	settings = {
		PIXEL_SIZE = 10
	},
	games = {},
	current_game_id = 1,
	util = util,
	points = 0,
	lives = 3,
	current_module = nil,
	overlay_module = nil,
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
	end,
	show_overlay = function(self, overlay)
		if type(overlay) == "string" then overlay = modules[overlay] end

		self.overlay_module = overlay

		if overlay and overlay.start then
			overlay.start(self)
		end
	end,
	clear_overlay = function(self)
		if self.overlay_module and self.overlay_module.stop then
			self.overlay_module.stop(self)
		end

		self.overlay_module = nil
	end,
	start_game = function(self)
		self.points = 0
		self.lives = 3
		self.games = {}

		-- Randomize the order of the games played
		for k, v in pairs(modules) do
			if not v.menu then
				table.insert(self.games, k)
			end
		end

		self.util.shuffle(self.games)
		print("Starting game!")
		self:switch_module(self.games[self.current_game_id])
	end,
	next_game = function(self)
		self.points = 0
		self.current_game_id = self.current_game_id + 1
		if self.current_game_id > #self.games then
			self.current_game_id = 1
		end

		self:switch_module(self.games[self.current_game_id])
	end,
	lose_life = function(self)
		self.lives = self.lives - 1
		if self.lives < 0 then
			self.lives = 3
			self:switch_module(modules.gameover)
		end
	end,
	add_score = function(self, points)
		self.points = self.points + points
		if self.points > 1000 then
			self:next_game()
		end
	end
}

function love.load()
	print("Thousand points launched.")

	print("Loading font...")
	love.graphics.setNewFont("resources/fonts/upheavtt.ttf", 24)
	print("Font loaded.")

	print("Loading shaders...")
	game.shaders = {
		blur = moonshine(moonshine.effects.gaussianblur)
	}
	print("Shaders loaded.")

	print("Starting main menu...")
	game:show_main_menu()
end

function love.update(dt)
	if game.overlay_module then
		game.overlay_module.update(dt, game)
	elseif game.current_module then
		game.current_module.update(dt, game)
	end
end

function love.draw()
	if game.current_module then
		if game.overlay_module then
			game.shaders.blur(function() game.current_module.draw(game) end)
		elseif not game.current_module.menu then
			local game_w, game_h = game.current_module.draw(game)
			local bottom_pos = game_h * game.settings.PIXEL_SIZE / 2 + love.graphics.getHeight() / 2
			local left_pos  = love.graphics.getWidth() / 2 - game_w * game.settings.PIXEL_SIZE / 2

			for i = 0, game.lives do
				love.graphics.rectangle("fill", left_pos + 20 * i, bottom_pos + 10, 16, 16)
			end
		else
			game.current_module.draw(game)
		end
	end

	if game.overlay_module then
		-- Dim screen
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
		love.graphics.setColor(1, 1, 1, 1)
		-- Draw overlay
		game.overlay_module.draw(game)
	end
end

function love.keypressed(key)
	-- If they press escape, intercept it and show the settings menu.
	if key == "escape" and not game.current_module.menu then
		if game.overlay_module then
			game:clear_overlay()
		else
			game:show_overlay(modules.settings)
		end
		return
	end

	if key == "f11" then
		love.window.setFullscreen(not love.window.getFullscreen())
		return
	end

	-- DEBUG ONLY
	if key == "`" then
		game:next_game()
		return
	end

	if not game.overlay_module and game.current_module and game.current_module.keypressed then
		game.current_module.keypressed(key, game)
	end
end

function love.keyreleased(key)
	if not game.overlay_module and game.current_module and game.current_module.keyreleased then
		game.current_module.keyreleased(key, game)
	end
end

function love.mousepressed(x, y, button)
	if not game.overlay_module and game.current_module and game.current_module.mousepressed then
		game.current_module.mousepressed(x, y, button, game)
	end
end

function love.mousereleased(x, y, button)
	if not game.overlay_module and game.current_module and game.current_module.mousereleased then
		game.current_module.mousereleased(x, y, button, game)
	end
end

function love.mousemoved(x, y, dx, dy)
	if not game.overlay_module and game.current_module and game.current_module.mousemoved then
		game.current_module.mousemoved(x, y, dx, dy, game)
	end
end

function love.quit()
	if game.overlay_module and game.overlay_module.quit then
		game.overlay_module.quit(game)
	end

	if game.current_module and game.current_module.stop then
		game.current_module.stop()
	end
end
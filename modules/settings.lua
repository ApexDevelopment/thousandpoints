--[[ Settings menu overlay module ]]

local buttons = {}
local button_spacing = 10
local button_height = 30

local function start(game)
	buttons = {}
	
	table.insert(buttons, game.util.button("Scale", function(game)
		game.settings.PIXEL_SIZE = game.settings.PIXEL_SIZE + 1

		if game.settings.PIXEL_SIZE > 12 then
			game.settings.PIXEL_SIZE = 5
		end
		-- If the current module has a settings update function, call it
		if game.current_module and game.current_module.settings_update then
			game.current_module.settings_update(game.settings)
		end
	end))

	if game.current_module.menu then
		-- We got here from the main menu
		table.insert(buttons, game.util.button("Back", function(game)
			game:show_main_menu()
		end))
	else
		-- We are ingame
		table.insert(buttons, game.util.button("Back", function(game)
			game.overlay_module = nil
		end))

		table.insert(buttons, game.util.button("Quit to Menu", function(game)
			game:clear_overlay()
			game:show_main_menu()
		end))
	end
end

local function update(dt, game)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()
	local button_width = game.util.get_max_button_width(buttons)

	for i, button in ipairs(buttons) do
		local button_x = screen_w / 2 - button_width / 2
		local button_y = screen_h / 2 + (i - 1) * (button_height + button_spacing)

		if love.mouse.isDown(1) and game.util.point_in_rect(mouse_x, mouse_y, button_x, button_y, button_width, button_height) then
			if not button.is_mouse_down then
				button.is_mouse_down = true
			end
		elseif button.is_mouse_down then
			button.is_mouse_down = false
			button.callback(game)
		end
	end
end

local function draw(game)
	love.graphics.setColor(1, 1, 1)
	local util = game.util
	local screen_w, screen_h = love.graphics.getDimensions()
	local button_width = game.util.get_max_button_width(buttons)

	love.graphics.print("Settings", util.center_h("Settings", screen_w), util.center_v("Settings", screen_h) - 50)

	for i, button in ipairs(buttons) do
		if button.is_mouse_down then
			love.graphics.setColor(0.2, 0.9, 0.1)
		else
			love.graphics.setColor(1, 1, 1)
		end

		love.graphics.rectangle(
			"line",
			screen_w / 2 - button_width / 2,
			screen_h / 2 + (i - 1) * (button_spacing + button_height),
			button_width,
			button_height
		)

		love.graphics.print(
			button.text,
			util.center_h(button.text, screen_w),
			util.center_v(button.text, screen_h) + (button_height / 2) + (i - 1) * (button_spacing + button_height)
		)

		love.graphics.setColor(1, 1, 1)
	end
end

return {
	start = start,
	update = update,
	draw = draw,
	menu = true
}
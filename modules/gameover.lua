--[[ Game Over menu ]]

local buttons = {}
local button_spacing = 10
local button_height = 30

local function add_button(text, callback)
	local button = {
		text = text,
		callback = callback,
		is_mouse_down = false
	}

	table.insert(buttons, button)
end

local function load()
	add_button("Play Again", function(game)
		game:start_game()
	end)

	add_button("Quit to Menu", function(game)
		game:show_main_menu()
	end)
end

local function get_max_button_width()
	local max_width = 0

	for i, v in ipairs(buttons) do
		local width = love.graphics.getFont():getWidth(v.text)
		if width > max_width then
			max_width = width
		end
	end

	return max_width + 10
end

local function update(dt, game)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()
	local button_width = get_max_button_width()

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
	local button_width = get_max_button_width()

	love.graphics.print("Game Over!", util.center_h("Game Over!", screen_w), util.center_v("Game Over!", screen_h) - 50)

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

	love.graphics.setColor(1, 1, 1)
end

return {
	update = update,
	draw = draw,
	load = load,
	menu = true
}
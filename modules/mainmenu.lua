local font = love.graphics.getFont()
local main_menu_text = love.graphics.newText(font, "thousand points")
local play_button_text = love.graphics.newText(font, "play")
local is_mouse_down = false

local function start()
	font = love.graphics.getFont()
	main_menu_text:setFont(font)
	play_button_text:setFont(font)
	is_mouse_down = false
	print("Main menu started.")
end

local function update(dt, game)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()

	if love.mouse.isDown(1) and game.util.point_in_rect(mouse_x, mouse_y, screen_w / 2 - 50, screen_h / 2 + 40, 100, 30) then
		if not is_mouse_down then
			is_mouse_down = true
		end
	elseif is_mouse_down then
		is_mouse_down = false
		print("Starting game!")
		game:switch_module("breakout")
	end
end

local function draw(game)
	local util = game.util
	local screen_w, screen_h = love.graphics.getDimensions()

	love.graphics.draw(
		main_menu_text,
		util.center_h(main_menu_text, screen_w),
		util.center_v(main_menu_text, screen_h) - 50
	)

	if is_mouse_down then
		love.graphics.setColor(0.2, 0.9, 0.1)
	end

	love.graphics.rectangle(
		"line",
		screen_w / 2 - 50,
		screen_h / 2 + 40,
		100,
		30
	)

	love.graphics.draw(
		play_button_text,
		util.center_h(play_button_text, screen_w),
		util.center_v(play_button_text, screen_h) + 55
	)

	love.graphics.setColor(1, 1, 1)
end

return { start = start, update = update, draw = draw }

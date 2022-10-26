local font = love.graphics.getFont()
local main_menu_text = love.graphics.newText(font, "thousand points")
local play_button_text = love.graphics.newText(font, "play")

function start()
	font = love.graphics.getFont()
	main_menu_text:setFont(font)
	play_button_text:setFont(font)
	print("Main menu started.")
end

function update(dt, game)
	if love.mouse.isDown(1) and game.util.point_in_rect(love.mouse.getX(), love.mouse.getY(), 100, 100, 100, 50) then
		print("Clicked")
	end
end

function draw(game)
	local util = game.util
	local screen_w, screen_h = love.graphics.getDimensions()

	love.graphics.draw(
		main_menu_text,
		util.center_h(main_menu_text, screen_w),
		util.center_v(main_menu_text, screen_h) - 50
	)

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
end

return { start = start, update = update, draw = draw }

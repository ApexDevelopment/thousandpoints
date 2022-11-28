local ABOUT_TEXT = {
	"A game by Micah H.",
	" ",
	"Earn a thousand points in each minigame.",
	"Most minigames control with mouse or arrow keys."
}
local TEXT_HEIGHT = 20 * #ABOUT_TEXT

local buttons = {}
local button_spacing = 10
local button_height = 30

local function start(game)
	buttons = {}

	table.insert(buttons, game.util.button("Back to Menu", function(game)
		game:show_main_menu()
	end))
end

local function update(dt, game)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()
	local button_width = game.util.get_max_button_width(buttons)

	for i, button in ipairs(buttons) do
		local button_x = screen_w / 2 - button_width / 2
		local button_y = screen_h / 2 + (i - 1) * (button_height + button_spacing) + TEXT_HEIGHT

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

	local about_title_text = "About 1000 Points"
	love.graphics.print(about_title_text, util.center_h(about_title_text, screen_w), love.graphics.getHeight() / 2 - TEXT_HEIGHT)

	for i, line in ipairs(ABOUT_TEXT) do
		love.graphics.print(line, util.center_h(line, screen_w), util.center_v(line, screen_h) + (i - 1) * 20 - TEXT_HEIGHT / 2)
	end

	for i, button in ipairs(buttons) do
		if button.is_mouse_down then
			love.graphics.setColor(0.2, 0.9, 0.1)
		else
			love.graphics.setColor(1, 1, 1)
		end

		love.graphics.rectangle(
			"line",
			screen_w / 2 - button_width / 2,
			screen_h / 2 + (i - 1) * (button_spacing + button_height) + TEXT_HEIGHT,
			button_width,
			button_height
		)

		love.graphics.print(
			button.text,
			util.center_h(button.text, screen_w),
			util.center_v(button.text, screen_h) + (button_height / 2) + (i - 1) * (button_spacing + button_height) + TEXT_HEIGHT
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
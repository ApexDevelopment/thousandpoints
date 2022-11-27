local font = love.graphics.getFont()

local buttons = {}
local button_spacing = 10
local button_height = 30

local countdown = 3
local counting = false

local function start(game)
	buttons = {}
	countdown = 3
	counting = false

	table.insert(buttons, game.util.button("Play", function(game)
		counting = true
	end))

	table.insert(buttons, game.util.button("Settings", function(game)
		game:switch_module("settings")
	end))

	table.insert(buttons, game.util.button("Exit", function(game)
		love.event.quit()
	end))

	font = love.graphics.getFont()
	print("Main menu started.")
end

local function update(dt, game)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()
	local button_width = game.util.get_max_button_width(buttons)

	if counting then
		countdown = countdown - dt
		if countdown <= 0 then
			game:start_game()
		end
	else
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
end

local function draw(game)
	local util = game.util
	local screen_w, screen_h = love.graphics.getDimensions()
	local button_width = game.util.get_max_button_width(buttons)

	if counting then
		local text = "Get ready"
		local dispnum = tostring(math.ceil(countdown))
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(text, util.center_h(text, screen_w), util.center_v(text, screen_h) - 50)
		love.graphics.print(dispnum, util.center_h(dispnum, screen_w), util.center_v(dispnum, screen_h))
	else
		local thousand_points_text = "Thousand Points"
		love.graphics.print(thousand_points_text, util.center_h(thousand_points_text, screen_w), util.center_v(thousand_points_text, screen_h) - 50)

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
end

return {
	start = start,
	update = update,
	draw = draw,
	menu = true
}

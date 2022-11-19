--[[ Settings menu overlay module ]]

local is_mouse_down = false

local function update(dt, game)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()

	if love.mouse.isDown(1) and game.util.point_in_rect(mouse_x, mouse_y, screen_w / 2 - 60, screen_h / 2 + 40, 120, 30) then
		if not is_mouse_down then
			is_mouse_down = true
		end
	elseif is_mouse_down then
		is_mouse_down = false
		-- For now we'll just change the pixel size
		game.settings.PIXEL_SIZE = game.settings.PIXEL_SIZE + 1

		if game.settings.PIXEL_SIZE > 12 then
			game.settings.PIXEL_SIZE = 1
		end
		-- If the current module has a settings update function, call it
		if game.current_module and game.current_module.settings_update then
			game.current_module.settings_update(game.settings)
		end
	end
end

local function draw(game)
	love.graphics.setColor(1, 1, 1)
	local util = game.util
	local screen_w, screen_h = love.graphics.getDimensions()

	love.graphics.print("Settings", util.center_h("Settings", screen_w), util.center_v("Settings", screen_h) - 50)

	if is_mouse_down then
		love.graphics.setColor(0.2, 0.9, 0.1)
	end

	love.graphics.rectangle(
		"line",
		screen_w / 2 - 60,
		screen_h / 2 + 40,
		120,
		30
	)

	local scale_button_text = "Scale: " .. game.settings.PIXEL_SIZE
	love.graphics.print(
		scale_button_text,
		util.center_h(scale_button_text, screen_w),
		util.center_v(scale_button_text, screen_h) + 55
	)
	love.graphics.setColor(1, 1, 1)
end

return {
	update = update,
	draw = draw,
	menu = true
}
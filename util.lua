local function round(num)
	return math.floor(num + 0.5)
end

local function point_in_rect(px, py, rx, ry, rw, rh)
	return px > rx and py > ry and px < rx + rw and py < ry + rh
end

local function center_h(drawable, screen_w)
	if type(drawable) == "string" then
		return screen_w / 2 - love.graphics.getFont():getWidth(drawable) / 2
	end

	return screen_w / 2 - drawable:getWidth() / 2
end

local function center_v(drawable, screen_h)
	if type(drawable) == "string" then
		return screen_h / 2 - love.graphics.getFont():getHeight() / 2
	end

	return screen_h / 2 - drawable:getHeight() / 2
end

local function shuffle(array)
	local n = #array

	-- For each element in the array, swap it with a random other element.
	while n > 2 do
		local k = math.random(n)
		array[n], array[k] = array[k], array[n]
		n = n - 1
	end
end

local function shallow_copy_table(t)
	local copy = {}

	for k, v in pairs(t) do
		copy[k] = v
	end

	return copy
end

local function swap_xy_inplace(t)
	local x, y = t.x, t.y
	t.x, t.y = y, x
end

local function button(text, callback)
	return {
		text = text,
		callback = callback,
		is_mouse_down = false
	}
end

local function get_max_button_width(buttons)
	local max_width = 0

	for i, v in ipairs(buttons) do
		local width = love.graphics.getFont():getWidth(v.text)
		if width > max_width then
			max_width = width
		end
	end

	return max_width + 10
end

local function is_gamepad_down_on_any_joystick(button)
	for i, joystick in ipairs(love.joystick.getJoysticks()) do
		if joystick:isGamepadDown(button) then
			return true
		end
	end

	return false
end

local function is_gamepad_stick_left_on_any_joystick(stick)
	for i, joystick in ipairs(love.joystick.getJoysticks()) do
		local axis = joystick:getGamepadAxis(stick .. "x")
		if axis < -0.2 then
			return -axis
		end
	end

	return 0
end

local function is_gamepad_stick_right_on_any_joystick(stick)
	for i, joystick in ipairs(love.joystick.getJoysticks()) do
		local axis = joystick:getGamepadAxis(stick .. "x")
		if axis > 0.2 then
			return axis
		end
	end

	return 0
end

local function is_gamepad_stick_up_on_any_joystick(stick)
	for i, joystick in ipairs(love.joystick.getJoysticks()) do
		local axis = joystick:getGamepadAxis(stick .. "y")
		if axis < -0.2 then
			return -axis
		end
	end

	return 0
end

local function is_gamepad_stick_down_on_any_joystick(stick)
	for i, joystick in ipairs(love.joystick.getJoysticks()) do
		local axis = joystick:getGamepadAxis(stick .. "y")
		if axis > 0.2 then
			return axis
		end
	end

	return 0
end

local function is_move_left()
	if love.keyboard.isDown("left") or love.keyboard.isDown("a") or is_gamepad_down_on_any_joystick("dpleft") then
		return 1
	else
		return is_gamepad_stick_left_on_any_joystick("right")
	end
end

local function is_move_right()
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") or is_gamepad_down_on_any_joystick("dpright") then
		return 1
	else
		return is_gamepad_stick_right_on_any_joystick("right")
	end
end

local function is_move_up()
	if love.keyboard.isDown("up") or love.keyboard.isDown("w") or is_gamepad_down_on_any_joystick("dpup") then
		return 1
	else
		return is_gamepad_stick_up_on_any_joystick("right")
	end
end

local function is_move_down()
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") or is_gamepad_down_on_any_joystick("dpdown") then
		return 1
	else
		return is_gamepad_stick_down_on_any_joystick("right")
	end
end

local function is_action()
	return love.keyboard.isDown("space") or love.keyboard.isDown("return") or love.mouse.isDown(1) or is_gamepad_down_on_any_joystick("a") or is_gamepad_down_on_any_joystick("triggerleft") or is_gamepad_down_on_any_joystick("triggerright")
end

return {
	round = round,
	point_in_rect = point_in_rect,
	center_h = center_h,
	center_v = center_v,
	shuffle = shuffle,
	shallow_copy_table = shallow_copy_table,
	swap_xy_inplace = swap_xy_inplace,
	button = button,
	get_max_button_width = get_max_button_width,
	is_move_left = is_move_left,
	is_move_right = is_move_right,
	is_move_up = is_move_up,
	is_move_down = is_move_down,
	is_action = is_action
}
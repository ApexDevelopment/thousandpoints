local FIELD_WIDTH = 60
local FIELD_HEIGHT = 40
local PIXEL_SIZE = 10
local TICKS_PER_SECOND = 20
local SHRINK_BRICKS = 0.2

local ball_position = {x = 0, y = 0}
local ball_velocity = {x = 0, y = 0}
local paddle_position = math.floor(FIELD_WIDTH / 2)
local paddle_width = 5
local bricks = {} -- Each brick is a table with x, y, width, height, and color.
local last_hit_was_paddle = true
local combo = 0
local time_since_last_tick = 0

local function reset_ball()
	last_hit_was_paddle = true
	combo = 0

	ball_position.x = math.floor(FIELD_WIDTH / 2)
	ball_position.y = math.floor(FIELD_HEIGHT / 2)
	ball_velocity.x = math.random(-2, 2)
	ball_velocity.y = math.random(-2, 2)

	if ball_velocity.x == 0 then
		ball_velocity.x = 1
	end

	if ball_velocity.y == 0 then
		ball_velocity.y = 1
	end
end

local function check_wall_collision(x, y)
	if y < 0 then
		return true, 0, 1, 1, -1
	elseif x < 0 then
		return true, 1, 0, -1, 1
	elseif x >= FIELD_WIDTH then
		return true, -1, 0, -1, 1
	end

	return false, 0, 0, 1, 1
end

local function check_paddle_collision(x, y, game)
	if y > FIELD_HEIGHT - 3 then
		if x >= paddle_position and x < paddle_position + paddle_width then
			last_hit_was_paddle = true
			return true, 0, -1, 1, -1
		else
			reset_ball()
			game:lose_life()
			return true, 0, 0, 0, 0
		end
	end

	return false, 0, 0, 1, 1
end

local function check_brick_collision(prev_x, prev_y, x, y, game)
	for i, brick in ipairs(bricks) do
		if x >= brick.x and x < brick.x + brick.width and y >= brick.y and y < brick.y + brick.height then
			table.remove(bricks, i)

			if not last_hit_was_paddle then
				combo = combo + 1
			end

			game:add_score(50 + combo * 10)
			last_hit_was_paddle = false

			local x_collision_left = false
			local x_collision_right = false
			local y_collision_top = false
			local y_collision_bottom = false

			if prev_x < brick.x then
				x_collision_left = true
			elseif prev_x >= brick.x + brick.width then
				x_collision_right = true
			end

			if prev_y < brick.y then
				y_collision_top = true
			elseif prev_y >= brick.y + brick.height then
				y_collision_bottom = true
			end

			if x_collision_left and y_collision_top then
				return true, -1, -1, -1, -1
			elseif x_collision_left and y_collision_bottom then
				return true, -1, 1, -1, -1
			elseif x_collision_right and y_collision_top then
				return true, 1, -1, -1, -1
			elseif x_collision_right and y_collision_bottom then
				return true, 1, 1, -1, -1
			elseif x_collision_left then
				return true, -1, 0, -1, 1
			elseif x_collision_right then
				return true, 1, 0, -1, 1
			elseif y_collision_top then
				return true, 0, -1, 1, -1
			elseif y_collision_bottom then
				return true, 0, 1, 1, -1
			end
		end
	end

	return false, 0, 0, 1, 1
end

local function update_ball(game)
	-- Check for any collisions that may occur between where the ball is now and where it will be next tick.
	local ball_velocity_x = ball_velocity.x
	local ball_velocity_y = ball_velocity.y

	while ball_velocity_x ~= 0 or ball_velocity_y ~= 0 do
		local ball_next_position_x = ball_position.x
		local ball_next_position_y = ball_position.y

		if ball_velocity_x > 0 then
			ball_next_position_x = ball_next_position_x + 1
			ball_velocity_x = ball_velocity_x - 1
		elseif ball_velocity_x < 0 then
			ball_next_position_x = ball_next_position_x - 1
			ball_velocity_x = ball_velocity_x + 1
		end

		if ball_velocity_y > 0 then
			ball_next_position_y = ball_next_position_y + 1
			ball_velocity_y = ball_velocity_y - 1
		elseif ball_velocity_y < 0 then
			ball_next_position_y = ball_next_position_y - 1
			ball_velocity_y = ball_velocity_y + 1
		end

		local collided, x_move, y_move, x_vel_mult, y_vel_mult = check_wall_collision(ball_next_position_x, ball_next_position_y)
		if collided then
			ball_next_position_x = ball_next_position_x + x_move
			ball_next_position_y = ball_next_position_y + y_move
			ball_velocity_x = ball_velocity_x * x_vel_mult
			ball_velocity_y = ball_velocity_y * y_vel_mult
			ball_velocity.x = ball_velocity.x * x_vel_mult
			ball_velocity.y = ball_velocity.y * y_vel_mult
		end

		collided, x_move, y_move, x_vel_mult, y_vel_mult = check_paddle_collision(ball_next_position_x, ball_next_position_y, game)
		if collided then
			if x_vel_mult ~= 0 then
				ball_next_position_x = ball_next_position_x + x_move
				ball_next_position_y = ball_next_position_y + y_move
				ball_velocity_x = ball_velocity_x * x_vel_mult
				ball_velocity_y = ball_velocity_y * y_vel_mult
				ball_velocity.x = ball_velocity.x * x_vel_mult
				ball_velocity.y = ball_velocity.y * y_vel_mult
			else
				break
			end
		end

		collided, x_move, y_move, x_vel_mult, y_vel_mult = check_brick_collision(ball_position.x, ball_position.y, ball_next_position_x, ball_next_position_y, game)
		if collided then
			ball_next_position_x = ball_next_position_x + x_move
			ball_next_position_y = ball_next_position_y + y_move
			ball_velocity_x = ball_velocity_x * x_vel_mult
			ball_velocity_y = ball_velocity_y * y_vel_mult
			ball_velocity.x = ball_velocity.x * x_vel_mult
			ball_velocity.y = ball_velocity.y * y_vel_mult
		end

		ball_position.x = ball_next_position_x
		ball_position.y = ball_next_position_y
	end
end

local function update_paddle()
	if love.keyboard.isDown("left") then
		paddle_position = paddle_position - 1
	elseif love.keyboard.isDown("right") then
		paddle_position = paddle_position + 1
	end

	-- Update player paddle based on mouse input (if mouse is in the game field)
	local mouse_x, mouse_y = love.mouse.getPosition()
	local screen_w, screen_h = love.graphics.getDimensions()
	local field_w = FIELD_WIDTH * PIXEL_SIZE
	local field_h = FIELD_HEIGHT * PIXEL_SIZE
	local field_x = (screen_w - field_w) / 2
	local field_y = (screen_h - field_h) / 2

	if mouse_x >= field_x and mouse_x < field_x + field_w and mouse_y >= field_y and mouse_y < field_y + field_h then
		paddle_position = math.floor((mouse_x - field_x) / PIXEL_SIZE)
	end

	if paddle_position < 0 then
		paddle_position = 0
	elseif paddle_position > FIELD_WIDTH - paddle_width then
		paddle_position = FIELD_WIDTH - paddle_width
	end
end

local function color_for_location(x, y)
	local r = x / FIELD_WIDTH
	local g = y / 5
	local b = (x + y) / (FIELD_WIDTH + 5)
	-- Clamp color so that it's not too dark
	r = math.max(r, 0.3)
	g = math.max(g, 0.3)
	b = math.max(b, 0.3)
	return { r, g, b }
end

local function generate_bricks()
	bricks = {}

	-- Set brick width based on field width
	local brick_width = math.floor(FIELD_WIDTH / 10)
	if brick_width < 1 then
		brick_width = 1
	end

	-- Generate bricks
	for y = 1, 10, 2 do
		for x = brick_width, FIELD_WIDTH - brick_width * 2, brick_width do
			local brick = {
				x = x,
				y = y,
				width = brick_width,
				height = 2,
				color = color_for_location(x, y)
			}
			table.insert(bricks, brick)
		end
	end
end

local function start()
	generate_bricks()
	reset_ball()
end
local function update(dt, game)
	time_since_last_tick = time_since_last_tick + dt

	if time_since_last_tick >= 1 / TICKS_PER_SECOND then
		update_ball(game)
		time_since_last_tick = 0
	end

	update_paddle()
end

local function draw(game)
	PIXEL_SIZE = game.settings.PIXEL_SIZE

	love.graphics.push("all")
	love.graphics.translate(love.graphics.getWidth() / 2 - FIELD_WIDTH * PIXEL_SIZE / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2)
	-- Draw border around play field
	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)

	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)

	-- Draw bricks
	for i = 1, #bricks do
		local brick = bricks[i]
		love.graphics.setColor(brick.color)
		love.graphics.rectangle("fill", brick.x + SHRINK_BRICKS, brick.y + SHRINK_BRICKS, brick.width - 2 * SHRINK_BRICKS, brick.height - 2 * SHRINK_BRICKS)
	end
	love.graphics.setColor(1, 1, 1)

	-- Draw ball
	love.graphics.rectangle("fill", ball_position.x, ball_position.y, 1, 1)

	-- Draw paddle
	love.graphics.rectangle("fill", paddle_position, FIELD_HEIGHT - 2, paddle_width, 1)

	love.graphics.pop()
	local score_text = "Score: " .. game.points
	love.graphics.print(score_text, love.graphics.getWidth() / 2 - love.graphics.getFont():getWidth(score_text) / 2, 10)

	return FIELD_WIDTH, FIELD_HEIGHT
end

return {
	update = update,
	draw = draw,
	start = start
}
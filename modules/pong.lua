local FIELD_WIDTH = 60
local FIELD_HEIGHT = 40
local PIXEL_SIZE = 10
local TICKS_PER_SECOND = 20

local ball_position = {x = 0, y = 0}
local ball_velocity = {x = 0, y = 0}
local paddle_position = 0
local d_paddle_position = 0
local bot_paddle_position = 0
local paddle_height = 5
local bot_score = 0
local time_since_last_tick = 0

local last_mouse_y = 0

local function reset_ball()
	ball_position.x = math.floor(FIELD_WIDTH / 2)
	ball_position.y = math.random(2, FIELD_HEIGHT - 3)
	ball_velocity.x = -1
	ball_velocity.y = math.random(-1, 1)

	if ball_velocity.y == 0 then
		ball_velocity.y = 1
	end
end

local function update_ball(game)
	-- Check for any collisions that may occur between where the ball is now and where it will be next tick.
	local ball_next_position = {x = ball_position.x + ball_velocity.x, y = ball_position.y + ball_velocity.y}

	-- Check for collisions with the top and bottom of the field.
	if ball_next_position.y < 0 then
		ball_next_position.y = 0
		ball_velocity.y = -ball_velocity.y
	elseif ball_next_position.y >= FIELD_HEIGHT then
		ball_next_position.y = FIELD_HEIGHT - 1
		ball_velocity.y = -ball_velocity.y
	end

	-- Check for collisions with the paddles.
	if ball_next_position.x < 2 then
		if ball_next_position.y >= paddle_position and ball_next_position.y < paddle_position + paddle_height then
			ball_next_position.x = 2
			ball_velocity.x = -ball_velocity.x

			-- If the ball hits the paddle at the top or bottom, it should bounce at a 45 degree angle.
			if ball_next_position.y == paddle_position then
				ball_velocity.y = -1
			elseif ball_next_position.y == paddle_position + paddle_height - 1 then
				ball_velocity.y = 1
			end

			-- If the player smashes the ball, it should go faster.
			if d_paddle_position * ball_velocity.y < 0 then
				-- The ball is moving in the opposite direction as the paddle, so we change x velocity
				ball_velocity.x = math.min(3, math.max(1, math.floor(4 * (1 - 1 / (d_paddle_position + 1)))))
			else
				-- The ball is moving in the same direction as the paddle, so we change y velocity
				ball_velocity.y = (ball_velocity.y / math.abs(ball_velocity.y)) * math.min(3, math.max(1, math.floor(4 * (1 - 1 / (d_paddle_position + 1)))))
			end
		else
			bot_score = bot_score + 250
			game:lose_life()
			reset_ball()
			return
		end
	elseif ball_next_position.x >= FIELD_WIDTH - 2 then
		if ball_next_position.y >= bot_paddle_position and ball_next_position.y < bot_paddle_position + paddle_height then
			ball_next_position.x = FIELD_WIDTH - 3
			ball_velocity.x = -ball_velocity.x

			-- If the ball hits the paddle at the top or bottom, it should bounce at a 45 degree angle.
			if ball_next_position.y == bot_paddle_position then
				ball_velocity.y = -1
			elseif ball_next_position.y == bot_paddle_position + paddle_height - 1 then
				ball_velocity.y = 1
			end
		else
			game:add_score(100)
			reset_ball()
			return
		end
	end

	ball_position.x = ball_next_position.x
	ball_position.y = ball_next_position.y
end

local function update_player_paddle()
	local old_paddle_position = paddle_position

	-- Update player paddle based on keyboard input
	if love.keyboard.isDown("up") then
		paddle_position = paddle_position - 1
	elseif love.keyboard.isDown("down") then
		paddle_position = paddle_position + 1
	end

	-- Update player paddle based on mouse input
	local mouse_x, mouse_y = love.mouse.getPosition()

	if mouse_y ~= last_mouse_y then
		local screen_w, screen_h = love.graphics.getDimensions()
		local field_w = FIELD_WIDTH * PIXEL_SIZE
		local field_h = FIELD_HEIGHT * PIXEL_SIZE
		local field_y = (screen_h - field_h) / 2
		paddle_position = math.floor((mouse_y - field_y) / PIXEL_SIZE)
	end

	if paddle_position < 0 then
		paddle_position = 0
	elseif paddle_position > FIELD_HEIGHT - paddle_height then
		paddle_position = FIELD_HEIGHT - paddle_height
	end

	-- Add a virtual velocity and velocity falloff so we can determine how hard the player hits the ball
	local dpp = paddle_position - old_paddle_position
	if math.abs(dpp) > math.abs(d_paddle_position) then
		d_paddle_position = dpp
	else
		d_paddle_position = d_paddle_position * 0.98
	end

	last_mouse_y = mouse_y
end

local function update_bot_paddle()
	-- Have the bot follow the ball imperfectly
	if ball_position.x > FIELD_WIDTH / 2 and math.random(100) < 99 then
		if ball_position.y > bot_paddle_position + paddle_height - 2 then
			bot_paddle_position = bot_paddle_position + 1
		elseif ball_position.y < bot_paddle_position + 1 then
			bot_paddle_position = bot_paddle_position - 1
		end
	end

	-- Clamp bot to play field
	if bot_paddle_position < 0 then
		bot_paddle_position = 0
	elseif bot_paddle_position > FIELD_HEIGHT - paddle_height then
		bot_paddle_position = FIELD_HEIGHT - paddle_height
	end
end

local function update(dt, game)
	time_since_last_tick = time_since_last_tick + dt

	if time_since_last_tick >= 1 / TICKS_PER_SECOND then
		update_ball(game)
		update_bot_paddle()
		time_since_last_tick = 0
	end

	update_player_paddle()
end

local function draw(game)
	PIXEL_SIZE = game.settings.PIXEL_SIZE

	love.graphics.push("all")
	love.graphics.translate(love.graphics.getWidth() / 2 - FIELD_WIDTH * PIXEL_SIZE / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2)
	-- Draw border around play field
	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)
	-- Draw the dotted line dividing the field
	for i = 0, FIELD_HEIGHT - 1 do
		love.graphics.rectangle("fill", FIELD_WIDTH * PIXEL_SIZE / 2 - 1, i * PIXEL_SIZE, 2, PIXEL_SIZE / 2)
	end
	-- Draw play field
	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 1, paddle_position, 1, paddle_height)
	love.graphics.rectangle("fill", FIELD_WIDTH - 2, bot_paddle_position, 1, paddle_height)
	love.graphics.rectangle("fill", ball_position.x, ball_position.y, 1, 1)
	love.graphics.pop()

	-- Draw scores
	local score_joiner = "-"
	local score_player_str = tostring(game.points)
	local score_bot_str = tostring(bot_score)
	local score_joiner_width = love.graphics.getFont():getWidth(score_joiner)
	local score_player_str_width = love.graphics.getFont():getWidth(score_player_str)
	local bottom = love.graphics.getHeight() / 2 + FIELD_HEIGHT * PIXEL_SIZE / 2

	love.graphics.print(score_player_str, love.graphics.getWidth() / 2 - score_player_str_width - score_joiner_width / 2 - 5, bottom)
	love.graphics.print(score_joiner, love.graphics.getWidth() / 2 - score_joiner_width / 2, bottom)
	love.graphics.print(score_bot_str, love.graphics.getWidth() / 2 + score_joiner_width / 2 + 5, bottom)

	return FIELD_WIDTH, FIELD_HEIGHT, true
end

local function start(game)
	reset_ball()
	bot_score = 0
end

return {
	update = update,
	draw = draw,
	start = start
}

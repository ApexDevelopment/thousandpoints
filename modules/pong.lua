local FIELD_WIDTH = 60
local FIELD_HEIGHT = 40
local PIXEL_SIZE = 10
local TICKS_PER_SECOND = 20

local ball_position = {x = 0, y = 0}
local ball_velocity = {x = 0, y = 0}
local paddle_position = 0
local bot_paddle_position = 0
local paddle_height = 5
local score = {player = 0, bot = 0}
local time_since_last_tick = 0

local function reset_ball()
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

local function update_ball()
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
		else
			score.bot = score.bot + 1
			reset_ball()
			return
		end
	elseif ball_next_position.x >= FIELD_WIDTH - 2 then
		if ball_next_position.y >= bot_paddle_position and ball_next_position.y < bot_paddle_position + paddle_height then
			ball_next_position.x = FIELD_WIDTH - 3
			ball_velocity.x = -ball_velocity.x
		else
			score.player = score.player + 1
			reset_ball()
			return
		end
	end

	ball_position.x = ball_next_position.x
	ball_position.y = ball_next_position.y
end

local function update_paddles()
	-- Update player paddle based on keyboard input
	if love.keyboard.isDown("up") then
		paddle_position = paddle_position - 1
	elseif love.keyboard.isDown("down") then
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
		paddle_position = math.floor((mouse_y - field_y) / PIXEL_SIZE)
	end

	if paddle_position < 0 then
		paddle_position = 0
	elseif paddle_position > FIELD_HEIGHT - paddle_height then
		paddle_position = FIELD_HEIGHT - paddle_height
	end

	-- TODO: More advanced bot
	bot_paddle_position = ball_position.y - paddle_height / 2
	-- Clamp bot to play field
	if bot_paddle_position < 0 then
		bot_paddle_position = 0
	elseif bot_paddle_position > FIELD_HEIGHT - paddle_height then
		bot_paddle_position = FIELD_HEIGHT - paddle_height
	end
end

local function update(dt)
	time_since_last_tick = time_since_last_tick + dt
	if time_since_last_tick > 1 / TICKS_PER_SECOND then
		update_ball()
		time_since_last_tick = 0
	end

	update_paddles()
end

local function draw()
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth() / 2 - FIELD_WIDTH * PIXEL_SIZE / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2)
	-- Draw border around play field
	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)
	-- Draw the dotted line dividing the field
	for i = 0, FIELD_HEIGHT - 1 do
		love.graphics.rectangle("fill", FIELD_WIDTH * PIXEL_SIZE / 2 - 1, i * PIXEL_SIZE, 2, PIXEL_SIZE / 2)
	end
	-- Draw play field
	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", 1, paddle_position, 1, paddle_height)
	love.graphics.rectangle("fill", FIELD_WIDTH - 2, bot_paddle_position, 1, paddle_height)
	love.graphics.rectangle("fill", ball_position.x, ball_position.y, 1, 1)
	love.graphics.pop()
	
	-- Draw scores
	local score_text = score.player .. " - " .. score.bot
	local score_text_width = love.graphics.getFont():getWidth(score_text)
	local score_text_height = love.graphics.getFont():getHeight(score_text)
	love.graphics.print(score_text, love.graphics.getWidth() / 2 - score_text_width / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2 - score_text_height - 10)
end

local function keypressed(key, game)
	if key == "escape" then
		game:switch_module("mainmenu")
	end
end

local function start()
	reset_ball()
end

return { update = update, draw = draw, start = start, keypressed = keypressed }

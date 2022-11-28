local FIELD_WIDTH = 50
local FIELD_HEIGHT = 50
local TICKS_PER_SECOND = 12

local snake = {}
local snake_direction = 1
local apple_position = {x = 0, y = 0}
local time_since_last_tick = 0

local function move_snake()
	for i = #snake, 2, -1 do
		snake[i].x = snake[i - 1].x
		snake[i].y = snake[i - 1].y
	end

	if snake_direction == 1 then
		snake[1].x = snake[1].x + 1
	elseif snake_direction == 2 then
		snake[1].y = snake[1].y + 1
	elseif snake_direction == 3 then
		snake[1].x = snake[1].x - 1
	elseif snake_direction == 4 then
		snake[1].y = snake[1].y - 1
	end
end

local function reset_apple_position()
	apple_position.x = math.random(FIELD_WIDTH - 1)
	apple_position.y = math.random(FIELD_HEIGHT - 1)
end

local function reset_snake()
	snake = {
		{
			x = math.floor(FIELD_WIDTH / 2),
			y = math.floor(FIELD_HEIGHT / 2)
		},
		{
			x = math.floor(FIELD_WIDTH / 2) - 1,
			y = math.floor(FIELD_HEIGHT / 2)
		},
		{
			x = math.floor(FIELD_WIDTH / 2) - 2,
			y = math.floor(FIELD_HEIGHT / 2)
		}
	}
	snake_direction = 1
	reset_apple_position()
end

local function handle_player_input(util)
	if util.is_move_left() ~= 0 then
		snake_direction = 3
	elseif util.is_move_right() ~= 0 then
		snake_direction = 1
	elseif util.is_move_up() ~= 0 then
		snake_direction = 4
	elseif util.is_move_down() ~= 0 then
		snake_direction = 2
	end
end

local function start()
	reset_snake()
end

local function update(dt, game)
	time_since_last_tick = time_since_last_tick + dt
	if time_since_last_tick > 1 / TICKS_PER_SECOND then
		move_snake()

		if snake[1].x < 0 or snake[1].x >= FIELD_WIDTH or snake[1].y < 0 or snake[1].y >= FIELD_HEIGHT then
			reset_snake()
			game:lose_life()
			return
		end

		for i = 2, #snake do
			if snake[1].x == snake[i].x and snake[1].y == snake[i].y then
				reset_snake()
				game:lose_life()
				return
			end
		end

		if snake[1].x == apple_position.x and snake[1].y == apple_position.y then
			reset_apple_position()
			TICKS_PER_SECOND = TICKS_PER_SECOND + 2
			game:add_score(150)
			table.insert(snake, {x = snake[#snake].x, y = snake[#snake].y})
		end

		time_since_last_tick = 0
	end

	handle_player_input(game.util)
end

local function draw(game)
	local PIXEL_SIZE = game.settings.PIXEL_SIZE

	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth() / 2 - FIELD_WIDTH * PIXEL_SIZE / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2)

	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)

	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)

	for i = 1, #snake do
		love.graphics.rectangle("fill", snake[i].x, snake[i].y, 1, 1)
	end

	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", apple_position.x, apple_position.y, 1, 1)
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)

	return FIELD_WIDTH, FIELD_HEIGHT
end

return {
	start = start,
	update = update,
	draw = draw
}
local FIELD_WIDTH = 60
local FIELD_HEIGHT = 40
local PIXEL_SIZE = 10
local TICKS_PER_SECOND = 20
local NUM_ALIENS_IN_ROW = (FIELD_WIDTH - 2)
local NUM_ALIEN_ROWS = 4
local NUM_ALIENS = NUM_ALIENS_IN_ROW * NUM_ALIEN_ROWS

local time_since_last_tick = 0

local ship_position = math.floor(FIELD_WIDTH / 2)

local alien_positions = {}
local alien_direction = 1
local alien_tick = 0
local alien_tick_threshold = TICKS_PER_SECOND * 5

local bullet_position = nil
local bullet_velocity = 1

local score = 0

local function reset_alien_positions()
	for i = 1, NUM_ALIENS do
		alien_positions[i] = {x = (i - 1) % NUM_ALIENS_IN_ROW + 1, y = math.floor((i - 1) / NUM_ALIENS_IN_ROW) + 1}
	end
	-- for i = 1, NUM_ALIENS do
	-- 	alien_positions[i] = {x = i % NUM_ALIENS_IN_ROW, y = math.floor(i / NUM_ALIENS_IN_ROW)}
	-- end
end

local function move_aliens_down()
	for i = 1, #alien_positions do
		alien_positions[i].y = alien_positions[i].y + 1
	end
end

local function update_alien_positions()
	if alien_tick % 10 == 0 then
		for i = 1, #alien_positions do
			alien_positions[i].x = alien_positions[i].x + alien_direction
		end
	end

	alien_tick = alien_tick + 1

	if alien_tick >= alien_tick_threshold then
		alien_tick = 0
		alien_direction = -alien_direction
		move_aliens_down()
	end

	for i = 1, #alien_positions do
		if alien_positions[i].x == 0 or alien_positions[i].x == FIELD_WIDTH - 1 then
			alien_direction = -alien_direction
			--alien_tick_threshold = alien_tick_threshold - 5
			return
		end
	end
end

local function update_bullet()
	if bullet_position == nil then
		return
	end

	bullet_position.y = bullet_position.y - bullet_velocity

	if bullet_position.y < 0 then
		bullet_position = nil
	end
end

local function check_bullet_collision()
	if bullet_position == nil then
		return
	end

	for i = 1, #alien_positions do
		if alien_positions[i].x == bullet_position.x and alien_positions[i].y == bullet_position.y then
			table.remove(alien_positions, i)
			bullet_position = nil
			score = score + 1
			return
		end
	end
end

local function update_player_position()
	if love.keyboard.isDown("left") then
		ship_position = ship_position - 1
	end

	if love.keyboard.isDown("right") then
		ship_position = ship_position + 1
	end

	if ship_position < 0 then
		ship_position = 0
	end

	if ship_position >= FIELD_WIDTH then
		ship_position = FIELD_WIDTH - 1
	end
end

local function fire_bullet()
	if bullet_position == nil and love.keyboard.isDown("space") then
		bullet_position = { x = ship_position, y = FIELD_HEIGHT - 2 }
	end
end

local function start()
	reset_alien_positions()
end

local function update(dt)
	time_since_last_tick = time_since_last_tick + dt
	if time_since_last_tick > 1 / TICKS_PER_SECOND then
		update_alien_positions()
		update_bullet()
		check_bullet_collision()
	end

	update_player_position()
	fire_bullet()
end

local function draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)

	love.graphics.push()
	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)

	love.graphics.setColor(1, 1, 1)
	for i = 1, #alien_positions do
		love.graphics.rectangle(
			"fill",
			alien_positions[i].x,
			alien_positions[i].y,
			1,
			1
		)
	end

	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle(
		"fill",
		ship_position,
		FIELD_HEIGHT - 1,
		1,
		1
	)

	if bullet_position ~= nil then
		love.graphics.setColor(0, 1, 0)
		love.graphics.rectangle(
			"fill",
			bullet_position.x,
			bullet_position.y,
			1,
			1
		)
	end

	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Score: " .. score, 0, 0)
end

return { start = start, update = update, draw = draw }
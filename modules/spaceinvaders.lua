local FIELD_WIDTH = 60
local FIELD_HEIGHT = 40
local PIXEL_SIZE = 10
local TICKS_PER_SECOND = 20
local NUM_ALIENS = (FIELD_WIDTH - 2) * 4

local time_since_last_tick = 0

local ship_position = math.floor(FIELD_WIDTH / 2)

local alien_positions = {}
local alien_direction = 1
local alien_velocity = 1
local alien_tick = 0
local alien_tick_threshold = 10

local bullet_position = nil
local bullet_velocity = 1

local score = 0

local function reset_alien_positions()
	for i = 1, #alien_positions do
		alien_positions[i] = {x = i % 10, y = math.floor(i / 10)}
	end
end

local function update_alien_positions()
	for i = 1, #alien_positions do
		alien_positions[i].x = alien_positions[i].x + alien_direction * alien_velocity
	end

	alien_tick = alien_tick + 1

	if alien_tick >= alien_tick_threshold then
		alien_tick = 0
		alien_velocity = alien_velocity + 1
		alien_direction = -alien_direction
	end

	for i = 1, #alien_positions do
		if alien_positions[i].x == 0 or alien_positions[i].x == FIELD_WIDTH - 1 then
			alien_direction = -alien_direction
			alien_velocity = alien_velocity + 1
			alien_tick_threshold = alien_tick_threshold - 1
			return
		end
	end
end

local function update_bullet()
	if bullet_position == nil then
		return
	end

	bullet_position = bullet_position + bullet_velocity

	if bullet_position < 0 then
		bullet_position = nil
	end
end

local function check_bullet_collision()
	if bullet_position == nil then
		return
	end

	for i = 1, #alien_positions do
		if alien_positions[i].x == bullet_position and alien_positions[i].y == ship_position then
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

local function update(dt)
	time_since_last_tick = time_since_last_tick + dt
	if time_since_last_tick > 1 / TICKS_PER_SECOND then
		update_alien_positions()
		update_bullet()
		check_bullet_collision()
	end

	update_player_position()
end
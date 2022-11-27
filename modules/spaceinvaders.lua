local FIELD_WIDTH = 60
local FIELD_HEIGHT = 40
local TICKS_PER_SECOND = 20
local NUM_ALIENS_IN_ROW = (FIELD_WIDTH - 4)
local NUM_ALIEN_ROWS = 4
local NUM_ALIENS = NUM_ALIENS_IN_ROW * NUM_ALIEN_ROWS

local SHIP_SPRITE = {
	{0, 0, 1, 0, 0},
	{0, 1, 1, 1, 0},
	{0, 1, 0, 1, 0},
	{1, 1, 1, 1, 1},
	{1, 0, 0, 0, 1}
}

local ALIEN_SPRITE = {
	{1, 0, 1},
	{1, 1, 1},
	{0, 1, 0}
}

local time_since_last_tick = 0

local ship_position = math.floor(FIELD_WIDTH / 2)

local alien_positions = {}
local alien_bullet_positions = {}
local alien_direction = 1
local alien_tick = 0
local alien_tick_threshold = TICKS_PER_SECOND * 5

local bullet_positions = {}
local bullet_velocity = 1
local bullet_cooldown = 0
local bullet_update_tick = 0

local game_freeze_timer = 0
local ship_blink_timer = 0
local ship_blink_state = false

local function reset_alien_positions()
	for i = 1, NUM_ALIENS do
		alien_positions[i] = {x = (i - 1) % NUM_ALIENS_IN_ROW, y = math.floor((i - 1) / NUM_ALIENS_IN_ROW) + 1}
	end
end

local function clear_bullets()
	alien_bullet_positions = {}
	bullet_positions = {}
end

local function move_aliens_down()
	for i = 1, #alien_positions do
		alien_positions[i].y = alien_positions[i].y + 1
	end
end

local function update_alien_positions()
	alien_tick = alien_tick + 1

	if alien_tick % 20 == 0 then
		-- Check for collisions with the left and right of the field.
		for i = 1, #alien_positions do
			if alien_positions[i].x == 0 and alien_direction == -1 then
				alien_direction = -alien_direction
				move_aliens_down()
				return
			elseif alien_positions[i].x == FIELD_WIDTH - 1 and alien_direction == 1 then
				alien_direction = -alien_direction
				move_aliens_down()
				return
			end
		end

		for i = 1, #alien_positions do
			alien_positions[i].x = alien_positions[i].x + alien_direction
		end
	end
end

local function update_bullets()
	if #bullet_positions ~= 0 then
		for i = #bullet_positions, 1, -1 do
			bullet_positions[i].y = bullet_positions[i].y - bullet_velocity

			if bullet_positions[i].y < 0 then
				table.remove(bullet_positions, i)
			end
		end
	end

	if #alien_bullet_positions ~= 0 then
		for i = #alien_bullet_positions, 1, -1 do
			alien_bullet_positions[i].y = alien_bullet_positions[i].y + bullet_velocity

			if alien_bullet_positions[i].y >= FIELD_HEIGHT then
				table.remove(alien_bullet_positions, i)
			end
		end
	end
end

local function check_bullet_collision(game)
	if #bullet_positions ~= 0 then
		for i = 1, #bullet_positions do
			for j = 1, #alien_positions do
				if bullet_positions[i].x == alien_positions[j].x and bullet_positions[i].y == alien_positions[j].y then
					table.remove(bullet_positions, i)
					table.remove(alien_positions, j)
					game:add_score(50)
					return
				end
			end
		end
	end

	if #alien_bullet_positions ~= 0 then
		for i = 1, #alien_bullet_positions do
			if alien_bullet_positions[i].x == ship_position and alien_bullet_positions[i].y == FIELD_HEIGHT - 1 then
				alien_bullet_positions[i].y = alien_bullet_positions[i].y - 1 -- Just so the death anim looks better
				game:lose_life()
				game_freeze_timer = 3
				return
			end
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
	if #bullet_positions < 2 and bullet_cooldown == 0 and love.keyboard.isDown("space") then
		table.insert(bullet_positions, {x = ship_position, y = FIELD_HEIGHT - 2})
		bullet_cooldown = 25
	end

	if #alien_bullet_positions < 10 then
		local alien = alien_positions[math.random(#alien_positions)]
		table.insert(alien_bullet_positions, {x = alien.x, y = alien.y})
	end
end

local function start()
	reset_alien_positions()
	clear_bullets()
end

local function update(dt, game)
	if game_freeze_timer > 0 then
		game_freeze_timer = game_freeze_timer - dt

		if ship_blink_timer > 0 then
			ship_blink_timer = ship_blink_timer - dt
		else
			ship_blink_timer = 0.3
			ship_blink_state = not ship_blink_state
		end

		if game_freeze_timer <= 0 then
			clear_bullets()
			ship_position = math.floor(FIELD_WIDTH / 2)
			ship_blink_state = false
		end

		return
	end

	time_since_last_tick = time_since_last_tick + dt
	if time_since_last_tick > 1 / TICKS_PER_SECOND then
		update_alien_positions()

		bullet_update_tick = bullet_update_tick + 1
		if bullet_update_tick > 4 then
			bullet_update_tick = 0
			update_bullets()
		end

		bullet_cooldown = math.max(0, bullet_cooldown - 1)
		check_bullet_collision(game)
		update_player_position()
		fire_bullet()
	end
end

local function draw(game)
	local PIXEL_SIZE = game.settings.PIXEL_SIZE

	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth() / 2 - FIELD_WIDTH * PIXEL_SIZE / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)

	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)

	-- Draw aliens
	love.graphics.setColor(1, 1, 1)
	for i = 1, #alien_positions do
		love.graphics.push("all")
		love.graphics.translate(alien_positions[i].x + 0.25, alien_positions[i].y + 0.25)
		love.graphics.scale(1/4, 1/4)
		for y = 1, 3 do
			for x = 1, 3 do
				if ALIEN_SPRITE[y][x] == 1 then
					love.graphics.rectangle(
						"fill",
						x - 1,
						y - 1,
						1,
						1
					)
				end
			end
		end
		love.graphics.pop()
	end

	-- Draw ship
	if not ship_blink_state then
		love.graphics.setColor(1, 1, 1)
		for y = 1, 5 do
			for x = 1, 5 do
				if SHIP_SPRITE[y][x] == 1 then
					love.graphics.rectangle(
						"fill",
						ship_position + (x - 1) / 5,
						FIELD_HEIGHT - 1.3 + (y - 1) / 5,
						0.2,
						0.2
					)
				end
			end
		end
	end

	-- Draw bullets
	if #bullet_positions ~= 0 then
		love.graphics.setColor(0, 1, 0)

		for i = 1, #bullet_positions do
			love.graphics.rectangle(
				"fill",
				bullet_positions[i].x + 0.3,
				bullet_positions[i].y,
				0.3,
				1
			)
		end
	end

	-- Draw alien bullets
	if #alien_bullet_positions ~= 0 then
		love.graphics.setColor(1, 0, 0)

		for i = 1, #alien_bullet_positions do
			love.graphics.rectangle(
				"fill",
				alien_bullet_positions[i].x + 0.3,
				alien_bullet_positions[i].y,
				0.3,
				1
			)
		end
	end

	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)
	local score_text = "Score: " .. game.points
	love.graphics.print(score_text, love.graphics.getWidth() / 2 - love.graphics.getFont():getWidth(score_text) / 2, 10)

	return FIELD_WIDTH, FIELD_HEIGHT
end

return {
	start = start,
	update = update,
	draw = draw
}
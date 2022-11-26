local FIELD_WIDTH = 10
local FIELD_HEIGHT = 22
local PIXEL_SIZE = 10

local PIECES_X = {
	I = {{0, 1, 2, 3}, {2, 2, 2, 2}, {0, 1, 2, 3}, {1, 1, 1, 1}},
	O = {{1, 2, 1, 2}, {1, 2, 1, 2}, {1, 2, 1, 2}, {1, 2, 1, 2}},
	T = {{1, 0, 1, 2}, {1, 1, 2, 1}, {0, 1, 2, 1}, {1, 0, 1, 1}},
	S = {{1, 2, 0, 1}, {1, 1, 2, 2}, {1, 2, 0, 1}, {0, 0, 1, 1}},
	Z = {{0, 1, 1, 2}, {2, 1, 2, 1}, {0, 1, 1, 2}, {1, 0, 1, 0}},
	J = {{0, 0, 1, 2}, {1, 2, 1, 1}, {0, 1, 2, 2}, {1, 1, 0, 1}},
	L = {{2, 0, 1, 2}, {1, 1, 1, 2}, {0, 1, 2, 0}, {0, 1, 1, 1}}
}

local PIECES_Y = {
	I = {{1, 1, 1, 1}, {0, 1, 2, 3}, {2, 2, 2, 2}, {0, 1, 2, 3}},
	O = {{1, 1, 2, 2}, {1, 1, 2, 2}, {1, 1, 2, 2}, {1, 1, 2, 2}},
	T = {{0, 1, 1, 1}, {0, 1, 1, 2}, {1, 1, 1, 2}, {0, 1, 1, 2}},
	S = {{0, 0, 1, 1}, {0, 1, 1, 2}, {1, 1, 2, 2}, {0, 1, 1, 2}},
	Z = {{0, 0, 1, 1}, {0, 1, 1, 2}, {1, 1, 2, 2}, {0, 1, 1, 2}},
	J = {{0, 1, 1, 1}, {0, 0, 1, 2}, {1, 1, 1, 2}, {0, 1, 2, 2}},
	L = {{0, 1, 1, 1}, {0, 1, 2, 2}, {1, 1, 1, 2}, {0, 0, 1, 2}}
}

local WALLKICKS = {
	{{0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}},
	{{0, 0}, { 1, 0}, {1, -1}, {0,  2}, { 1,  2}},
	{{0, 0}, { 1, 0}, { 1, 1}, {0, -2}, { 1, -2}},
	{{0, 0}, {-1, 0}, {-1,-1}, {0,  2}, {-1,  2}}
}

local WALLKICKS_I = {
	{{0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1,  2}},
	{{0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2, -1}},
	{{0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1, -2}},
	{{0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2,  1}}
};

local PIECE_COLORS = {
	I = {0, 255, 255},
	O = {255, 255, 0},
	T = {165, 0, 165},
	S = {0, 255, 0},
	Z = {255, 0, 0},
	J = {0, 0, 255},
	L = {255, 165, 0}
}

local PIECE_NAMES = {"I", "O", "T", "S", "Z", "J", "L"}

local cur_time_s = 0
local last_grav_s = 0 -- Last time gravity was applied to the piece
local last_input_s = 0 -- Last time the player pressed a key
local last_rotation_s = 0 -- Last time the player rotated the piece
local grav_speed = 0.3 -- Gravity speed in seconds
local input_speed = 0.06 -- Input poll delay in seconds
local rotation_speed = 0.2 -- Rotation delay in seconds
local key_held = false
local score = 0
local game_over = false
local soft_drop = false
local hard_drop = false
local piece_landed = false
local rotation = 1
local piece_grid = {}
local piece = nil
local piece_queue = {}
local piece_position = {x = 1, y = 1}
local num_combo = 0

local function permute_pieces(game)
	local pieces = game.util.shallow_copy_table(PIECE_NAMES)
	game.util.shuffle(pieces)
	return pieces
end

local function spawn_next_piece(game)
	if #piece_queue == 0 then
		piece_queue = permute_pieces(game)
	end

	piece = table.remove(piece_queue, 1)
	rotation = 1
	piece_position.y = 1

	if piece == "I" or piece == "I" then
		piece_position.x = 3
	else
		piece_position.x = 1
	end
end

local function get_lowest_y_for_rotation(new_rotation)
	local lowest_y = 0

	for i = 1, 4 do
		local y = PIECES_Y[piece][new_rotation][i]

		if y > lowest_y then
			lowest_y = y
		end
	end

	return lowest_y
end

local function get_rightmost_x_for_rotation(new_rotation)
	local rightmost_x = 0

	for i = 1, 4 do
		local x = PIECES_X[piece][new_rotation][i]

		if x > rightmost_x then
			rightmost_x = x
		end
	end

	return rightmost_x
end

local function get_leftmost_x_for_rotation(new_rotation)
	local leftmost_x = 4

	for i = 1, 4 do
		local x = PIECES_X[piece][new_rotation][i]

		if x < leftmost_x then
			leftmost_x = x
		end
	end

	return leftmost_x
end

local function does_next_position_overlap(new_rotation, nx, ny)
	-- Border check
	if get_leftmost_x_for_rotation(new_rotation) + piece_position.x + nx < 0 then
		print("Left border collision")
		return true
	end

	if get_rightmost_x_for_rotation(new_rotation) + piece_position.x + nx > FIELD_WIDTH then
		return true
	end

	if piece_position.y + get_lowest_y_for_rotation(new_rotation) + ny > FIELD_HEIGHT then
		return true
	end

	-- Grid overlap check
	for i = 1, 4 do
		local piece_x = PIECES_X[piece][new_rotation][i] + piece_position.x + nx
		local piece_y = PIECES_Y[piece][new_rotation][i] + piece_position.y + ny

		if piece_grid[piece_y][piece_x] ~= 0 then
			return true
		end
	end

	return false
end

local function add_to_rotation(i)
	local new_rotation = rotation + i

	if new_rotation > 4 then
		new_rotation = 1
	elseif new_rotation < 1 then
		new_rotation = 4
	end

	return new_rotation
end

local function try_rotation()
	if piece == "O" then
		return
	end

	if piece == "I" then
		-- Test each wallkick position for I pieces specifically (they are special)
		for i = 1, 5 do
			if not does_next_position_overlap(add_to_rotation(i), WALLKICKS_I[rotation][i][1], WALLKICKS_I[rotation][i][2]) then
				piece_position.x = piece_position.x + WALLKICKS_I[rotation][i][1]
				piece_position.y = piece_position.y + WALLKICKS_I[rotation][i][2]
				rotation = add_to_rotation(i)
				return
			end
		end
	else
		-- Test each wallkick position for all other pieces
		for i = 1, 5 do
			if not does_next_position_overlap(add_to_rotation(i), WALLKICKS[rotation][i][1], WALLKICKS[rotation][i][2]) then
				piece_position.x = piece_position.x + WALLKICKS[rotation][i][1]
				piece_position.y = piece_position.y + WALLKICKS[rotation][i][2]
				rotation = add_to_rotation(i)
				return
			end
		end
	end
end

local function advance_piece_or_collide()
	if does_next_position_overlap(rotation, 0, 1) then
		-- Collide
		for i = 1, 4 do
			local piece_x = PIECES_X[piece][rotation][i] + piece_position.x
			local piece_y = PIECES_Y[piece][rotation][i] + piece_position.y

			piece_grid[piece_y][piece_x] = piece
		end

		piece_landed = true
	else
		-- Advance
		piece_position.y = piece_position.y + 1

		if soft_drop or hard_drop then
			score = score + 1
		end
	end
end

local function check_rows()
	local total = 0
	local bonus = 0
	local y = FIELD_HEIGHT

	while y > 0 do
		local full = true

		for x = 1, FIELD_WIDTH do
			if piece_grid[y][x] == 0 then
				full = false
				break
			end
		end

		if full then
			total = total + 100
			bonus = bonus + 1

			table.remove(piece_grid, y)
			table.insert(piece_grid, 1, {})

			for x = 1, FIELD_WIDTH do
				table.insert(piece_grid[1], 1, 0)
			end
		else
			-- Makes sure we don't skip a row
			y = y - 1
		end
	end

	if bonus > 1 then
		total = total + (bonus - 1) * 10
	end
	-- Combo logic will come later
	--[[
	if total > 0 then
		num_combo = num_combo + 1
		total = total * num_combo
	else
		num_combo = 0
	end
	]]

	score = score + total
end

local function handle_input()
	local new_key_held = false

	if love.keyboard.isDown("left") then
		if not does_next_position_overlap(rotation, -1, 0) then
			piece_position.x = piece_position.x - 1
		end

		new_key_held = true
	end

	if love.keyboard.isDown("right") then
		if not does_next_position_overlap(rotation, 1, 0) then
			piece_position.x = piece_position.x + 1
		end

		new_key_held = true
	end

	if love.keyboard.isDown("down") then
		if not soft_drop then
			grav_speed = 0.03
			soft_drop = true
		end

		new_key_held = true
	elseif soft_drop then
		grav_speed = 0.3
		soft_drop = false
	end

	if love.keyboard.isDown("up") then
		if cur_time_s - last_rotation_s > rotation_speed then
			try_rotation()
			last_rotation_s = cur_time_s
		end

		new_key_held = true
	end

	if love.keyboard.isDown("space") then
		-- Don't allow hard drop if we hard dropped the last piece
		if not hard_drop then
			hard_drop = true
			while not piece_landed do
				advance_piece_or_collide()
			end
		end
	else
		hard_drop = false
	end

	key_held = new_key_held
end

local function update(dt, game)
	if not game_over then
		cur_time_s = cur_time_s + dt

		if score >= 1000 then
			game_over = true
			game:next_game()
			return
		end

		if not key_held or cur_time_s - last_input_s >= input_speed then
			handle_input()
			last_input_s = cur_time_s
		end

		if cur_time_s - last_grav_s >= grav_speed then
			last_grav_s = cur_time_s

			if not piece_landed then
				advance_piece_or_collide()
			else
				check_rows()
				spawn_next_piece(game)

				if does_next_position_overlap(rotation, 0, 0) then
					game_over = true
				else
					piece_landed = false
				end
			end
		end
	end
end

local function draw(game)
	if game_over then
		return
	end

	PIXEL_SIZE = game.settings.PIXEL_SIZE

	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth() / 2 - FIELD_WIDTH * PIXEL_SIZE / 2, love.graphics.getHeight() / 2 - FIELD_HEIGHT * PIXEL_SIZE / 2)

	-- Draw border around play field
	love.graphics.rectangle("line", 0, 0, FIELD_WIDTH * PIXEL_SIZE, FIELD_HEIGHT * PIXEL_SIZE)

	love.graphics.scale(PIXEL_SIZE, PIXEL_SIZE)

	-- Draw grid
	for y = 1, FIELD_HEIGHT do
		for x = 1, FIELD_WIDTH do
			if piece_grid[y][x] ~= 0 then
				love.graphics.setColor(1, 1, 1)
				love.graphics.rectangle("fill", x - 1, y - 1, 1, 1)
			end
		end
	end
	love.graphics.setColor(1, 1, 1)

	-- Draw current piece
	if not piece_landed then
		for i = 1, 4 do
			local piece_x = PIECES_X[piece][rotation][i] + piece_position.x
			local piece_y = PIECES_Y[piece][rotation][i] + piece_position.y

			love.graphics.rectangle("fill", piece_x - 1, piece_y - 1, 1, 1)
		end
	end

	love.graphics.pop()
	local score_text = "Score: " .. score
	love.graphics.print(score_text, love.graphics.getWidth() / 2 - love.graphics.getFont():getWidth(score_text) / 2, 10);
end

local function start(game)
	-- Initialize the piece grid
	for y = 1, FIELD_HEIGHT do
		piece_grid[y] = {}
		for x = 1, FIELD_WIDTH do
			piece_grid[y][x] = 0
		end
	end

	spawn_next_piece(game)
	spawn_next_piece(game)
end

return {
	update = update,
	draw = draw,
	start = start
}
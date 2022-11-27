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

return {
	point_in_rect = point_in_rect,
	center_h = center_h,
	center_v = center_v,
	shuffle = shuffle,
	shallow_copy_table = shallow_copy_table,
	swap_xy_inplace = swap_xy_inplace
}
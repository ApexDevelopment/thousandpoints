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

return {
	point_in_rect = point_in_rect,
	center_h = center_h,
	center_v = center_v
}
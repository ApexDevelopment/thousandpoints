function point_in_rect(px, py, rx, ry, rw, rh)
	return px > rx and py > ry and px < rx + rw and py < ry + rh
end

function center_h(drawable, screen_w)
	return screen_w / 2 - drawable:getWidth() / 2
end

function center_v(drawable, screen_h)
	return screen_h / 2 - drawable:getHeight() / 2
end

return {
	point_in_rect = point_in_rect,
	center_h = center_h,
	center_v = center_v
}
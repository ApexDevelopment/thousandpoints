function point_in_rect(px, py, rx, ry, rw, rh)
	return px > rx and py > ry and px < rx + rw and py < ry + rh
end

return {
	point_in_rect = point_in_rect
}
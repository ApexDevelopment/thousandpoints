function update(dt, game)
	if love.mouse.isDown(1) and game.util.point_in_rect(love.mouse.getX(), love.mouse.getY(), 100, 100, 100, 50) then
		print("Clicked")
	end
end

function draw()
	love.graphics.print("This is the main menu!", 10, 10)
	love.graphics.rectangle("line", 100, 100, 100, 50)
	love.graphics.print("Play", 110, 110)
end

return { update = update, draw = draw }

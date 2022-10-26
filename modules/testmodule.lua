function start()
	print("Test module started.")
end

function stop()
	print("Test module stopped.")
end

function update(dt, game)
	if love.keyboard.isDown("b") then
		game:switch_module("mainmenu")
	end
end

function draw(game)
	love.graphics.print("This is a test module. Press 'b' to go back to the main menu.", 50, 50)
end

return { start = start, stop = stop, update = update, draw = draw }

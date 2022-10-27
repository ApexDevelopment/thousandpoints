function start()
	print("Test module started.")
end

function stop()
	print("Test module stopped.")
end

function update(dt, game)
end

function draw(game)
	love.graphics.print("This is a test module. Press 'b' to go back to the main menu.", 10, 50)
end

function keypressed(key, game)
	if key == "b" then
		game:switch_module("mainmenu")
	end
end

return { start = start, stop = stop, update = update, draw = draw, keypressed = keypressed }

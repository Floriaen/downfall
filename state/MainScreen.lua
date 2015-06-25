local MainScreen = State:extend('MainScreen')

function MainScreen:new()
	MainScreen.super.new(self)
end

function MainScreen:start()
	print('MainScreen:start')
	G.input:bind(' ', 'START')
end

function MainScreen:stop()

end

function MainScreen:update(dt)
	if G.input:pressed('START') then
		Stateswitch(Game)
	end
end

function MainScreen:draw()
	love.graphics.setFont(Font.pressStart42)
	love.graphics.printf('Downfall', 0, love.graphics.getHeight() / 2 - 100, love.graphics.getWidth(), "center")
	love.graphics.setFont(Font.pressStart26)
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf('Press space\n to start', 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

return MainScreen
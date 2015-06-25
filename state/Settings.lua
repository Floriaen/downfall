local Settings = State:extend('Settings')

function Settings:new()
	Settings.super.new(self)
end

function Settings:start()
	print('Settings:start')
	G.input:bind('escape', 'CLOSE')
end

function Settings:stop()

end

function Settings:update(dt)
	if G.input:pressed('CLOSE') then
		Stateswitch(MainScreen)
	end
end

function Settings:draw()
	love.graphics.setFont(Font.pressStart26)
	love.graphics.printf('Settings', 0, 100, love.graphics.getWidth(), "center")
	--[[
	love.graphics.setFont(Font.pressStart26)
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf('Fullscreen Y/N', 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
	]]
end

return Settings
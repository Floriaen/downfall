local Home = Class:extend()

function Home:new(x, y)
	Home.super.new(self, x, y)
	self.background = love.graphics.newCanvas()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setCanvas(self.background)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', 0, 0, love.window.getWidth(), love.window.getHeight())
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(GAME_FONT)
	love.graphics.print('R', love.window.halfWidth, love.window.halfHeight - 60)

	love.graphics.setColor(r, g, b, a)
	love.graphics.setCanvas()
end

function Home:update(dt)
	if love.keyboard.isDown('r') then
		self.activate = false
		G.world = World()
	end
end

function Home:draw()
	love.graphics.draw(self.background)
end

return Home
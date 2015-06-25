local Teleport = Item:extend('Teleport')

function Teleport:new(x, y)
	Teleport.super.new(self, x, y)
	self.gain = 10
end

function Teleport:hitBy(e)
	Teleport.super.hitBy(self, e)
	e:teleport()
end

function Teleport:draw()
	love.graphics.setColor(255, 100, 0)
	love.graphics.draw(Assets.gfx.teleport, self.x, self.y, self.angle, 1, 1, 10, 10)
end

return Teleport
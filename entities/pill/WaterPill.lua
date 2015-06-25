local WaterPill = Item:extend('WaterPill')

function WaterPill:new(x, y)
	Teleport.super.new(self, x, y)
	self.gain = 0
end

function WaterPill:hitBy(e)
	Teleport.super.hitBy(self, e)
	self.world.arena:immerge(10)
end

function WaterPill:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(Assets.gfx.water, self.x, self.y, self.angle, 1, 1, 10, 10)
end

return WaterPill


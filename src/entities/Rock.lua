local Rock = Entity:extend('Rock')

function Rock:new(x, y)
	Rock.super.new(self, x, y)
	self.zIncrement = 0
	self.z = 1
	self.hitboxRadius = 40
end

function Rock:update(dt)
	Rock.super.update(self, dt)
end

function Rock:draw()
	love.graphics.draw(Assets.gfx.rock, self.x, self.y, 0, 2, 2, Assets.gfx.rock:getWidth() / 2, Assets.gfx.rock:getHeight() / 2 + 20)
	Rock.super.draw(self)
end

return Rock
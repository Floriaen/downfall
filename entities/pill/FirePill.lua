local FirePill = Item:extend('FirePill')

function FirePill:new(x, y)
	FirePill.super.new(self, x, y)
	self.gain = 0
end

function FirePill:hitBy(e)
	FirePill.super.hitBy(self, e)
	e.bullet = Fireball
end

function FirePill:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(Assets.gfx.fireball, self.x, self.y, self.angle, 1, 1, 10, 10)
end

return FirePill
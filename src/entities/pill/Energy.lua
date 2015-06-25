local AnimatedSprite = require 'entities/component/AnimatedSprite'
local Energy = Item:extend('Energy')
Energy:implement(AnimatedSprite)

function Energy:new(x, y)
	Energy.super.new(self, x, y)

	self:animatedSpriteNew(Assets.gfx.pill, 20, 10)
	self:addAnimation('charging', {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}}, self.lifeDuration / 6, false)
	self:playAnimation('charging')
end

function Energy:update(dt)
	Energy.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
	self.gain = #self:getCurrentAnimation().frames - self:getCurrentAnimation().currentFrame + 1
end

function Energy:draw()
	gaussian.drawFunc(function()
			love.graphics.setColor(255, 255, 255)
			self:animatedSpriteDraw(self.x, self.y, self.angle, 1, 1, 10, 5)
		end)
	self:animatedSpriteDraw(self.x, self.y, self.angle, 1, 1, 10, 5)
	Energy.super.draw(self)
end

return Energy
local AnimatedSprite = require 'entities/component/AnimatedSprite'
local Shark = Entity:extend('Shark')
Shark:implement(AnimatedSprite)

function Shark:new(x, y)
	Shark.super.new(self, x, y)
	self:animatedSpriteNew(Assets.gfx.shark, 156, 64)
	self:addAnimation('swimming', {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, {8, 1}}, 0.2, true)
	self:playAnimation('swimming')
	self.zIncrement = 0
	self.z = 1
	self.scale = 2
end

function Shark:update(dt)
	Shark.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
end

function Shark:draw()
	Shark.super.draw(self)
	self.scale = 2
	self:animatedSpriteDraw(self.x, self.y, 0, self.scale, self.scale + 1, 78, 32)
end

return Shark


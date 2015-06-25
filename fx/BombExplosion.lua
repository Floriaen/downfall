local AnimatedSprite = require'entities/component/AnimatedSprite'
local BombExplosion = Entity:extend('BombExplosion')
BombExplosion:implement(AnimatedSprite)

function BombExplosion:new(x, y)
	BombExplosion.super.new(self, x, y)
	self.hitboxRadius = 40
	--	self.hasShadow = false
	self.toRadius = 40

	self:animatedSpriteNew(Assets.gfx.bombExplosion, 64, 64)
	self:addAnimation('explode', { { 1, 1 }, { 2, 1 } }, 0.4, false)
	self:playAnimation('explode')

end

function BombExplosion:update(dt)
	BombExplosion.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
end

function BombExplosion:draw()
	love.graphics.setColor(255, 255, 255)
	self:animatedSpriteDraw(self.x, self.y, 0, 2, 2, 32, 32)
	BombExplosion.super.draw(self)
end

return BombExplosion
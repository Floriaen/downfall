local AnimatedSprite = require('entities/component/AnimatedSprite')
local Grass = Entity:extend('Grass')
Grass:implement(AnimatedSprite)

function Grass:new(x, y)
	Grass.super.new(self, x, y)
	self._x = x
	self._y = y
	print('GRASS', self._x, self._y)
	self.hitboxRadius = 1
	self.z = 1.01
	self.zIncrement = 0
	self.flipX = math.random() > 0.5 and 1 or -1
	self.hasShadow = false

	self:animatedSpriteNew(Assets.gfx.grass, 48, 48)
	--[[
	self:addAnimation('growing', { { 1, 1 }, { 2, 1 }, { 3, 1 }, { 4, 1 } }, 9 + math.random() * 3, false)
	self:addAnimation('moving', { { 4, 1 }, { 5, 1 } }, 0.2, true) -- , {6, 1}
	self:addAnimation('wind', { { 7, 1 }, { 8, 1 } }, 0.2, true)
	]] --

	self:addAnimation('growing', { { 1, 1 }, { 2, 1 }, { 2, 1 } }, 9 + math.random() * 3, false)
	self:addAnimation('moving', { { 2, 1 }, { 2, 1 } }, 0.2, true) -- , {6, 1}
	self:addAnimation('wind', { { 2, 1 }, { 2, 1 } }, 0.2, true)

	self.timer = Timer()
	self.growed = false
	self.decay = 2
	--self.debug = true
	self.angle = 0
	self.alpha = 255
end

function Grass:onAnimationComplete(animationName)
	if animationName == 'growing' then
		self:playAnimation('moving')

		local animation = self:getCurrentAnimation()
		animation.currentFrame = math.random(#animation.frames)
		self.growed = true
	end
end

function Grass:added()
	Grass.super.added(self)
	self.timer:after(self.decay, function()
		self:playAnimation('growing')
	end)
end

function Grass:update(dt)
	Grass.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
	self.timer:update(dt)

	local arena = self.world.arena
	-- handle the ground rotation
	local gx = arena.x - arena.groundCanvas:getWidth() / 2
	local gy = arena.y - arena.groundCanvas:getHeight() / 2
	self.x = self._x - gx
	self.y = self._y - gy

	self.color[4] = self.alpha
end

function Grass:draw()
	local arena = self.world.arena
	local gx = arena.x - arena.groundCanvas:getWidth() / 2
	local gy = arena.y - arena.groundCanvas:getHeight() / 2

	love.graphics.push()
	love.graphics.translate(gx, gy)
	love.graphics.translate(arena.groundCanvas:getWidth() / 2, arena.groundCanvas:getHeight() / 2)
	love.graphics.rotate(arena.groundAngle)
	love.graphics.translate(-arena.groundCanvas:getWidth() / 2, -arena.groundCanvas:getHeight() / 2)

	love.graphics.setColor(self.color)
	self:animatedSpriteDraw(self.x, self.y, -arena.groundAngle, self.flipX * 2, 2, 24, 24)
	Grass.super.draw(self)

	love.graphics.pop()
end

return Grass
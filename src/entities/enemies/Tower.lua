local AnimatedSprite = require 'entities/component/AnimatedSprite'
local Colorable = require('entities/component/Colorable')
local Tower = Entity:extend('Tower')
Tower:implement(AnimatedSprite)
Tower:implement(Colorable)

Tower.vector = Vector()

function Tower:new(x, y)
	Tower.super.new(self, x, y)
	self.hitboxRadius = 30
	self.timer = Timer()
	self:colorableNew()
	self.hasShadow = false

	self.delay = 0
	self.life = 100

	self.zIncrement = 0
	self.z = 1.2

	self:animatedSpriteNew(Assets.gfx.tower, 30, 32)
	self:addAnimation('opening', { { 1, 1 }, { 2, 1 }, { 3, 1 } }, 0.14, false)
	self:addAnimation('closing', { { 3, 1 }, { 2, 1 }, { 1, 1 } }, 0.14, false)
	self:addAnimation('rotating', { { 3, 1 }, { 4, 1 }, { 5, 1 }, { 6, 1 }, { 7, 1 }, { 8, 1 }, { 9, 1 }, { 10, 1 }, { 3, 1 } }, 0.3, false)

	self.damage = 6
	self.hitBack = 60

	--self.decay = 0
	table.insert(self.collidables, 'UFO')
	table.insert(self.collidables, 'Bullet')
	self.shakes = true

	self.gunDirection = Vector(0, 1)
--	self.debug = true
	self.maskEffect = love.graphics.newShader(Shader.maskEffect)
end

function Tower:onAnimationComplete(animationName)
	if animationName == 'closing' then
		self.hitboxRadius = 0

		self.timer:after(2 * 0.8, function()
			self.hitboxRadius = 20
			self:playAnimation('opening')
		end)

	elseif animationName == 'opening' then
		self:playAnimation('rotating')
		self:fire(self.gunDirection)
		self.timer:every('fire', 0.12, function()
			self:fire(self.gunDirection)
		end)
	elseif animationName == 'rotating' then
		self.timer:cancel('fire')
		self:playAnimation('closing')
	end


end

function Tower:fire(direction)
	local angle = direction:angleTo()
	local bullet = self.world:createEntity(Ball,
		self.x + math.cos(angle) * 20,
		self.y + math.sin(angle) * 20)
	bullet.color = {0, 0, 0}
	table.insert(bullet.collidables, 'UFO')
	table.insert(bullet.collidables, 'Plane')
	table.insert(bullet.collidables, 'Kamikaze')
	table.insert(bullet.collidables, 'AngelFace')
	table.insert(bullet.collidables, 'Snake')
	table.insert(bullet.collidables, 'Mine')

	bullet.velocity.x = direction.x * 500
	bullet.velocity.y = direction.y * 500
end

function Tower:added()
	Tower.super.added(self)
	self.timer:after(self.delay * 0.8, function()
		self:playAnimation('opening')
	end)
end

function Tower:hitBy(e)
	if e:is(Bullet) then
		self:setTint({1, 0, 0, 0.6}, 0.6)
	end
	Tower.super.hitBy(self, e)
end

function Tower:update(dt)
	Tower.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
	self:colorableUpdate(dt)
	self.timer:update(dt)

	local currentAnimation = self:getCurrentAnimation()
	if currentAnimation.name == 'rotating' then
		local frame = currentAnimation.currentFrame
		--print('frame', frame)
		--[[
		--7 : 0.5
		--8 :  1 / 4 * math.pi -- 0.25
		--9 : 2 * math.pi --- 0
		--10 : 7 / 4 * math.pi --- 1.75
		 ]]

		local angle = 1.5
		if frame == 8 then
			angle = 1.75
		else
			angle = (7 - frame) * 0.25
		end

		--print('angle', currentAnimation.currentFrame, angle)
		angle = math.pi * 2 - angle * math.pi

		local c, s = math.cos(angle), math.sin(angle)
		self.gunDirection.x = math.lerp(self.gunDirection.x, c, dt * 6)
		self.gunDirection.y = math.lerp(self.gunDirection.y, s, dt * 6)
	end

end

function Tower:draw()
	love.graphics.setColor(255, 255, 255)
	self:animatedSpriteDraw(self.x, self.y, 0, 2, 2, 15, 16)

	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		self:animatedSpriteDraw(self.x, self.y, 0, 2, 2, 15, 16)
		love.graphics.setShader()
	end

	Tower.super.draw(self)
end

return Tower
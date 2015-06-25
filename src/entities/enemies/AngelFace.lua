local AnimatedSprite = require('entities/component/AnimatedSprite')
local Colorable = require('entities/component/Colorable')
local LifeIndicator = require('entities/component/LifeIndicator')
local AngelFace = Entity:extend('AngelFace')
AngelFace:implement(Colorable)
AngelFace:implement(AnimatedSprite)
AngelFace:implement(LifeIndicator)

AngelFace.vector = Vector(0, 0)
AngelFace.maxLife = 160
AngelFace.fireDelay = 0.4

function AngelFace:new(x, y)
	AngelFace.super.new(self, x, y)
	self:lifeIndicatorNew(AngelFace.maxLife, 92, 3)

	self.hitboxRadius = 78
	self.timer = Timer()

	self.target = State.current.player
	self.angleStep = 2
	self.speed = 0.3
	self:colorableNew()

	self.z = 20
	self.zIncrement = 0

	self.life = AngelFace.maxLife
	self.decay = 3 * math.pi / 2

	self:animatedSpriteNew(Assets.gfx.face, 64, 65)

	self:addAnimation('toBlowing', { { 3, 1 }, { 2, 1 }, { 1, 1 } }, 0.3, false)
	self:addAnimation('toSmilling', { { 1, 1 }, { 2, 1 }, { 3, 1 } }, 0.3, false)
	self:playAnimation('toBlowing')
	self:getCurrentAnimation():stop()

	self.maskEffect = love.graphics.newShader(Shader.maskEffect)

	self.state = 'smiling' -- 'blowing'

	self.damage = 10
	table.insert(self.collidables, 'UFO')

	self.faceAngle = 0
	self.showLifeStatus = 0

	self.fireAngle = 0
	self.fireDelay = 0.4
end

function AngelFace:onAnimationComplete(animationName)
	if animationName == 'toBlowing' then

		self.state = 'blowing'

		self.world.arena.wind.x = math.cos(self.faceAngle + math.pi / 2)
		self.world.arena.wind.y = math.sin(self.faceAngle + math.pi / 2)
		self.world.arena.wind:normalize_inplace()
		self.world.arena.wind = self.world.arena.wind * 16

		self.fireAngle = 0
		self.timer:tween(3, self, { fireAngle = math.pi }, 'linear', function()
			-- reset:
			self.fireAngle = 0
			self.fireDelay = 0.4

			self.world.arena.wind.x = 0
			self.world.arena.wind.y = 0
			self:playAnimation('toSmilling')
		end)

	else
		self.state = 'smiling'
	end
end

function AngelFace:hitBy(e)

	if not e:is(Plane) then
		self:setTint({ 1, 0, 0, 0.6 }, 0.6)
		self.showLifeIndicator = 3
		AngelFace.super.hitBy(self, e)
		if self.state == 'smiling' then
			self:playAnimation('toBlowing', false)
		end
	end


	if e:is(UFO) then
		local ratio = 60
		local ang = math.atan2(self.y - e.y, self.x - e.x)
		e.velocity.x = e.velocity.x - math.cos(ang) * ratio
		e.velocity.y = e.velocity.y - math.sin(ang) * ratio
	end
end

function AngelFace:update(dt)
	AngelFace.super.update(self, dt)
	self.timer:update(dt)
	self:colorableUpdate(dt)
	self:animatedSpriteUpdate(dt)
	self:lifeIndicatorUpdate(dt)

	self.faceAngle = self.world.arena.angle + (self.decay - math.pi * 1.5)

	local radius = Arena.radius * 0.5
	local position = Vector(self.x, self.y)
	local center = Vector(self.world.arena.x, self.world.arena.y)
	local offset = position - center
	local distance = offset:len()

	if (radius < distance) then
		local direction = offset / distance
		position = center + direction * radius

		self.x = position.x
		self.y = position.y
	end

	self.x = self.world.arena.x + math.cos(self.world.arena.angle + self.decay) * Arena.radius * 0.5
	self.y = self.world.arena.y + math.sin(self.world.arena.angle + self.decay) * Arena.radius * 0.5 - 52

	if self.fireAngle > 0 then
		self.fireDelay = self.fireDelay - dt
		if self.fireDelay < 0 then
			-- the less there is life the more the fire accurency is high
			self.fireDelay = AngelFace.fireDelay + (self.life / AngelFace.maxLife) * 0.4

			AngelFace.vector.x = math.cos(self.fireAngle)
			AngelFace.vector.y = math.sin(self.fireAngle)
			self:fire(AngelFace.vector)
		end
	end
end

function AngelFace:fire(direction)
	local bullet = self.world:createEntity(Bullet,
		self.x,
		self.y + 60)
	table.insert(bullet.collidables, 'UFO')
	bullet.hitboxRadius = 20
	bullet.hasShadow = true
	bullet.color = { 225, 210, 0 }
	bullet.z = 30
	bullet.damage = 10

	bullet.velocity.x = direction.x * 400
	bullet.velocity.y = direction.y * 400
end

function AngelFace:onEvent(event)
	--[[
	if event == 'END_LOOP' then
		self.blowing = false
	elseif event == 'BEGIN_LOOP' then
		self.blowing = true
		--self:playAnimation('burning')
	end
	]] --
end

function AngelFace:removed()
	AngelFace.super.removed(self)
	self.world.arena.wind.x = 0
	self.world.arena.wind.y = 0
end

function AngelFace:draw()
	love.graphics.setColor(255, 255, 255)

	self:animatedSpriteDraw(self.x, self.y, self.faceAngle, 2.4, 2.2, 32, 32)
	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		self:animatedSpriteDraw(self.x, self.y, self.faceAngle, 2.4, 2.2, 32, 32)
		love.graphics.setShader()
	end
	self:lifeIndicatorDraw()

	AngelFace.super.draw(self)
end

return AngelFace
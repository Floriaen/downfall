local Colorable = require('entities/component/Colorable')
local Lazer = Entity:extend('Lazer')
Lazer:implement(Colorable)

Lazer.spawnPause = 2
Lazer.maxMovementCount = 12

-- State
Lazer.RUNNING = 0
Lazer.OUT_OF_ORDER = 1

function Lazer:new(x, y)
	Lazer.super.new(self, x, y)
	self:colorableNew()
	self.timer = Timer()

	self.pixel = love.graphics.newCanvas(Arena.radius + 8, 2)
	love.graphics.setCanvas(self.pixel)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle('fill', 0, 0, self.pixel:getWidth(), self.pixel:getHeight())
	love.graphics.setCanvas()

	self.lazerDirection = Vector(0, 0)
	self.lazerAngle = 0
	self.showLazer = true

	self.doSpawn = true
	self.movementCount = 0
	self.hasShadow = false
	self.tint = false

	self.state = Lazer.RUNNING

	self.angle = math.pi / math.random(1, 4)

	self.scale = 1.5

	self.lazerScale = 0
	self.lazerSourceRadius = 0
	self.lazerSourceAlpha = 10
	self.visible = false
	self.life = 10
	self.z = 1.1
	self.maskEffect = love.graphics.newShader(Shader.maskEffect)
	self.damage = 10 -- hight damage!
	self.baseScale = self.scale

	-- scaling movement
	self.timer:every(0.8, function()
		self.timer:tween(0.4, self, { baseScale = self.baseScale + 0.6 }, 'linear', function()
			self.timer:tween(0.4, self, { baseScale = self.baseScale - 0.6 }, 'linear')
		end)
	end)

	self.gunSmoke = love.graphics.newParticleSystem(Assets.gfx.cruz, 100)
	self.gunSmoke:setParticleLifetime(1)
	self.gunSmoke:setEmitterLifetime(1.6)
	self.gunSmoke:setRadialAcceleration(1, 10)
	self.gunSmoke:setRelativeRotation(true)
	self.gunSmoke:setEmissionRate(14)
	self.gunSmoke:setSizes(0.8, 3.8)
	self.gunSmoke:setColors(255, 255, 255, 240, 150, 150, 150, 180, 60, 60, 60, 100)
	self.gunSmoke:setLinearAcceleration(60, 60, 200, 200)
	self.gunSmoke:stop()
end

function Lazer:hitBy(e)

	--[[
		if not self.tint then
			self:setTint({1, 0, 0, 1}, 0.6)
		end
		Lazer.super.hitBy(self, e)
	]] --


	--[[
		if self.life == 0 then
			self.life = 10
			self.state = Lazer.OUT_OF_ORDER
			self.tint = true
			self.color = {0, 0, 0, 0.6}
			self.timer:after(1, function()
					self.state = Lazer.RUNNING
				end)
		end
		]] --
end

function Lazer:added()
	Lazer.super.added(self)
	self.baseScale = self.scale
end

function Lazer:update(dt)
	Lazer.super.update(self, dt)
	self.timer:update(dt)
	self:colorableUpdate(dt)

	self.gunSmoke:update(dt)


	if self.state == Lazer.OUT_OF_ORDER then
		self.showLazer = false
	end

	if self.showLazer == true then
		self.showLazer = false
		local toAngle = self.angle + math.rsign() * math.pi / 4
		self.timer:tween(Lazer.spawnPause, self, { angle = toAngle }, 'linear',
			function()
				self.visible = true
				self.timer:tween(0.4, self, { lazerSourceRadius = 40, lazerSourceAlpha = 40 }, 'linear',
					function()
						self.gunSmoke:start()
						self.timer:tween(1.2, self, { lazerScale = 4, lazerSourceRadius = 2, lazerSourceAlpha = 10 }, 'out-bounce', function()
							self.showLazer = true
							self.visible = false
							self.lazerScale = 0
							self.lazerSourceRadius = 0
							self.movementCount = self.movementCount + 1
							if self.movementCount > Lazer.maxMovementCount then
								self.movementCount = 0
								self.world:levelUp()
							end
						end)
					end)
			end)
	end

	self.x = self.world.arena.x + math.cos(self.world.arena.angle + self.angle + math.pi / 2) * Arena.radius * 0.5
	self.y = self.world.arena.y + math.sin(self.world.arena.angle + self.angle + math.pi / 2) * Arena.radius * 0.5

	local toX = self.world.arena.x + math.cos(self.world.arena.angle + self.angle + math.pi / 2) * Arena.radius * 0.5 * -1
	local toY = self.world.arena.y + math.sin(self.world.arena.angle + self.angle + math.pi / 2) * Arena.radius * 0.5 * -1
	self.gunSmoke:setPosition(toX, toY)


	self.lazerDirection.x = love.window.halfWidth - self.x
	self.lazerDirection.y = love.window.halfHeight - self.y
	self.lazerAngle = self.lazerDirection:angleTo()

	-- hit UFO
	if self.visible then
		local distance = Vector(self.world.player.x - self.x, self.world.player.y - self.y)
		local dist = distance:cross(self.lazerDirection)

		if math.abs(dist) <= self.world.player.hitboxRadius * 80 then
			self.world.player:hitBy(self)
		end
	end
end

function Lazer:draw()
	--	local shader = love.graphics.getShader()
	-- base
	local angle = self.angle - math.pi * 1.5 + math.pi / 2
	love.graphics.draw(Assets.gfx.lazer, self.x, self.y, self.world.arena.angle + angle, self.baseScale, 1 / self.baseScale + 0.4, Assets.gfx.lazer:getWidth() / 2, Assets.gfx.lazer:getHeight() / 2 + 10)

	if self.colorableDuration > 0 or self.tint then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.lazer, self.x, self.y, self.world.arena.angle + angle, self.baseScale, 1 / self.baseScale + 0.4, Assets.gfx.lazer:getWidth() / 2, Assets.gfx.lazer:getHeight() / 2 + 10)
		love.graphics.setShader()
	end

	if self.visible then

		-- lazer
		love.graphics.setColor(255, 255, 255)
		if self.lazerScale > 0 then
			love.graphics.draw(self.pixel,
				self.x,
				self.y,
				self.lazerAngle,
				1,
				self.lazerScale,
				2 * self.scale,
				self.pixel:getHeight() / 2)
		end

		-- halo
		if self.lazerSourceRadius > 0 then
			love.graphics.setColor(255, 255, 255, self.lazerSourceAlpha)
			love.graphics.circle('fill', self.x, self.y, self.lazerSourceRadius * self.scale)
		end
	end
	love.graphics.draw(self.gunSmoke)
	Lazer.super.draw(self)
	--	love.graphics.setShader(shader)
end

return Lazer
local Colorable = require('entities/component/Colorable')
local UFO = Entity:extend('UFO')
UFO:implement(Colorable)

UFO.fireDelay = 0.1
UFO.boundRadius = 100
UFO.maxLife = 100
UFO.vector = Vector()

UFO.around = {
	{ -1, -1 }, { 0, -1 }, { 1, -1 },
	{ -1, 0 }, { 1, 0 },
	{ -1, 1 }, { 0, 1 }, { 1, 1 }
}

UFO.around2 = {
	{ -2, -2 }, { 1, -2 }, { 2, -2 },
	{ -2, 1 }, { 2, 1 },
	{ -2, 2 }, { 1, 2 }, { 2, 2 }
}

function UFO:new(x, y)
	UFO.super.new(self, x, y)

	self:colorableNew()

	self.origin.x = x
	self.origin.y = y

	self.hitboxRadius = 20

	local size = 20
	self.pixel = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas(self.pixel)
	love.graphics.rectangle('fill', 0, 0, size, size)
	love.graphics.setCanvas()

	self.fireDelay = 0

	self.toOriginVector = Vector(0, 0)

	self.life = 100
	self.damage = 2

	self.friction.x = 0.89
	self.friction.y = 0.89

	self.inBounds = false
	self.active = true
	self.speed = 1500

	self.mask = love.graphics.newCanvas(Assets.gfx.ship:getWidth(), Assets.gfx.ship:getHeight())

	self.maskEffect = love.graphics.newShader(Shader.maskEffect)
	love.graphics.setCanvas(self.mask)
	self.maskEffect:send('colorFill', { 1, 1, 1, 1 })
	love.graphics.setShader(self.maskEffect)
	love.graphics.draw(Assets.gfx.ship, 0, 0)
	love.graphics.setShader()
	love.graphics.setCanvas()

	table.insert(self.collidables, 'Plane')
	table.insert(self.collidables, 'Kamikaze')

	self.deformation = { x = 1, y = 1 }

	self.halo = nil
	self.force = 74
	self.timer = Timer()

	self.gun = Vector()
	self.z = 10
	self.zDistance = 30
	self.state = 'MOVE' -- TELEPORT
	self.teleportTarget = nil

	self.lazerSfx = love.audio.newSource(Assets.sfx.lazer, "static")
	self.lazerSfx:setVolume(0.5)

	self.bullet = Bullet
	self.lastBulletFired = nil

	--bubbles:
	self.particles = love.graphics.newParticleSystem(Assets.gfx.bubble, 100)
	self.particles:setEmitterLifetime(0.4)
	self.particles:setParticleLifetime(0.26)
	self.particles:setEmissionRate(100)
	self.particles:setSizes(0.2, 0.4, 0.8)
	self.particles:setAreaSpread('normal', self.hitboxRadius / 3, self.hitboxRadius / 3)
	self.particles:stop()
	--[[
	self.particles:setColors(255, 255, 255, 255,
		255, 255, 0, 255,
		255, 100, 100, 200,
		255, 0, 0, 100,
		0, 100, 255, 30,
		255, 255, 255, 30)
		]]
	self.particles:setPosition(self.x, self.y)

	self.bulletCount = 0
end

function UFO:added()
	UFO.super.added(self)
end

function UFO:update(dt)
	UFO.super.update(self, dt)
	self:colorableUpdate(dt)
	self.timer:update(dt)

	-- deformation
	self.deformation.x = math.lerp(self.deformation.x, 1, dt * 10)
	self.deformation.y = math.lerp(self.deformation.y, 1, dt * 10)

	if self.deformation.x > 0.9 and self.deformation.x < 1.1 then
		self.deformation.x = 1
	end

	if self.deformation.y > 0.9 and self.deformation.y < 1.1 then
		self.deformation.y = 1
	end

	-- common stuff:
	self.fireDelay = self.fireDelay - dt
	if not self.active then return end
	if self.life == 0 then
		return;
	end

	local canFire = not self.world.arena:immerged()
	local dash = self.world.arena:immerged()

	if self.state == 'MOVE' then
		if dash then
			UFO.vector.x = self.velocity.x
			UFO.vector.y = self.velocity.y
			UFO.vector:normalize_inplace()
			-- bubbles
			self.particles:setPosition(self.x, self.y)
			self.particles:setLinearAcceleration(
				-UFO.vector.x * 2020,
				-UFO.vector.y * 2020
			)
			self.particles:update(dt)

			self.friction.x = 0.8
			self.friction.y = 0.8
			local dashSpeed = 130000

			if G.input:pressed('FIRE_RIGHT') then
				self.velocity.x = self.velocity.x + dashSpeed * dt
				self.particles:start()
			elseif G.input:pressed('FIRE_LEFT') then
				self.velocity.x = self.velocity.x - dashSpeed * dt
				self.particles:start()
			elseif G.input:pressed('FIRE_UP') then
				self.velocity.y = self.velocity.y - dashSpeed * dt
				self.particles:start()
			elseif G.input:pressed('FIRE_DOWN') then
				self.velocity.y = self.velocity.y + dashSpeed * dt
				self.particles:start()
			end

		elseif self.fireDelay <= 0 then
			self.fireDelay = UFO.fireDelay
			local fire = false

			local changeDirectionSpeed = 40
			if G.input:down('FIRE_RIGHT') then
				fire = true
				self.gun.x = math.lerp(self.gun.x, 1, dt * changeDirectionSpeed)
			elseif G.input:down('FIRE_LEFT') then
				fire = true
				self.gun.x = math.lerp(self.gun.x, -1, dt * changeDirectionSpeed)
			else
				self.gun.x = math.lerp(self.gun.x, 0, dt * changeDirectionSpeed)
			end

			if G.input:down('FIRE_UP') then
				fire = true
				self.gun.y = math.lerp(self.gun.y, -1, dt * changeDirectionSpeed)
			elseif G.input:down('FIRE_DOWN') then
				fire = true
				self.gun.y = math.lerp(self.gun.y, 1, dt * changeDirectionSpeed)
			else
				self.gun.y = math.lerp(self.gun.y, 0, dt * changeDirectionSpeed)
			end

			self.gun:normalize_inplace()

			if fire then

				self:fire(self.gun)
				-- recoil
				self.velocity.x = self.velocity.x - self.gun.x * 1000 * dt
				self.velocity.y = self.velocity.y - self.gun.y * 1000 * dt

				self.friction.x = 0.89
				self.friction.y = 0.89
			end
		end
	end

	-- movement
	if self.state == 'MOVE' then

		if G.input:down('GO_RIGHT') then
			self.velocity.x = self.velocity.x + self.speed * dt
		elseif G.input:down('GO_LEFT') then
			self.velocity.x = self.velocity.x - self.speed * dt
		end

		if G.input:down('GO_UP') then
			self.velocity.y = self.velocity.y - self.speed * dt
		elseif G.input:down('GO_DOWN') then
			self.velocity.y = self.velocity.y + self.speed * dt
		end

		--[[
			self.jumpDown = self.jumpDown - dt
			if self.jumpDown < 0 then
				self.jumpDown = 0
			end
			]] --

		--[[
				-- jumping
				if G.input:down('SPECIAL') then

				end

				if self.jumpDown == 0 then
					if self.jumping then
						self.z = self.z - dt
						if self.z < 1.1 then
							self.z = 1.1
						end
					end
				end
		]]
	elseif self.state == 'TELEPORT' then
		self.teleportTarget.scale = self.scale * 0.8
		--[[
				if G.input:down('GO_RIGHT') then
					--self.teleportTarget.velocity.x = self.teleportTarget.velocity.x + (self.speed / Game.speedRatio) * 16 * dt
				elseif G.input:down('GO_LEFT') then
					--self.teleportTarget.velocity.x = self.teleportTarget.velocity.x - (self.speed / Game.speedRatio) * 16 * dt
				end

				if G.input:down('GO_UP') then
					--self.teleportTarget.velocity.y = self.teleportTarget.velocity.y - (self.speed / Game.speedRatio) * 16 * dt
				elseif G.input:down('GO_DOWN') then
					--self.teleportTarget.velocity.y = self.teleportTarget.velocity.y + (self.speed / Game.speedRatio) * 16 * dt
				end

				if G.input:pressed('SPECIAL') then
					self.state = 'MOVE'
					Game.speedRatio = 1
					self.world.arena.pause = false
					self.timer:cancel('teleport')
					self.teleportTarget:die()
					self.teleportTarget = nil
				end
				]] --
	end

	UFO.vector.x = self.velocity.x
	UFO.vector.y = self.velocity.y

	self.angle = UFO.vector:angleTo()

	-- BOUNDS:
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
end

function UFO:teleport()
	if self.state == 'TELEPORT' then
		return
	end

	self.state = 'TELEPORT'
	Game.speedRatio = 0.3
	self.world.arena.pause = true

	self.timer:after('teleport', 0.4, function()
		self.state = 'MOVE'
		Game.speedRatio = 1
		self.world.arena.pause = false
		self.timer:cancel('teleport')
		-- teleport UFO to target position

		self.x = self.teleportTarget.x
		self.y = self.teleportTarget.y


		self.teleportTarget:die()
		self.teleportTarget = nil
	end)

	-- pickup the best place to teleport
	self.teleportTarget = self.world:createEntity(TeleportTarget, self.x, self.y)

	local heat = 10
	local saferPlace = nil
	local distanceFromHere = 0
	local grid = self:findTheSaferPlace()
	local tx = math.floor(self.x / 64) + 1
	local ty = math.floor(self.y / 64) + 1
	for i = 1, #grid do
		for j = 1, #grid[i] do
			if grid[i][j] > heat then
				heat = grid[i][j]
				-- pick up the farest location from here:
				local distance = math.dist(tx, ty, i, j)
				if distance > distanceFromHere then
					saferPlace = { i, j }
				end
			end
		end
	end

	if saferPlace then
		self.teleportTarget.x = (self.world.arena.x - Arena.radius) + saferPlace[1] * 64 + 32
		self.teleportTarget.y = (self.world.arena.x - Arena.radius) + saferPlace[1] * 64 + 32
	end
end

function UFO:findTheSaferPlace()
	local tileSize = 64
	local gridSize = Arena.radius * 2 / tileSize

	local grid = {}
	for i = 1, gridSize do
		grid[i] = {}
		for j = 1, gridSize do
			grid[i][j] = 0
		end
	end

	local es = self.world:getEntitiesForClassName({ 'Plane', 'UFO', 'Gate', 'Spikes' })
	for ei = 1, #es do
		-- tile where the entities is:
		local x = es[ei].x - (self.world.arena.x - Arena.radius)
		local y = es[ei].y - (self.world.arena.y - Arena.radius)
		x = math.floor(x / tileSize) + 1
		y = math.floor(y / tileSize) + 1

		for i = 1, gridSize do
			for j = 1, gridSize do
				--print(i, j, grid[i][j], math.dist(x, y, i, j))
				grid[i][j] = grid[i][j] + math.floor(math.dist(x, y, i, j))
			end
		end
	end

	--[[
	local line = ''
	for i = 1, gridSize do
		line = ''
		for j = 1, gridSize do
			line = line .. ' ' .. grid[i][j]
		end
		print(line)
	end
	]] --

	return grid
end

function UFO:removed()
	self.world:exploding(self.x, self.y)
	--	self.world:exploding(self.x, self.y, 1.9)
	self.world:createEntity(Explosion, self.x, self.y)
	self.world:gameOver()
	if self.teleportTarget then
		self.teleportTarget:die()
	end
end

function UFO:fire(direction)
	self.bulletCount = self.bulletCount + 1
	if self.bulletCount >= 4 then
		self.bulletCount = 0
		self.life = self.life - 1
	end
	--[[
	if self.lastBulletFired then
		if self.lastBulletFired:is(Fireball) then
			if self.lastBulletFired.life > 0 then
				return
			else
				self.bullet = Bullet -- get back original bullet
			end
		end
	end
	]]

	local angle = direction:angleTo()
	local bullet = self.world:createEntity(self.bullet,
		self.x + math.cos(angle) * 20,
		self.y + math.sin(angle) * 20)

	bullet.timer:after(0.5, function()
		table.insert(bullet.collidables, 'UFO')
	end)

	table.insert(bullet.collidables, 'Plane')
	table.insert(bullet.collidables, 'Kamikaze')
	table.insert(bullet.collidables, 'AngelFace')
	table.insert(bullet.collidables, 'Snake')
	table.insert(bullet.collidables, 'Mine')
	--table.insert(bullet.collidables, 'Bullet')

	bullet.velocity.x = direction.x * 400
	bullet.velocity.y = direction.y * 400

	self.lastBulletFired = bullet

	self.bullet = Bullet -- get back original bullet
	--	self.lazerSfx:stop()
	--	self.lazerSfx:play()
end

function UFO:displayDamage(damage)
	local gainUI = self.world:createEntity(Gain, self.x, self.y)
	gainUI.scale = 0.8
	gainUI.color = { 255, 100, 60 } --{0, 0, 0}
	gainUI.value = '-' .. damage
end

function UFO:hitBy(e)
	if self.world.arena:immerged() then
		self.invincibility = 0.1
	end

	if UFO.super.hitBy(self, e) then

		if e.damage > 0 then
			self:displayDamage(math.floor(e.damage * Game.ufoDamageRatio))
		end
		self:setTint({ 1, 0, 0, 1 }, 0.6)
		if e.shakes then
			self.world.camera:shake(10, 0.4)
			--G.input:vibration(0.5, 0.5)
		end

		if self.deformation.x == 1 and self.deformation.y == 1 then
			self.deformation.x = 0.2 + math.random() * 1.3
			self.deformation.y = 0.2 + math.random() * 1.3
		end
	end
end

function UFO:draw()
	local sr = 0.8
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(Assets.gfx.ship,
		self.x, self.y, 0, self.scale * sr * self.deformation.x, self.scale * sr * self.deformation.y,
		self.pixel:getWidth(), self.pixel:getHeight())

	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.ship,
			self.x, self.y, 0, self.scale * sr * self.deformation.x, self.scale * sr * self.deformation.y,
			self.pixel:getWidth(), self.pixel:getHeight())
		love.graphics.setShader()
	end

	if self.world.arena:immerged() then
		love.graphics.draw(self.particles)
	end

	UFO.super.draw(self)
end

return UFO
-- http://stackoverflow.com/questions/345838/ball-to-ball-collision-detection-and-handling
local Colorable = require('entities/component/Colorable')
local Fireball = Entity:extend('Fireball')
Fireball:implement(Colorable)
Fireball.vector = Vector()

function Fireball:new(x, y)
	Fireball.super.new(self, x, y)

	self.hitboxRadius = 18
	self.life = self.hitboxRadius / 2
	self.damage =  math.floor(self.hitboxRadius / 8)
	self:colorableNew()

	self.friction.x = 1--0.999
	self.friction.y = 1--0.999
	self.hasShadow = true

	self.color = { 255, 255, 255 }

	self.z = 3
	self.zIncrement = 0

	table.insert(self.collidables, 'Mine')
	table.insert(self.collidables, 'Fireball')
	table.insert(self.collidables, 'Tower')
	table.insert(self.collidables, 'Bullet')
	table.insert(self.collidables, 'Plane')

	self.rebound = 10
	--self.debug = true
	self.maskEffect = love.graphics.newShader(Shader.maskEffect)

	--	print('self.velocity', self.velocity)

	self.particles = love.graphics.newParticleSystem(Assets.gfx.cruz, 100)
	self.particles:setParticleLifetime(0.3)
	self.particles:setEmissionRate(100)
	self.particles:setSizes(self.hitboxRadius / 20)
	self.particles:setAreaSpread('normal', self.hitboxRadius / 4, self.hitboxRadius / 4)
	self.particles:setColors(255, 255, 255, 255,
		255, 255, 0, 255,
		255, 100, 100, 200,
		255, 0, 0, 100,
		0, 100, 255, 30,
		255, 255, 255, 30)
	self.particles:setPosition(self.x, self.y)
	self.died = false
	self.timer = Timer()
	self.gain = 10
	--self.debug = true
end

function Fireball:added()
	Fireball.super.added(self)
	self.timer:after(10, function()
		self:die()
	end)
end

function Fireball:split()
	for i = 1, 2 do
		local speed = 100
		local blob = self.world:createEntity(Fireball, self.x, self.y)

		local tangent = math.atan2(self.velocity.x, self.velocity.x)
		if i == 1 then
			blob.velocity.x = math.cos(tangent) * speed
			blob.velocity.y = math.sin(tangent) * speed
		else
			blob.velocity.x = -math.cos(tangent) * speed
			blob.velocity.y = math.sin(tangent) * speed
		end

		--blob.hitboxRadius = self.hitboxRadius * 2 / 3

		blob.hitboxRadius = self.hitboxRadius

		blob.life = self.hitboxRadius / 2
		blob.damage = math.floor(self.hitboxRadius / 8)
		blob.invincibility = 0.8

		if self.hitboxRadius <= 8 then
			blob.timer:after(5, function()
				self:die()
			end)
		end
	end
end

function Fireball:die()
	if not self.died then

		self.hasShadow = false
		self.particles:setEmitterLifetime(0.8)
		self.died = true
		--[[
		if self.hitboxRadius > 8 then
			self:split()
		end
		]]
	end
end

function Fireball:removed()
	Fireball.super.removed(self)
end

function Fireball:update(dt)
	self:colorableUpdate(dt)
	self.timer:update(dt)

	if math.abs(self.velocity.x) < 100 then
		self.velocity.x = math.sign(self.velocity.x) * 100
	end
	if math.abs(self.velocity.y) < 100 then
		self.velocity.y = math.sign(self.velocity.y) * 100
	end

	if self.world.arena:immerged() then
		self:die()
	end

	self.particles:setPosition(self.x, self.y)
	self.particles:setLinearAcceleration(
		-self.velocity.x / Game.speedRatio * 10,
		-self.velocity.y / Game.speedRatio * 10
	)
	self.particles:update(dt)

	-- rebound
	-- NOTE: http://answers.unity3d.com/questions/880103/vector-based-pong-Fireball-bounce-calculations.html
	-- FROM: http://stackoverflow.com/questions/12040547/wanted-to-make-an-object-bounce-inside-a-circle-ended-up-making-the-object-move
	local nx = self.x - self.world.arena.x
	local ny = self.y - self.world.arena.y
	local nd = math.hypot(nx, ny)
	if nd > Arena.radius * 0.5 then
		if nd == 0 then nd = 1 end
		nx = nx / nd
		ny = ny / nd
		local dotProduct = self.velocity.x * nx + self.velocity.y * ny
		self.velocity.x = self.velocity.x + (-2 * dotProduct * nx)
		self.velocity.y = self.velocity.y + (-2 * dotProduct * ny)
	end

	if self.died then
		if self.particles:getCount() == 0 then
			Fireball.super.die(self)
		end
	end

	Fireball.super.update(self, dt)
end

function Fireball:hitBy(e)
	--	self:setTint({ 1, 0, 0, 1 }, 0.6)

	local ratio = e.force or 50
	--[[
	if e:is(Bullet) then
		self.hitboxRadius = 18
		self.life = self.hitboxRadius / 2
		self.damage = self.hitboxRadius / 8
	end
	]]

	local ang = math.atan2(self.y - e.y, self.x - e.x)
	self.velocity.x = self.velocity.x + math.cos(ang) * ratio * self.friction.x
	self.velocity.y = self.velocity.y + math.sin(ang) * ratio * self.friction.y

	if not e:is(Fireball) then
		-- this hack prevent a non bullet to be safe for the blob
		local edamage = e.damage
		local blobDamage = self.damage
		if not e:is(Bullet) then
			e.damage = 0 -- no damage
			if e:is(UFO) then
				self.damage = 1 -- minimum damage for UFO
			end
		end

		Fireball.super.hitBy(self, e)

		-- restore the initial values:
		e.damage = edamage
		self.damage = blobDamage
	end
end

function Fireball:draw()
	if not self.died then
		love.graphics.setColor(255, 255, 255)
		love.graphics.circle('fill', self.x, self.y, self.hitboxRadius / 2 * self.scale)

		if self.colorableDuration > 0 then
			self.maskEffect:send('colorFill', self.color)
			love.graphics.setShader(self.maskEffect)
			love.graphics.circle('fill', self.x, self.y, self.hitboxRadius / 2 * self.scale)
			love.graphics.setShader()
		end

		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.draw(self.particles)

	Fireball.super.draw(self)
end

return Fireball
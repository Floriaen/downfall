local Colorable = require('entities/component/Colorable')
local Plane = Entity:extend('Plane')
Plane:implement(Colorable)

Plane.vector = Vector()

function Plane:new(x, y)
	Plane.super.new(self, x, y)
	self.hitboxRadius = 10
	self.life = 4
	self.target = nil
	self:colorableNew()
	self.timer = Timer()
	self.speed = 3
	self.z = 10.1
	self.shakes = true
	
	self.timer:every(0.3, function()
			Plane.vector:normalize_inplace()
			--self:fire(Plane.vector)
		end)

	self.zIncrement = 0
	
	table.insert(self.collidables, 'Plane')
	table.insert(self.collidables, 'UFO')
	
	self.maskEffect = love.graphics.newShader(Shader.maskEffect)
	self.spawnPill = false
	self.damage = 6

	--self.maxVelocity.x = 380
	--self.maxVelocity.y = 380

	self.explosionSfx = love.audio.newSource(Assets.sfx.explosion, "static")
	self.explosionSfx:setVolume(0.5)
	self.explosionSfx:setPitch(2)
end

function Plane:update(dt)
	Plane.super.update(self, dt)
	self.timer:update(dt)

	self:colorableUpdate(dt)
	-- follow:
	if self.target then
		local ang = math.atan2(self.y - self.target.y ,  self.x - self.target.x)
		self.velocity.x = self.velocity.x - math.cos(ang) * self.speed
		self.velocity.y = self.velocity.y - math.sin(ang) * self.speed
	end	
	
	local radius = Arena.radius * 0.5
	local position = Vector(self.x, self.y)
	local center = Vector(self.world.arena.x, self.world.arena.y)
	local offset = 	position - center
	local distance = offset:len()

	if (radius < distance) then
		local direction = offset / distance
		position = center + direction * radius

		self.x = position.x
		self.y = position.y
	end	
	
	Plane.vector.x = self.velocity.x
	Plane.vector.y = self.velocity.y 
	
	self.angle = Plane.vector:angleTo()
end

function Plane:fire(direction)
	local bullet = self.world:createEntity(
		Bullet, 
		self.x - 5,--self.pixel:getWidth() / 2, 
		self.y - 5 --self.pixel:getHeight() / 2
	)
	table.insert(bullet.collidables, 'UFO')
	bullet.hitboxRadius = 10
	bullet.color = {255, 255, 0}
	bullet.z = self.z - 1

	bullet.velocity.x = direction.x * 400
	bullet.velocity.y = direction.y * 400
end

function Plane:draw()
	love.graphics.draw(Assets.gfx.enemy, self.x, self.y, self.angle + math.pi / 2, self.scale, self.scale, 12, 11)

	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.enemy, self.x, self.y, self.angle + math.pi / 2, self.scale, self.scale, 12, 11)
		love.graphics.setShader()
	end
	Plane.super.draw(self)
end

function Plane:removed()
	--self.world:exploding(self.x, self.y)

	self.world:createEntity(Explosion, self.x, self.y)
	local explosion2 = self.world:createEntity(Explosion, self.x - 20, self.y - 10)
	explosion2.delay = 0.1
	explosion2.duration = 0.3
	explosion2.toRadius = 30
	local explosion3 = self.world:createEntity(Explosion, self.x + 8, self.y + 20)
	explosion3.delay = 0.05
	explosion3.duration = 0.5
	explosion3.toRadius = 28


	--self.world:explode(self.x, self.y, 1.9)

	if self.spawnPill then
		local classItem = Energy
		local r = math.random()
		if r > 0.8 then
			-- if there is no Teleport item in the arena:
			local es = self.world:getEntitiesForClassName({'Teleport'})
			if #es == 0 then
				classItem = Teleport
			end
		elseif r > 0.6 then
			-- disallow spawn fireball if there is at least one on the screen
			local es = self.world:getEntitiesForClassName({'Fireball', 'FirePill'})
			if #es == 0 then
				classItem = FirePill
			end
		elseif r > 0.1 then
			-- disallow spawn fireball if there is at least one on the screen
			local es = self.world:getEntitiesForClassName({'WaterPill'})
			if #es == 0 then
				--classItem = WaterPill
			end
		end

		local pill = self.world:createEntity(classItem, self.x, self.y)
		Plane.vector:normalize_inplace()
		pill.velocity.x = Plane.vector.x * 100
		pill.velocity.y = Plane.vector.y * 100
	end
	self.world.arena:addStain(self.x, self.y)
end

function Plane:hitBy(e)
	if not e:is(Plane) then
		self:setTint({1, 0, 0, 1}, 0.6)
		Plane.super.hitBy(self, e)
	end

	if self.life > 0 then
		local ratio = e.force or 50
		local ang = math.atan2(self.y - e.y ,  self.x - e.x)
		self.velocity.x = self.velocity.x + math.cos(ang) * ratio * self.friction.x
		self.velocity.y = self.velocity.y + math.sin(ang) * ratio * self.friction.y
	else
		-- Plane is dead
		if e:is(Bullet) or e:is(Fireball) then
			self.spawnPill = true
		end
	end
end

return Plane
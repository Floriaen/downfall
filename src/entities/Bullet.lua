local Bullet = Entity:extend('Bullet')

function Bullet:new(x, y)
	Bullet.super.new(self, x, y)
	self.hitboxRadius = 14
	self.friction.x = 0.999
	self.friction.y = 0.999
	self.hasShadow = false
	self.force = 30
	self.color = { 255, 255, 255 } --, 210}

	self.damage = 2
	self.timer = Timer()
	self.alpha = 255
	--self.timer:tween(0.5, self, {alpha = 255})


	self.pixel = love.graphics.newCanvas(20, 10)
	love.graphics.setCanvas(self.pixel)

	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', 5, 5, 5)
	love.graphics.rectangle('fill', 5, 0, 10, 10)
	love.graphics.circle('fill', 15, 5, 5)
	love.graphics.setCanvas()

	--	self.debug = true
	self.neighbor = nil

	self.z = 10
	self.zIncrement = 0
	--[[
		self.particles = love.graphics.newParticleSystem(Assets.gfx.cruz, 100)
		self.particles:setParticleLifetime(0.3)
		self.particles:setEmitterLifetime(0.2)
		self.particles:setEmissionRate(60)
		self.particles:setSizes(0.5, 3)
		self.particles:setSpeed(1, 3)
		self.particles:setAreaSpread('normal', 3, 3)
		self.particles:setTangentialAcceleration(3, 3)
		self.particles:setColors(
			255, 255, 0, 255,
			255, 100, 100, 200,
			255, 0, 0, 100,
			0, 100, 255, 30,
			255, 255, 255, 30)
		self.particles:setPosition(self.x, self.y)
	]] --
	self.visible = true

	self.angle = 0
end

function Bullet:added()
	Bullet.super.added(self)
	self.timer:after(6, function()
		self:die()
	end)
end

function Bullet:update(dt)
	self.velocity.x = self.velocity.x / Game.speedRatio
	self.velocity.y = self.velocity.y / Game.speedRatio
	self.angle = self.angle + dt
	if self.angle > math.pi * 2 then
		self.angle = 0
	end

	--[[
	self.particles:setRotation(self.angle)
	self.particles:setDirection(math.random() * math.pi)
	self.particles:setLinearAcceleration(
		self.velocity.x / Game.speedRatio * 10 + (30 - math.random() * 30),
		self.velocity.y / Game.speedRatio * 10 + (30 - math.random() * 30)
	)
	self.particles:update(dt)
	]]
	Bullet.super.update(self, dt)
	self.timer:update(dt)

	--	self.neighbor = nil
	--[[
	if not self.neighbor then

		local maxDistance = 20
		local es = self.world:getEntitiesForClassName({'Plane'})
		if #es == 0 then

		else
			for i = 0, #es do
				if es[i] then
					local distanceFromEntity = self:distance(es[i])
					if distanceFromEntity < maxDistance then
						self.color = {255, 0, 0}
						self.neighbor = es[i]
						maxDistance = self:distance(es[i])
					end
				end
			end
		end
	else
		if self.neighbor.life == 0 then
			--self:die()
			local es = self.world:getEntitiesForClassName({'Plane'})
			if #es == 0 then
				self:die()
			end
			self.neighbor = nil
		end
	end
]] --
	if false and self.neighbor then
		-- go to target
		local ang = math.atan2(self.y - self.neighbor.y, self.x - self.neighbor.x)
		self.velocity.x = self.velocity.x - math.cos(ang) * 10
		self.velocity.y = self.velocity.y - math.sin(ang) * 10
		--[[
				G.vector.x = self.neighbor.x - self.x
				G.vector.y =  self.neighbor.y - self.y
				G.vector:normalize_inplace()

				local force = G.vector:len()
				self.velocity.x = G.vector.x * force + self.velocity.x
				self.velocity.y = G.vector.y * force + self.velocity.y
				]] --
	end
	--[[
	self.angle = self.angle + dt * 20
	if self.angle > math.pi * 2 then
		self.angle = 0
	end
	]]
	-- BOUNDS:
	local radius = Arena.radius * 0.6
	local position = Vector(self.x, self.y)
	local center = Vector(self.world.arena.x, self.world.arena.y)
	local offset = position - center
	local distance = offset:len()
	if (radius + 10 < distance) then
		--self:die()
		self.visible = false
	end

	if not self.visible then
		--	if self.particles:isStopped() then
		self:die()
		--	end
	end
end

function Bullet:draw()
	if self.visible then

		self.color[4] = self.alpha

		gaussian.color = self.color
		gaussian.drawFunc(function()
			love.graphics.setColor(255, 255, 255)
		--		love.graphics.circle('fill', self.x, self.y, self.hitboxRadius / 2 + 5)
		end)


		love.graphics.setColor(self.color)


		love.graphics.draw(Assets.gfx.smoke,
			self.x, self.y, self.angle, 1, 1,
			Assets.gfx.smoke:getWidth() / 2,
			Assets.gfx.smoke:getHeight() / 2)

		love.graphics.circle('fill', self.x, self.y, self.hitboxRadius / 2)

		love.graphics.setColor(255, 255, 255)
	end

	--	love.graphics.draw(self.particles)
	Bullet.super.draw(self)
end

return Bullet
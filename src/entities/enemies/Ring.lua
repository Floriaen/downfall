local Ring = Entity:extend('Ring')

Ring.vector = Vector()

function Ring:new(x, y)
	Ring.super.new(self, x, y)
	self.hitboxRadius = 30
	self.life = 4
	self.target = nil

	self.timer = Timer()
	self.speed = 3
	self.z = 1
	self.shakes = true

	self.z = 2
	self.zIncrement = 0

	table.insert(self.collidables, 'Plane')

	self.damage = 0
	self.state = 'stick' -- 'follow' 'stop'

	self.followSpeedRatio = 4
end

function Ring:update(dt)
	Ring.super.update(self, dt)
	self.timer:update(dt)

	-- follow:
	if self.target then
		if self.state == 'stick' then
			local ang = math.atan2(self.y - self.target.y, self.x - self.target.x)
			local distSqr = (self.target.x - self.x) * (self.target.x - self.x) + (self.target.y - self.y) * (self.target.y - self.y)

			if distSqr / 160 > 1 then
				self.speed = 5 * distSqr / 160
			else
				if distSqr / 20 < 1 then
					self.speed = 5 * distSqr / 20
				else
					self.speed = 3
				end
			end

			self.velocity.x = self.velocity.x - math.cos(ang) * self.speed
			self.velocity.y = self.velocity.y - math.sin(ang) * self.speed
		elseif self.state == 'follow' then
			self.velocity.x = 0
			self.velocity.y = 0
			self.x = math.lerp(self.x, self.target.x, dt * self.followSpeedRatio)
			self.y = math.lerp(self.y, self.target.y, dt * self.followSpeedRatio)
		else

			-- stop
			self.velocity.x = 0
			self.velocity.y = 0

			self.followSpeedRatio = math.lerp(self.followSpeedRatio, 0, dt * 3)

			self.x = math.lerp(self.x, self.target.x, dt * self.followSpeedRatio)
			self.y = math.lerp(self.y, self.target.y, dt * self.followSpeedRatio)
		end
	end

	-- limit
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

	Ring.vector.x = self.velocity.x
	Ring.vector.y = self.velocity.y

	self.angle = Ring.vector:angleTo()
end

function Ring:draw()
	local scale = self.scale * 2
	--love.graphics.setColor(0, 0, 0)
	--love.graphics.circle('fill', self.x, self.y, 30)
	love.graphics.draw(Assets.gfx.snakeRing, self.x, self.y, self.angle, scale, scale, 24, 24)
	Ring.super.draw(self)
end

return Ring


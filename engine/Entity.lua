local Entity = Class:extend('Entity')

Entity.zDistance = 20
Entity.scaleRatio = 0.34
Entity.debug = false --true
Entity.ZERO = 0.001

function Entity:new(x, y)
	self.x = x
	self.y = y
	self.velocity = { x = 0, y = 0 }
	self.angle = 0
	self.origin = { x = 0, y = 0 }
	self.friction = { x = 0.98, y = 0.98 }
	self.hitboxRadius = 30
	self.life = 1
	self.damage = 1
	self.hasShadow = true
	self.invincibility = 0
	self.scale = 1
	self.z = 0
	self.zIncrement = -1

	self.collidables = {}
	self.collidable = true
	self.debugMessage = ''
	self.maxVelocity = { x = 0, y = 0 }

	self.hitBack = 0
end

function Entity:update(dt)
	if self.zDistance > 0 then
		self.z = self.z + self.zIncrement * self.zDistance * dt
		if self.zIncrement == 1 and self.z > self.zDistance then
			self.zIncrement = -1
		elseif self.zIncrement == -1 and self.z < 0 then
			self.zIncrement = 1
		end
		self.scale = 1 + (self.z / self.zDistance) * self.scaleRatio
	end

	self.velocity.x = self.velocity.x * self.friction.x * Game.speedRatio
	self.velocity.y = self.velocity.y * self.friction.y * Game.speedRatio

	-- max velocity
	if self.maxVelocity.x ~= 0 then
		local unsignVelocityX = math.abs(self.velocity.x)
		if unsignVelocityX > self.maxVelocity.x then
			local dirX = self.velocity.x >= 0 and 1 or -1
			self.velocity.x = self.maxVelocity.x * dirX
		end
	end

	if self.maxVelocity.y ~= 0 then
		local unsignVelocityY = math.abs(self.velocity.y)
		if unsignVelocityY > self.maxVelocity.y then
			local dirY = self.velocity.y >= 0 and 1 or -1
			self.velocity.y = self.maxVelocity.y * dirY
		end
	end

	self.x = self.x + self.velocity.x * dt
	self.y = self.y + self.velocity.y * dt

	if self.invincibility > 0 then
		self.invincibility = self.invincibility - dt
		if self.invincibility < 0 then
			self.invincibility = 0
		end
	end

	-- COLLISION
	if #self.collidables > 0 then
		local es = self.world:getEntitiesForClassName(self.collidables)
		for i = 1, #es do
			if es[i] ~= self then
				if self:overlaps(es[i]) then
					if es[i].collidable and self.collidable then
						es[i]:hitBy(self)
						self:hitBy(es[i])
					end
				end
			end
		end
	end

	if self.life <= 0 then
		self:die()
	end
end

function Entity:added()
end

function Entity:removed()
end

function Entity:draw()
	if self.debug then
		if self.hitboxRadius > 0 then
			love.graphics.push()
			love.graphics.origin()

			love.graphics.setColor(255, 100, 10, 100)
			love.graphics.circle('fill', self.x, self.y, self.hitboxRadius)
			love.graphics.setColor(255, 100, 10, 255)
			love.graphics.circle('line', self.x, self.y, self.hitboxRadius)
			love.graphics.setColor(255, 255, 255)

			love.graphics.setFont(Font.system)
			love.graphics.print(self.class_name .. ' ' .. self.life .. ' z: ' .. (math.floor(self.z * 10) / 10), self.x, self.y)
			--	love.graphics.print(self.debugMessage, self.x, self.y)
			love.graphics.pop()
		end
	end
end

function Entity:hitBy(e)
	local hit = false
	if self.invincibility == 0 then
		hit = true
		self.invincibility = 0.2
		self.life = self.life - e.damage
		if self.life < 0 then
			self.life = 0
		end
	end

	if self.hitBack > 0 then
		local ang = math.atan2(self.y - e.y, self.x - e.x)
		e.velocity.x = e.velocity.x - math.cos(ang) * self.hitBack
		e.velocity.y = e.velocity.y - math.sin(ang) * self.hitBack
	end

	return hit
end

function Entity:die()
	self.life = 0
	if self.world then
		self.world:removeEntity(self)
	end
end

function Entity:collide(entity)
	if entity.hitbox then
		return self:intersects(entity)
	end
	return self:overlaps(entity)
end

function Entity:intersects(entity)

	--[[
		(abs(a.x - b.x) * 2 < (a.width + b.width)) &&
         (abs(a.y - b.y) * 2 < (a.height + b.height));
	]] --

	if self.x > entity.hitbox.x and self.x < entity.hitbox.x + entity.hitbox.w then
		if self.y > entity.hitbox.y and self.y < entity.hitbox.y + entity.hitbox.h then
			return true
		end
	end
	return false
end

function Entity:overlaps(entity)
	if self.collidable and self.hitboxRadius > 0 then
		local maxDist = self.hitboxRadius + entity.hitboxRadius;
		-- classic distance formula
		local distSqr = (entity.x - self.x) * (entity.x - self.x) + (entity.y - self.y) * (entity.y - self.y)
		if distSqr <= maxDist * maxDist then
			-- square root computed here for performances sake
			return math.sqrt(distSqr) <= maxDist;
		end
	end
	return false;
end

function Entity:distance(e)
	return ((e.x - self.x) ^ 2 + (e.y - self.y) ^ 2) ^ 0.5
end

return Entity
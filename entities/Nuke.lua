local Nuke = Entity:extend('Nuke')

Nuke.vector = Vector()

function Nuke:new(x, y)
	Nuke.super.new(self, x, y)
	self.hitboxRadius = 0
	self.hasShadow = false
	self.zIncrement = 0
	self.z = 3
	self.timer = Timer()
	self.free = false
end

function Nuke:added()
	Nuke.super.added(self)
	self.timer:tween(1, self, {hitboxRadius = Arena.radius}, 'linear', function()
			print('remove halo')
			self:die()
			self.free = true
		end)
end

function Nuke:overlaps(entity)
	if self.hitboxRadius > 0 then
		local maxDist = self.hitboxRadius + entity.hitboxRadius;
		-- classic distance formula
		local distSqr = (entity.x - self.x) * (entity.x - self.x) + (entity.y - self.y) * (entity.y - self.y)
		
		if distSqr <= maxDist * maxDist then
			-- square root computed here for performances sake
			local dist = math.sqrt(distSqr)
		--	print('dist', dist, maxDist)			
			return dist <= maxDist and dist >= maxDist - 40;
		end
	end
	return false;
	
	--x = cx + r * cos(a)
	--y = cy + r * sin(a)
end

function Nuke:update(dt)
	Nuke.super.update(self, dt)
	self.timer:update(dt)
	local entities = self.world:getEntitiesForClassName({'Plane'})
	for i = 1, #entities do
		if not entities[i].isSlowingDown then
			if self:overlaps(entities[i]) then
				entities[i].slowingDown = true
				local friction = {
					x = entities[i].friction.x,
					y = entities[i].friction.y
				}
				print('friction', friction.x, friction.y)
				entities[i].friction.x = 0.2
				entities[i].friction.y = 0.2
				
--[[
				Nuke.vector.x = entities[i].x - self.x
				Nuke.vector.y = entities[i].y - self.y
				Nuke.vector:normalize_inplace()

				
				Plane.vector.x = entities[i].velocity.x
				Plane.vector.y = entities[i].velocity.y
				local force = Plane.vector:len()
				force = force * 10
				
				Nuke.vector.x = Nuke.vector.x * force * dt
				Nuke.vector.y = Nuke.vector.y * force * dt
				
				entities[i].velocity.x = entities[i].velocity.x + Nuke.vector.x
				entities[i].velocity.y = entities[i].velocity.y + Nuke.vector.y

				if entities[i].slowingDown then
					entities[i]:slowingDown()
				end

				]]--
				print('tween', entities[i].friction.x, 'to', friction.x)
				self.timer:tween(4, entities[i].friction, {x = friction.x, y = friction.y}, 'linear', function()
						entities[i].slowingDown = false
					end)

			end
		end
	end
end

function Nuke:draw()
	love.graphics.setColor(255, 255, 255, 40)
	love.graphics.circle('fill', self.x, self.y, self.hitboxRadius)
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('line', self.x, self.y, self.hitboxRadius)
	
	Nuke.super.draw(self)
end

return Nuke
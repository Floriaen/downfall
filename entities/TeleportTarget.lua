local TeleportTarget = Entity:extend('TeleportTarget')

function TeleportTarget:new(x, y)
	TeleportTarget.super.new(self, x, y)
	self.zIncrement = 0
	self.z = 1
	self.hitboxRadius = 0
	self.hasShadow = false
end

function TeleportTarget:update(dt)
	TeleportTarget.super.update(self, dt)
	self.speed = 40 / Game.speedRatio

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

function TeleportTarget:draw()

	love.graphics.setColor(255, 255, 255, 140)
	--love.graphics.draw(Assets.gfx.ship, self.x, self.y, 0, self.scale, self.scale, Assets.gfx.ship:getWidth() / 2, Assets.gfx.ship:getHeight() / 2)

	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.circle('line', self.x, self.y, Assets.gfx.ship:getWidth() / 2)
	TeleportTarget.super.draw(self)
end

return TeleportTarget


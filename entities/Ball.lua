local Ball = Entity:extend('Ball')

Ball.vector = Vector()

function Ball:new(x, y)
	Ball.super.new(self, x, y)
	self.hitboxRadius = 16
--	self.friction.x = 0.99
--	self.friction.y = 0.99
	self.hasShadow = false

	--self.force = 30
	self.color = {255, 255, 255}
	self.alpha = 255

	self.damage = 2
	self.timer = Timer()

	self.z = 3
	self.zIncrement = 0

	table.insert(self.collidables, 'UFO')
	table.insert(self.collidables, 'Mine')
	table.insert(self.collidables, 'Tower')
	table.insert(self.collidables, 'Ball')
	table.insert(self.collidables, 'Bullet')

	self.rebound = 10
	--self.debug = true
end

function Ball:added()
	Ball.super.added(self)

	self.timer:after(1, function()
		--table.insert(self.collidables, 'Tower')
	end)

	self.timer:tween(1, self, {hitboxRadius = 16}, 'linear', function()

	end)
end

function Ball:update(dt)
	self.velocity.x = self.velocity.x / Game.speedRatio
	self.velocity.y = self.velocity.y / Game.speedRatio

	Ball.super.update(self, dt)
	self.timer:update(dt)

	-- TODO: http://answers.unity3d.com/questions/880103/vector-based-pong-ball-bounce-calculations.html
	local dx = self.world.arena.x - self.x
	local dy = self.world.arena.y - self.y
--[[
	local overlaps = math.hypot(dx, dy) - (Arena.radius * 0.6 - self.hitboxRadius)
	if overlaps >= 0 then
]]

	local radius = Arena.radius * 0.5
	local position = Vector(self.x, self.y)
	local center = Vector(self.world.arena.x, self.world.arena.y)
	local offset = 	position - center
	local distance = offset:len()

	if (radius < distance) then
		self.world:createEntity(Explosion, self.x, self.y)
		self:die()
		--print(dx, dy)
		local tangent = math.atan2(dy, dx)
	--	self.angle = 2 * tangent - self.angle
		--self.speed *= elasticity
	--	self.angle = 0.5 * math.pi + tangent

--		self.velocity.x = self.velocity.x + math.sin(tangent) * self.rebound
--		self.velocity.y = self.velocity.y - math.cos(tangent) * self.rebound
	end

end

function Ball:hitBy(e)
	if e:is(Bullet) then
		self.world:createEntity(Explosion, self.x, self.y)
		self:die()
		e:die()
	else
		local tangent = math.atan2(self.y - e.y ,  self.x - e.x)
	--	self.velocity.x = self.velocity.x + math.sin(tangent) * self.rebound
	--	self.velocity.y = self.velocity.y - math.cos(tangent) * self.rebound
	end
--	Ball.super.hitBy(self, e)
end

function Ball:draw()
	self.color[4] = self.alpha
	love.graphics.setColor(self.color)
	love.graphics.circle('fill', self.x, self.y, self.hitboxRadius / 2 * self.scale)
	love.graphics.setColor(255, 255, 255)
	Ball.super.draw(self)
end

return Ball


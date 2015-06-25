local Colorable = require('entities/component/Colorable')
local AnimatedSprite = require 'entities/component/AnimatedSprite'
local Snake = Entity:extend('Snake')
Snake:implement(AnimatedSprite)
Snake:implement(Colorable)

Snake.ringCount = 5
Snake.vector = Vector()

function Snake:new(x, y)
	Snake.super.new(self, x, y)
	self:colorableNew()

	self.hitboxRadius = 30

	self.z = 3
	self.zIncrement = 0
	self.scaleRatio = 1
	self.zDistance = 4

	self.tail = {}
	self.life = 10

	self.speed = 5
	self.target = nil
	self.timer = Timer()
	self.moveAround = false

	table.insert(self.collidables, 'Plane')
	self.maskEffect = love.graphics.newShader(Shader.maskEffect)

	self.damage = 0
	self.active = true
end

function Snake:added()
	Snake.super.added(self)

	local z = self.z - 0.1
	local previousRing = self
	for i = 1, Snake.ringCount do
		local ring = self.world:createEntity(Ring, self.x, self.y)
		ring.target = previousRing
		ring.z = z
		z = z - 0.1
		previousRing = ring

		table.insert(self.tail, ring)
	end

	local x = self.world.arena.x + math.cos(self.world.arena.angle + math.pi / 2) * Arena.radius * 0.5
	local y = self.world.arena.y +  math.sin(self.world.arena.angle + math.pi / 2) * Arena.radius * 0.5

	self.timer:tween(1, self, {x = x, y = y}, 'linear', function()
		self.moveAround = true
		self.damage = 6
		for i = 1, #self.tail do
			self.tail[i].damage = 4
			self.tail[i].state = 'follow'
			table.insert(self.tail[i].collidables, 'UFO')
			table.insert(self.tail[i].collidables, 'UFO')
		end
		table.insert(self.collidables, 'UFO')
	end)
end

function Snake:update(dt)
	Snake.super.update(self, dt)
	self.timer:update(dt)
	self:colorableUpdate(dt)

	--self.scale = 1 + (self.z / self.zDistance) * Entity.scaleRatio
	print(self.z, self.zDistance, self.scaleRatio, '=', 1 + (self.z / self.zDistance) * self.scaleRatio)
	if self.active then
		if self.moveAround then
			self.angle = self.angle + dt * math.pi / 3
			self.x = self.world.arena.x + math.cos(self.world.arena.angle + self.angle + math.pi / 2) * Arena.radius * 0.5
			self.y = self.world.arena.y +  math.sin(self.world.arena.angle + self.angle + math.pi / 2) * Arena.radius * 0.5
		end
	end

--[[
	self.target = self.world.player
	print(G.player)
	if self.target then
		local ang = math.atan2(self.y - self.target.y ,  self.x - self.target.x)
		self.velocity.x = self.velocity.x - math.cos(ang) * self.speed
		self.velocity.y = self.velocity.y - math.sin(ang) * self.speed
	end


	Snake.vector.x = self.velocity.x
	Snake.vector.y = self.velocity.y

	self.angle = Snake.vector:angleTo()
	]]--
--[[
	--self:animatedSpriteUpdate(dt)
	local previousRing = {x = self.x, y = self.y}
	for i = 1, #self.tail do
		local ang = math.atan2(self.tail[i].y - previousRing.y, self.tail[i].x - previousRing.x)

		self.tail[i].velocity.x = self.tail[i].velocity.x - math.cos(ang)
		self.tail[i].velocity.y = self.tail[i].velocity.y - math.sin(ang)
		self.tail[i].x = self.tail[i].x + self.tail[i].velocity.x * dt * Game.speedRatio
		self.tail[i].y = self.tail[i].y + self.tail[i].velocity.y * dt * Game.speedRatio

		previousRing = self.tail[i]
	end
	]]--
end

function Snake:removed()
	for i = 1, #self.tail do
		self.world:removeEntity(self.tail[#self.tail - i + 1])
	end
	Snake.super.removed(self)
end


function Snake:hitBy(e)
	if not self.active then
		return
	end

	if not e:is(Plane) then
		self:setTint({1, 0, 0, 0.6}, 0.6)
	end
	if self.life - e.damage <= 0 then
		-- wait until die
		self.active = false

		for i = 1, #self.tail do
			self.tail[i].state = 'stop'
			self.timer:tween(1, self.tail[i], {z = self.tail[i].z - 1.5}, 'linear')
		end

		self.timer:tween(1, self, {z = 1.5}, 'linear', function()
			self.timer:after(10, function()



				self.life = 0
			end)
		end)
	else
		Snake.super.hitBy(self, e)
	end
end

function Snake:draw()
	local scale = self.scale * 1.2
	love.graphics.draw(Assets.gfx.snakeRing, self.x, self.y, self.angle + math.pi, scale, scale, 24, 24)
	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.snakeRing, self.x, self.y, self.angle + math.pi, scale, scale, 24, 24)
		love.graphics.setShader()
	end
	Snake.super.draw(self)
end

return Snake




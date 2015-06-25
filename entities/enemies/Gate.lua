local Colorable = require('entities/component/Colorable')
local AnimatedSprite = require'entities/component/AnimatedSprite'
local Gate = Entity:extend('Gate')
Gate:implement(AnimatedSprite)
Gate:implement(Colorable)

Gate.spawnDelay = 0.8
Gate.spawnCount = 10
Gate.maxMovementCount = 3 --12

function Gate:new(x, y)
	Gate.super.new(self, x, y)
	self.spawnClass = Plane
	self.life = 1000 -- TODO
	self.timer = Timer()
	self.spawnCount = Gate.spawnCount
	self.spawned = 0
	self.doSpawn = false

	self.hasShadow = false

	self.scale = 2
	self.movementCount = 0
	self.zDistance = 0
	self.z = 1
	self.decay = math.pi / 2
	self.delay = 0.5
end

function Gate:onEvent(event)
	if event == 'END_LOOP' then
		self.timer:after(self.delay, function()
			self:playAnimation('opening')
			self.doSpawn = true
		end)
	end
end

function Gate:added()
	if self.spawnClass == Kamikaze then
		self.scale = 2.4
		self:animatedSpriteNew(Assets.gfx.deathDoor, 30, 30)
	else
		self:animatedSpriteNew(Assets.gfx.door, 30, 30)
	end

	self:addAnimation('opening', { { 1, 1 }, { 2, 1 }, { 3, 1 } }, 0.1, false)
	self:addAnimation('closing', { { 3, 1 }, { 2, 1 }, { 1, 1 } }, 0.06, false)
	self:playAnimation('opening')
	self:getCurrentAnimation():stop()

	Gate.super.added(self)
	self.timer:after(self.delay, function()
		self:playAnimation('opening')
		self.doSpawn = true
	end)
end

function Gate:update(dt)
	Gate.super.update(self, dt)
	self.timer:update(dt)
	self:animatedSpriteUpdate(dt)

	if self.doSpawn then
		self.spawnDelay = self.spawnDelay - dt
		if self.spawnDelay <= 0 then
			self.spawnDelay = Gate.spawnDelay
			self.spawned = self.spawned + 1
			if self.spawned % self.spawnCount == 0 then
				self.doSpawn = false
				self:playAnimation('closing')
			end
			self:spawn()
		end
	end

	-- turn around
	self.x = self.world.arena.x + math.cos(self.world.arena.angle + self.decay) * Arena.radius * 0.5
	self.y = self.world.arena.y + math.sin(self.world.arena.angle + self.decay) * Arena.radius * 0.5
end

function Gate:spawn()
	local vector = Vector(self.x - self.world.player.x, self.y - self.world.player.y)
	vector:normalize_inplace()

	local enemy = self.world:createEntity(self.spawnClass, self.x, self.y)
	enemy.velocity.x = -vector.x * 330
	enemy.velocity.y = -vector.y * 330
	enemy.target = self.world.player
end

function Gate:draw()
	Gate.super.draw(self)
	local r = self.decay - math.pi * 1.5
	self:animatedSpriteDraw(self.x, self.y, self.world.arena.angle + r, self.scale, self.scale, 15, 30)
end

function Gate:hitBy(e)
	if not e:is(Plane) then
		self:setTint({ 255, 0, 0 }, 0.7)
		Gate.super.hitBy(self, e)
	end
end

return Gate
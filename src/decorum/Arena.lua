local Arena = Entity:extend('Arena')

Arena.radius = 300
Arena.goToLevelDuration = 1
Arena.debug = false

function Arena:new(x, y)
	Arena.super.new(self, x, y)
	self.Gates = {}

	if Arena.debug then
		self.levels = require('assets/data/test')
	else
		self.levels = require('assets/data/levels')
	end

	self.scale = 1
	self.timer = Timer()
	self.z = 0

	-- ground glasspane
	self.groundCanvas = love.graphics.newCanvas(Arena.radius, Arena.radius)
	love.graphics.setCanvas(self.groundCanvas)
	love.graphics.setColor(255, 100, 100, 100)
--	love.graphics.rectangle('fill', 0, 0, Arena.radius, Arena.radius)
	love.graphics.setCanvas()

	self.groundTempCanvas = love.graphics.newCanvas(self.groundCanvas:getWidth(), self.groundCanvas:getHeight())

	self.groundAngle = 0
	self.hasShadow = false
	self.zDistance = 0
	self.hitboxRadius = 0
	self.movementLocked = false
	self.nextLevelIndex = 0
	self.waterRadius = Arena.radius * 0.5
	self.maskEffect = love.graphics.newShader(Shader.maskEffect)

	self.wind = Vector()

	self.pause = false
end

function Arena:getCurrentLevelName()
	return self:getLevel(self.nextLevelIndex - 1).name
end

function Arena:getLevel(level)
	-- loop
	if level < 1 then
		level = #self.levels
	elseif level > #self.levels then
		level = 1
	end
	return self.levels[level]
end

function Arena:added()
	Arena.super.added(self)
	self.nextLevelIndex = 1 --9
	self.nextLevelIndex = self.nextLevelIndex + 1
	self:initLevel()
end

-- Work only one time
function Arena:goToPreviousLevel(onComplete)
	if not Arena.debug and self.nextLevelIndex <= 2 then
		if onComplete then
			onComplete()
		end
		return
	end

	if self.movementLocked == true then return end -- for manual control

	self.timer:cancel('every')
	self.movementLocked = true

	-- reset current level
	self:resetLevel()
	self.scale = 4

	self.nextLevelIndex = self.nextLevelIndex - 1

	self.timer:tween(Arena.goToLevelDuration, self, { scale = 1, groundAngle = self.groundAngle - 0.4 }, 'linear',
		function()
			self.movementLocked = false
			self:initLevel()
			self.scale = 1
			if onComplete then
				onComplete()
			end
		end)
	--end
end

function Arena:resetLevel() -- clean
	for i = 1, #self.Gates do
		self.world:removeEntity(self.Gates[i])
	end
end

function Arena:goToNextLevel(onComplete)
	if not Arena.debug then
		if self.nextLevelIndex > #self.levels then
			-- GAME OVER
			self.world:gameOver()
			return
		end
	end
	if self.movementLocked == true then return end -- for manual control

	self.timer:cancel('every')
	self.movementLocked = true

	-- reset current level
	self:resetLevel()
	self.scale = 1

	self.timer:tween(Arena.goToLevelDuration, self,
		{
			scale = 4,
			groundAngle = self.groundAngle + 0.4
		},
		'linear',
		function()
			self.movementLocked = false

			self.nextLevelIndex = self.nextLevelIndex + 1
			self:initLevel()

			self.scale = 1

			if onComplete then
				onComplete()
			end
		end)
end

function Arena:updateGround()
	--temp:clear()
	love.graphics.setCanvas(self.ground)
	-- self.groundAngle
	love.graphics.setCanvas(self.groundTempCanvas)
	love.graphics.push()
	love.graphics.translate(self.groundCanvas:getWidth() / 2, self.groundCanvas:getHeight() / 2)
	love.graphics.rotate(self.groundAngle)
	love.graphics.translate(-self.groundCanvas:getWidth() / 2, -self.groundCanvas:getHeight() / 2)
	love.graphics.draw(self.groundCanvas, 0, 0)
	love.graphics.pop()
	love.graphics.setCanvas()
	self.groundCanvas = self.groundTempCanvas
end

function Arena:initLevel()
	print('init level, remove ', #self.Gates, 'Gates', 'next level', self.nextLevelIndex)

	self.boss = nil

	local currentLevel = self:getLevel(self.nextLevelIndex - 1)
	print('init: ' .. currentLevel.name)

	self.angle = currentLevel.angle or self.angle

	-- build objects from data:
	self.Gates = {}
	for i = 1, #currentLevel.Gates do
		local data = currentLevel.Gates[i]

		local entity = data.class(0, 0)
		if data.scale then
			entity.scale = data.scale
		end
		-- default
		entity.x = 0
		entity.y = 0
		--entity.decay = 0
		-- setup the initial place around the arena:
		entity.angle = self.angle
		if data.isBoss then
			self.boss = entity
		end
		-- override or extra
		for k, v in pairs(data) do
			if k ~= 'class' then
				entity[k] = v
			end
		end

		self.world:addEntity(entity)
		table.insert(self.Gates, entity)
	end

	-- level duration
	local loopDuration = 4
	local count = 4
	local rotation = math.pi / 4

	if currentLevel.loop then
		if self.boss then
			-- the boss must die to end the level
			count = math.huge
		else
			count = currentLevel.loop.count or count
		end
		rotation = currentLevel.loop.rotation or rotation
		loopDuration = currentLevel.loop.duration or loopDuration
	end

	self.timer:every('every', loopDuration, function()
		self:sendEvent('BEGIN_LOOP')

		self.timer:tween(1.4, self, { angle = self.angle + rotation }, 'linear', function()
			self:sendEvent('END_LOOP')
			count = count - 1
			if count == 0 then
				self:goToNextLevel()
			end
		end)
	end, count);
end

function Arena:immerged()
	return self.waterRadius > Arena.radius * 0.5
end

function Arena:immerge(duration)
	duration = duration or 8
	local toWaterRadius = Arena.radius * 0.8
	self.timer:tween(1.4, self, { waterRadius = toWaterRadius}, 'linear', function()
		self.waterRadius = toWaterRadius
		self.timer:after(duration, function()
			self.timer:tween(1.4, self, {waterRadius = Arena.radius * 0.5}, 'linear', function()
				self.waterRadius = Arena.radius * 0.5
			end)
		end)
	end)
end

function Arena:sendEvent(event)
	for i = 1, #self.Gates do
		if self.Gates[i].onEvent then
			self.Gates[i]:onEvent(event)
		end
	end
end

function Arena:update(dt)
	Arena.super.update(self, dt)

	if not self.pause then
		self.timer:update(dt)

		local es = self.world:getEntitiesForClassName({ 'Plane', 'UFO', 'Bullet' })
		for i = 1, #es do
			es[i].velocity.x = es[i].velocity.x + self.wind.x
			es[i].velocity.y = es[i].velocity.y + self.wind.y
		end

		es = self.world:getEntitiesForClassName({ 'Grass' })
		for i = 1, #es do
			if es[i].growed then
				--es[i].angle = self.groundAngle
				if math.abs(self.wind.x) + math.abs(self.wind.y) > 0 then
					es[i]:playAnimation('wind', false)
				else
					es[i]:playAnimation('moving', false)
				end
			end
		end
	end


	if G.input:pressed('DEBUG_NEXT_LEVEL') then
		--self:goToNextLevel()
	elseif G.input:pressed('DEBUG_PREVIOUS_LEVEL') then
		--self:goToPreviousLevel()
	end

	if self.boss and self.boss.life == 0 then
		print('boss died')
		self.boss = nil
		self.timer:cancel('every')
		self.timer:after(1, function()
			self:goToNextLevel()
		end)
	end
end

function Arena:addStain(x, y)
	local h = math.rsign()
	local v = math.rsign()

	love.graphics.setCanvas(self.groundCanvas)
	love.graphics.push()
	-- handle the ground rotation
	love.graphics.translate(self.groundCanvas:getWidth() / 2, self.groundCanvas:getHeight() / 2)
	love.graphics.rotate(-self.groundAngle)
	love.graphics.translate(-self.groundCanvas:getWidth() / 2, -self.groundCanvas:getHeight() / 2)

	local gx = self.x - self.groundCanvas:getWidth() / 2
	local gy = self.y - self.groundCanvas:getHeight() / 2
	love.graphics.setColor(255, 255, 255, math.random() * 100 + 155)
	love.graphics.draw(Assets.gfx.stain, x - gx, y - gy, 0, h * 4, v * 4, Assets.gfx.stain:getWidth() / 2, Assets.gfx.stain:getHeight() / 2)

	love.graphics.pop()
	love.graphics.setCanvas()
end

function Arena:draw()
	Arena.super.draw(self)

	local currentLevel = self:getLevel(self.nextLevelIndex - 1)
	local scale = currentLevel.scale or 0.5
	local nextLevel = self:getLevel(self.nextLevelIndex)

	--if self.scale > 1 then
	love.graphics.draw(nextLevel.arena,
		self.x, self.y, self.angle, self.scale * scale, self.scale * scale,
		nextLevel.arena:getWidth() / 2,
		nextLevel.arena:getHeight() / 2)
	--end

	love.graphics.draw(currentLevel.arena,
		self.x, self.y, self.angle, self.scale * 4 * scale, self.scale * 4 * scale,
		currentLevel.arena:getWidth() / 2,
		currentLevel.arena:getHeight() / 2)

	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.circle("fill", self.x, self.y, Arena.radius / 2 + 1)
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.draw(Assets.gfx.ground,
		self.x, self.y, self.groundAngle, 4, 4,
		Assets.gfx.ground:getWidth() / 2,
		Assets.gfx.ground:getHeight() / 2)

	-- grounds additionnal stuff (stain)
	love.graphics.setStencil(function()
	-- TODO optimize:
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.ground,
			self.x, self.y, self.groundAngle, 4, 4,
			Assets.gfx.ground:getWidth() / 2,
			Assets.gfx.ground:getHeight() / 2)
		love.graphics.setShader()
	end)

	--self.groundAngle
	love.graphics.draw(self.groundCanvas, self.x, self.y, self.groundAngle, 1, 1,
		self.groundCanvas:getWidth() / 2,
		self.groundCanvas:getHeight() / 2)

	love.graphics.setStencil()
end

return Arena
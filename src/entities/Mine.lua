local Colorable = require('entities/component/Colorable')
local LifeIndicator = require('entities/component/LifeIndicator')
local Mine = Entity:extend('Mine')
Mine:implement(Colorable)
Mine:implement(LifeIndicator)

Mine.vector = Vector()
Mine.maxLife = 40

function Mine:new(x, y)
	Mine.super.new(self, x, y)
	self._x = x
	self._y = y
	self:colorableNew()
	self:lifeIndicatorNew(Mine.maxLife, 28, 1)
	self.timer = Timer()

	self.hitboxRadius = 24
	self.life = Mine.maxLife

	self.shakes = true

	self.speed = 3

	self.z = 2000
	self.zIncrement = 0

	self.damage = 1

	table.insert(self.collidables, 'Plane')
	table.insert(self.collidables, 'UFO')
	table.insert(self.collidables, 'Mine')

	self.collidable = false

	self.target = {x = 0, y = 0 }

	self.maskEffect = love.graphics.newShader(Shader.maskEffect)

	--self.debug = true
end

function Mine:added()
	Mine.super.added(self)
	self.timer:tween(1.4, self, {z = 1.2, x = self.target.x, y = self.target.y}, 'in-cubic', function()
		self.world.camera:shake(14, 0.2)
	end)
end

function Mine:update(dt)
	Mine.super.update(self, dt)
	self:colorableUpdate(dt)
	self:lifeIndicatorUpdate(dt)
	self.timer:update(dt)
	self.collidable = self.z < 2

--[[
	local arena = self.world.arena
	-- handle the ground rotation
	local gx = arena.x - arena.groundCanvas:getWidth() / 2
	local gy = arena.y - arena.groundCanvas:getHeight() / 2
	self.x = self._x - math.cos(arena.groundAngle) * (arena.x - arena.groundCanvas:getWidth() / 2)
	self.y = self._y - math.sin(arena.groundAngle) * (arena.y - arena.groundCanvas:getHeight() / 2)
	self.x = self.x - gx
	self.y = self.y - gy
	]]--
end

function Mine:hitBy(e)
	if e:is(Mine) then
		self.world:removeEntity(self)
	elseif e:is(Bullet) then
		self:setTint({1, 0, 0, 0.9}, 0.6)
		Mine.super.hitBy(self, e)
		self.showLifeIndicator = 2
	else

		local ratio = 100--e.force or 14
		local ang = math.atan2(self.y - e.y ,  self.x - e.x)
		e.velocity.x = e.velocity.x - math.cos(ang) * ratio
		e.velocity.y = e.velocity.y + math.sin(ang) * ratio
	end
end

function Mine:draw()

	--[[
	local arena = self.world.arena

	-- handle the ground rotation
	local gx = arena.x - arena.groundCanvas:getWidth() / 2
	local gy = arena.y - arena.groundCanvas:getHeight() / 2

	love.graphics.push()
	love.graphics.translate(gx, gy)
	love.graphics.translate(arena.groundCanvas:getWidth() / 2, arena.groundCanvas:getHeight() / 2)
	love.graphics.rotate(arena.groundAngle)
	love.graphics.translate(-arena.groundCanvas:getWidth() / 2, -arena.groundCanvas:getHeight() / 2)
	]]--
	local scale = self.scale
	love.graphics.draw(Assets.gfx.snakeRing, self.x, self.y, 0, scale, scale, 24, 24)

	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.snakeRing, self.x, self.y, 0, scale, scale, 24, 24)
		love.graphics.setShader()
	end

	self:lifeIndicatorDraw()
	Mine.super.draw(self)

--	love.graphics.pop()
end

return Mine
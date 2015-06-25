local HeatSensor = require 'entities/component/HeatSensor'
local Ship = Entity:extend()
Ship:implement(HeatSensor)

function Ship:new(x, y)
	Ship.super.new(self, x , y)
	self:heatSensorNew(0.005 + math.random() * 0.02)--0.5 + math.random() * 0.5)
	self.type = 'ENEMY'
	self.zDistance = Entity.zDistance + math.floor(math.random() * 4)
	self.hitbox = {w = 14, h = 14}
	self.pixel = love.graphics.newImage("assets/ship.png")
	self.timer = Timer()
	self.slowingDown = false
end

function Ship:update(dt)
	Ship.super.update(self, dt)
	self:heatSensorUpdate(dt)
	self.timer:update(dt)
end

function Ship:slowingDown()
	if not self.isSlowingDown then
		self.isSlowingDown = true
		self.timer:after(1, function()
			self.slowingDown = false
		end)
	end
end

function Ship:hit()
	Ship.super.hit(self)
	if self.active == false then
		if math.random() > 0.9 then
			self.world:addEntity(Energy(self.x, self.y))
		end
	end
end

return Ship
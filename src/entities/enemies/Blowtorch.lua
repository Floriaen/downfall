local AnimatedSprite = require('entities/component/AnimatedSprite')
local Blowtorch = Entity:extend('Blowtorch')
Blowtorch:implement(AnimatedSprite)

Blowtorch.vector = Vector()
Blowtorch.hitboxRadius = 40

function Blowtorch:new(x, y)
	Blowtorch.super.new(self, x, y)
	self.hitboxRadius = Blowtorch.hitboxRadius
	
	self.timer = Timer()
	self.speed = 4

	self.hasShadow = false
	self.scale = 2
	
	self.shakes = true

	self.zIncrement = 0
	self.z = 1.2

	self.decay = math.pi

	self:animatedSpriteNew(Assets.gfx.fire, 30, 60)
	self:addAnimation('burning', {{1, 1}, {2, 1}, {3, 1}, {2, 1}, {1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {4, 1}, {5, 1}, {4, 1}, {3, 1}, {2, 1}}, 0.1, 4)
	self:playAnimation('burning')

	self.damage = 4
	
	table.insert(self.collidables, 'UFO')
end	

function Blowtorch:onAnimationComplete(animationName)
	self.hitboxRadius = 0
	self.timer:after(1.4, function()
			self:playAnimation('burning', true)
			self.hitboxRadius = Blowtorch.hitboxRadius
		end)
end

function Blowtorch:hitBy(e)

end

function Blowtorch:update(dt)
	Blowtorch.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
	self.timer:update(dt)

	self.x = self.world.arena.x + math.cos(self.world.arena.angle + self.decay) * Arena.radius * 0.5
	self.y = self.world.arena.y +  math.sin(self.world.arena.angle + self.decay) * Arena.radius * 0.5
end

function Blowtorch:draw()
	local angle = self.decay - math.pi * 1.5
	love.graphics.setColor(255, 255, 255)
	-- base
	love.graphics.draw(Assets.gfx.flameThrower, self.x, self.y, self.world.arena.angle + angle, self.scale * 1.5, self.scale * 1.5, 15, 30)
	-- fire
	if not self:getCurrentAnimation():isPaused() then
		self:animatedSpriteDraw(self.x, self.y, self.world.arena.angle + angle, self.scale * 1.5, self.scale * 1.5, 13, 2)
	end
	Blowtorch.super.draw(self)
end

return Blowtorch
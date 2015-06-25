local AnimatedSprite = require 'entities/component/AnimatedSprite'
local Spikes = Entity:extend('Spikes')
Spikes:implement(AnimatedSprite)

Spikes.vector = Vector()

function Spikes:new(x, y)
	Spikes.super.new(self, x, y)
	self.hitboxRadius = 20
	self.timer = Timer()
	self.speed = 4

	self.hasShadow = false
	self.scale = 2

	self.zIncrement = 0
	self.z = 1.2

	self.decay = math.pi
	self.delay = 0

	self:animatedSpriteNew(Assets.gfx.spikes, 30, 50)
	self:addAnimation('opening', {{1, 1}, {2, 1}, {3, 1}}, 0.14, false)
	self:addAnimation('closing', {{3, 1}, {2, 1}, {1, 1}}, 0.14, false)

	self.damage = 6
	--self.decay = 0
	table.insert(self.collidables, 'UFO')
	self.shakes = true
	--self.hitBack = 60
end	

function Spikes:onAnimationComplete(animationName)
	if animationName == 'closing' then
		self.hitboxRadius = 0
	end
	self.timer:after(2 * 0.8, function()
			if animationName == 'closing' then
				self.hitboxRadius = 20
				self:playAnimation('opening')
			else
				self:playAnimation('closing')
			end
		end)
end

function Spikes:added()
	Spikes.super.added(self)
	self.timer:after(self.delay * 0.8, function()
			self:playAnimation('opening')
		end
	)		
end

function Spikes:hitBy(e)
	local ratio = 60--e.force or 14
	local ang = math.atan2(self.y - e.y ,  self.x - e.x)
	e.velocity.x = e.velocity.x - math.cos(ang) * ratio
	e.velocity.y = e.velocity.y - math.sin(ang) * ratio
end

function Spikes:update(dt)
	Spikes.super.update(self, dt)
	self:animatedSpriteUpdate(dt)
	self.timer:update(dt)

	self.x = self.world.arena.x + math.cos(self.world.arena.angle + self.decay) * Arena.radius * 0.5
	self.y = self.world.arena.y +  math.sin(self.world.arena.angle + self.decay) * Arena.radius * 0.5
end

function Spikes:draw()
	local r = self.decay - math.pi * 1.5

	love.graphics.setColor(255, 255, 255)
	self:animatedSpriteDraw(self.x, self.y, self.world.arena.angle + r, self.scale * 1.5, self.scale * 1.5, 15, 30)
	Spikes.super.draw(self)
end

return Spikes
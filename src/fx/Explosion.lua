local Explosion = Entity:extend('Explosion')

function Explosion:new(x, y)
	Explosion.super.new(self, x, y)
	self.hitboxRadius = 2
--	self.hasShadow = false
	self.timer = Timer()
	self.color = {255, 255, 255, 255}
	self.duration = 0.4
	self.toRadius = 40
	self.delay = 0
end

function Explosion:added()
	--self.radius = self.toRadius
	self.timer:after(self.delay, function()
			self.timer:tween(self.duration, self, {hitboxRadius = self.toRadius}, 'linear', function()
					self.timer:tween(self.duration * 0.5, self, {hitboxRadius = 2}, 'linear', function()
							--	self.timer:after(0.05, function()
							self.world:removeEntity(self)	
							--	end)
						end)
				end)
		end)
	Explosion.super.added(self)
end

function Explosion:update(dt)
	Explosion.super.update(self, dt)
	self.timer:update(dt)
end

function Explosion:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle('fill', self.x, self.y, self.hitboxRadius)
--	love.graphics.setColor(255, 255, 255)
end

return Explosion
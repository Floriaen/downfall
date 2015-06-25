local Gain = Entity:extend('Gain')

function Gain:new(x, y)
	Gain.super.new(self, x, y)
	self.color = {155, 217, 169, 255}
	self.alpha = 255
	self.value = '0'
	self.hasShadow = false
	self.timer = Timer()
	self.hitboxRadius = 0
	self.zDistance = 0
	self.scale = 1
	
	self.zIncrement = 0
	self.timer:tween(1, self, {y = self.y - 200, alpha = 60}, 'linear', function()
			self.world:removeEntity(self)
		end)
end

function Gain:update(dt)	
	Gain.super.update(self, dt)
	self.timer:update(dt)
	self.color[4] = self.alpha
end

function Gain:draw()
	love.graphics.setFont(Font.pressStart18)
	love.graphics.setColor(self.color)
	love.graphics.print(self.value, self.x, self.y, 0, self.scale, self.scale, 20, 10)
	Gain.super.draw(self)
end

return Gain
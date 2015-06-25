local Ground = Entity:extend('Ground')

function Ground:new()
	Ground.super.new(self, 0, 0)
	self.shadow = love.graphics.newCanvas(love.window.getWidth(), love.window.getHeight())
	self.z = 0.2
end

function Ground:update()
	love.graphics.setCanvas(self.shadow)
	self.shadow:clear()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 100)
	local e = nil
	for i = 1, #self.world.entities do
		e = self.world.entities[i]
		if e.hasShadow then
			local decayX = ((e.x * 2) - love.graphics.getWidth()) * 0.06  + e.z * 0.2
			local decayY = ((e.y * 2) - love.graphics.getHeight()) * 0.06 + e.z * 0.2
			love.graphics.ellipse('fill', e.x + decayX, e.y + decayY, e.hitboxRadius, e.hitboxRadius)-- * 0.6, e.hitboxRadius * 0.5)
		end
	end
	love.graphics.setColor(r, g, b, a)
	love.graphics.setCanvas()
end

function Ground:draw()
	love.graphics.draw(self.shadow, 0, 0)
end

return Ground
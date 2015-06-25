local Fire = Entity:extend('Fire')

function Fire:new(x, y)
	Fire.super.new(self, x, y)
	self.hasShadow = false
	self.actions = {
		FIRE_UP = false,
		FIRE_LEFT = false,
		FIRE_RIGHT = false,
		FIRE_DOWN = false
	}
end

function Fire:update(dt)
	Fire.super.update(self, dt)
	local done = true
	for k, v in pairs(self.actions) do
		if not v and G.input:pressed(k) then
			self.actions[k] = true
		end
		done = done and v
	end

	if done then
		self:die()
	end
end

function Fire:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(Font.pressStart26)
	local gap = 100

	love.graphics.print(G.input.binds['FIRE_UP'][1], self.x, self.y - gap, 0, 1, 1, 60)
	love.graphics.print(G.input.binds['FIRE_LEFT'][1], self.x - gap, self.y, 0, 1, 1, 60)
	love.graphics.print(G.input.binds['FIRE_RIGHT'][1], self.x + gap, self.y, 0, 1, 1, 60)
	love.graphics.print(G.input.binds['FIRE_DOWN'][1], self.x, self.y + gap, 0, 1, 1, 60)

	Fire.super.draw(self)
end

return Fire
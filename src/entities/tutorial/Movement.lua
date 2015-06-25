local Movement = Entity:extend('Movement')

function Movement:new(x, y)
	Movement.super.new(self, x, y)
	self.hasShadow = false
	self.actions = {
		GO_UP = false,
		GO_LEFT = false,
		GO_RIGHT = false,
		GO_DOWN = false
	}
end

function Movement:update(dt)
	Movement.super.update(self, dt)
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

function Movement:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(Font.pressStart26)
	local gap = 100
	love.graphics.circle('line', self.x, self.y - gap, 20)
	love.graphics.print(G.input.binds['GO_UP'][1], self.x, self.y - gap, 0, 1, 1, 11, 9)
	love.graphics.circle('line', self.x - gap, self.y, 20)
	love.graphics.print(G.input.binds['GO_LEFT'][1], self.x - gap, self.y, 0, 1, 1, 11, 9)
	love.graphics.circle('line', self.x + gap, self.y, 20)
	love.graphics.print(G.input.binds['GO_RIGHT'][1], self.x + gap, self.y, 0, 1, 1, 11, 9)
	love.graphics.circle('line', self.x, self.y + gap, 20)
	love.graphics.print(G.input.binds['GO_DOWN'][1], self.x, self.y + gap, 0, 1, 1, 11, 9)

	Movement.super.draw(self)
end

return Movement



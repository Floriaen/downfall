local Life = Entity:extend('Life')

function Life:new(x, y)
	Life.super.new(self, x, y)
	self.color = {155, 102, 169, 255}

	-- ui
	self.hasShadow = false	
	self.zDistance = 0
	self.scale = 1
	self.zIncrement = 0
	self.z = 2

	self.timer = Timer()
	self.value = 0
	self.newValue = 0

	self.width = 300
	self.height = 24
end

function Life:update(dt)	
	Life.super.update(self, dt)
	self.timer:update(dt)
	if self.world.player then
		self.newValue = self.width * self.world.player.life / UFO.maxLife
	else
		self.newValue = 0
	end
	self.value = math.lerp(self.value, self.newValue, dt * 2)
end

function Life:draw()
	local value = self.newValue
	local gap = self.value
	local gapColor = {255, 0, 0}

	if self.newValue > self.value then
		value = self.value
		gap = self.newValue
		gapColor = {0, 255, 0}
	end

	-- draw border
	if value > 0 then
		-- gap + 4
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle('line', self.x - 1, self.y - 1, self.width, self.height + 2)
	end

	-- draw gap
	love.graphics.setColor(gapColor)
	love.graphics.rectangle('fill', self.x, self.y, gap, self.height)

	-- draw current
	love.graphics.setColor(self.color)
	love.graphics.rectangle('fill', self.x, self.y, value, self.height)

	-- life number
	--[[
	if value > 50 then
		love.graphics.setFont(Font.pressStart26)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(self.world.player.life, self.x + 4, self.y + 9)
	end
	]]
end

return Life
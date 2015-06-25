local MineDropper = Class:extend('MineDropper')

MineDropper.vector = Vector()

function MineDropper:new(x, y)
	MineDropper.super.new(self, x, y)
	self.timer = Timer()



	self.currentIndex = 1
	self.positions = {
		{ 1, 1 },
		{ 1, -1 },
		{ -1, 1 },
		{ -1, -1 }
	}
	self.mineCount = #self.positions
end

function MineDropper:added()

	local hw = love.graphics.getHeight() / 2
	local hh = love.graphics.getWidth() / 2

	self.positions = table.shuffle(self.positions)
	self.timer:every(1, function()
		local position = self.positions[self.currentIndex]
		local mine = self.world:createEntity(Mine, hw + position[1] * (900 - math.random(100)), hh + position[2] * (900 - math.random(100)))
		mine.target.x = hw + position[1] * (100 - math.random(70))
		mine.target.y = hh + position[2] * (100 - math.random(70))

		-- loop if necessary
		self.currentIndex = self.currentIndex + 1
		if self.currentIndex > #self.positions then
			self.positions = table.shuffle(self.positions)
			self.currentIndex = 1
		end

	end, self.mineCount)
end

function MineDropper:update(dt)
	self.timer:update(dt)
end

return MineDropper
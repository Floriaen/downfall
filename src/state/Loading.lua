local resources = require 'assets/data/resources'
local Loading = State:extend('Loading')

function Loading:new()
	Loading.super.new(self)
	self.width = love.graphics.getWidth() * 0.8
	self.height = 40
end

function Loading:start()
	print('Loading:start')
	self.resourceLoader = ResourceLoader(resources, Assets, function()
			print('switch game')
			Stateswitch(MainScreen)
			--Stateswitch(Settings)
		end)
end

function Loading:stop()	

end

function Loading:update(dt)
	self.resourceLoader:update(dt)
	--	if not loading.finishedLoading then return end
end

function Loading:draw()
--	self.resourceLoader:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('line', 
		love.graphics.getWidth() * 0.1, 
		love.graphics.getHeight() / 2 - self.height / 2, 
		self.width, 
		self.height
	)
	
	love.graphics.rectangle('fill', 
		love.graphics.getWidth() * 0.1, 
		love.graphics.getHeight() / 2 - self.height / 2, 
		self.resourceLoader.percentLoaded * self.width, 
		self.height
	)
end

return Loading
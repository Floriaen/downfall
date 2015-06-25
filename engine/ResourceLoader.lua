local ResourceLoader = Class:extend('ResourceLoader')
local loveLoader = require ('/lib/love-loader/love-loader')

function ResourceLoader:new(resources, resourcesHandler, onResourceLoaderComplete)

	loveLoader.loadedCount = 0
	self.percentLoaded = 0
	
	local resourceCount = 0
	for type, content in pairs(resources) do
		resourcesHandler[type] = {}
		for k, v in pairs(content) do
			resourceCount = resourceCount + 1
			print('load', k, v)
			if type == 'sfx' then
				loveLoader.newSoundData(resourcesHandler[type], k, v)
			elseif type == 'gfx' then
				loveLoader.newImage(resourcesHandler[type], k, v)
			end
		end


		
		--[[
		if k == 'marsh' then
			loveLoader.newSoundData(resourcesHandler.gfx, k, v)
		else
			loveLoader.newImage(resourcesHandler, k, v)
		end
		]]--
	end
	
	loveLoader.resourceCount = resourceCount
	if resourceCount > 0 then
		self.finishedLoader = false
		loveLoader.start(function()
				self.finishedLoader = true
				if onResourceLoaderComplete then
					onResourceLoaderComplete()
				end
			end, print)
	else
		print('no resources')
		self.finishedLoader = true
		if onResourceLoaderComplete then
			onResourceLoaderComplete()
		end
	end
end

function ResourceLoader:update(dt)
	if not self.finishedLoader then
		loveLoader.update() -- You must do this on each iteration until all resources are loaded
		if loveLoader.resourceCount ~= 0 then
			self.percentLoaded = loveLoader.loadedCount / loveLoader.resourceCount 
		end
	end
end

function ResourceLoader:draw()
	if not self.finishedLoader then
		love.graphics.print(("Loader .. %d%%"):format(self.percentLoaded*100), 100, 100)
	end
end

return ResourceLoader
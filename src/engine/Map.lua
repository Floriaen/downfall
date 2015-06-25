local Map = Class:extend()

Map.tileSize = 32

Map.around = {
	{-1, -1}, {0, -1}, {1, -1},
	{-1,  0}, {1,  0},
	{-1,  1}, {0,  1}, {1,  1}
}

function Map:new(width, height)
	self.width = math.floor(width / Map.tileSize)
	self.height = math.floor(height / Map.tileSize)

	self.entities = {}
	for j = 1, self.height do
		self.entities[j] = {}
		for k = 1, self.width do
			self.entities[j][k] = 0;
		end
	end

	self.heatValues = {}
	for j = 1, self.height do
		self.heatValues[j] = {}
		for k = 1, self.width do
			self.heatValues[j][k] = 0;
		end
	end

	self.target = nil

	self.x = 0
	self.y = 0
end

function Map:cleanEntities()
	for j = 1, self.height do
		for k = 1, self.width do
			self.entities[j][k] = 0;
		end
	end
end

function Map:setTarget(target)
	self.target = target;
end

function Map:getHeatValue(tileX, tileY)
	if tileY < 1 or tileY > self.height or tileX < 1 or tileX > self.width then
		return false
	end
	return self.heatValues[tileY][tileX]
end

function Map:getTile(x, y)
	return 1 + math.floor((x - self.x) / Map.tileSize), 1 + math.floor((y - self.y) / Map.tileSize)
end

function Map:getTileCoords(x, y)
	return self.x + (x - 1) * Map.tileSize, self.y + (y - 1) * Map.tileSize
end

function Map:update(dt)
	if not self.target then return end

	for j = 1, self.height do
		--self.heatValues[j] = {}
		for k = 1, self.width do
			local distance = math.floor(math.sqrt((self.target.tile.x - k) * (self.target.tile.x - k) + (self.target.tile.y - j) * (self.target.tile.y - j)));
			local heatValue = distance
			if heatValue > 3 then
				if self.entities[j][k] > 4 then
					heatValue = heatValue + self.entities[j][k]
				end
			end
			self.heatValues[j][k] = heatValue
		end
	end
end

return Map
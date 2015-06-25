local EntityHelper = Entity:extend('EntityHelper')

function EntityHelper:new()
	self.timer = Timer:new()
end

function EntityHelper:spawn(types, settings)
	local x = settings.x or 0
	local y = settings.y or 0
	local radius = settings.radius or 30
	local count = settings.count or 1

	for i = 1, count do
		local px = x + math.rsign() * math.random() * radius
		local py = y + math.rsign() * math.random() * radius

		G.world:createEntity(self:randomChoose(types), px, py)
	end
end

function EntityHelper:spawnCorpse(x, y)
	if G.data.raw.astronauts then
		local countOfDeadAstronauts = #G.data.raw.astronauts
		if countOfDeadAstronauts > 0 then
			local r = math.random(1, countOfDeadAstronauts)
			G.world:createEntity(Corpse, x, y, {firstName = G.data.raw.astronauts[r].firstName})
		end
	end
end

function EntityHelper:spawnWithinTiles(types, settings)
	--self:spawn(types, settings)

	
	local x = settings.x or 0
	local y = settings.y or 0
	local radius = settings.radius or 30
	local count = settings.count or 1

	-- from map fill the available tiles
	local map = G.world.map
	local tiles = map.solidMap
	local tx, ty = map:getTile(x - radius, y - radius)
	local tileRadius = math.ceil((radius * 0.5) / Map.tileSize)

	local availableTiles = {}
	for i = 1, tileRadius do
		for j = 1, tileRadius do
			--print('is solid ', tx + i, ty + j, map:isTileSolid(tx + i, ty + j))
			if not map:isTileSolid(tx + i, ty + j) then
				table.insert(availableTiles, {tx, ty})
				--print('insert', #availableTiles, tx, ty)
			end
		end
	end

	if #availableTiles > 0 then
		for i = 1, count do
			-- random choose an available tile
			local r = math.random(1, #availableTiles)
			local tile = availableTiles[r]
			-- pick up a random location within the tile
			local px, py =  map:getTileCoords(tile[1] + math.random(), tile[2] + math.random())
			G.world:createEntity(self:randomChoose(types), px, py)
		end
	else
		--print('No tiles available for spawn', types)
	end
	
end

function EntityHelper:throwItems(types, settings)
	local x = settings.x or 0
	local y = settings.y or 0
	local count = settings.count or 1
	local layer = settings.layer or 0
	local groundY = settings.groundY or y
	local delay = settings.delay or 0.2
	self.timer:every(delay, function()
		local item = G.world:createEntity(self:randomChoose(types), x, y)
		item.layerPosition = layer
		item.groundY = groundY + math.random() * 20 --+ item.height
		item.gravity = 0.3
		item.velocity.x = math.rsign() * math.random() * 0.5
		item.velocity.y = - 1.8 * math.random()
	end, count)
end

function EntityHelper:update(dt)
	self.timer:update(dt)
end

function EntityHelper:randomChoose(types)
	if #types == 1 then
		return types[1]
	else
		local r = math.random(1, #types)
		return types[r]
	end
	return nil
end

return EntityHelper
local Query = Class:extend()

Query.entities = {}

function Query:getCountOfEntitiesForClassName(classNames)
	local set = table.getSet(classNames)
	local count = 0
	for i = 1, #self.entities do
		local e = self.entities[i]
		if set[e.class_name] then
			count = count + 1
		end
	end
	return count
end

function Query:getEntitiesForClassName(classNames)
	local set = table.getSet(classNames)
	Query.entities = {} -- empty
	for i = 1, #self.entities do
		local e = self.entities[i]
		if set[e.class_name] then
			table.insert(Query.entities, e)
		end
	end
	return Query.entities
end

-- TODO: refactor getEntitiesInCircle / getCountOfEntitiesInCircle / hasAtLeastOneEntityInCircle
function Query:getEntitiesInCircle(x, y, radius, classNames)
	local set = nil
	if classNames and #classNames > 1 then
		set = table.getSet(classNames)
	end

	Query.entities = {}
	for i = 1, #self.entities do
		local e = self.entities[i]
		if not set or set[e.class_name] then
			if e.x and e.y then
				local dx, dy = math.abs(x - e.x), math.abs(y - e.y)
				local distance = math.sqrt(dx * dx + dy * dy)
				if distance < radius then 
					table.insert(Query.entities, e)
				end
			end
		end
	end
	return Query.entities
end

function Query:getCountOfEntities(classNames)
	local count = 0
	local set = nil
	if classNames and #classNames > 0 then
		set = table.getSet(classNames)
	end

	for i = 1, #self.entities do
		local e = self.entities[i]
		if not set or set[e.class_name] then
			count = count + 1
		end
	end
	return count
end

function Query:getCountOfEntitiesInCircle(x, y, radius, classNames)
	local count = 0
	local set = nil
	if classNames and #classNames > 0 then
		set = table.getSet(classNames)
	end

	for i = 1, #self.entities do
		local e = self.entities[i]
		if not set or set[e.class_name] then
			local dx, dy = math.abs(x - e.x), math.abs(y - e.y)
			local distance = math.sqrt(dx * dx + dy * dy)
			if distance < radius then 
				count = count + 1
			end
		end
	end
	return count
end

function Query:hasAtLeastOneEntityInCircle(x, y, radius, classNames)
	local set = nil
	if classNames and #classNames > 1 then
		set = table.getSet(classNames)
	end

	for i = 1, #self.entities do
		local e = self.entities[i]
		if not set or set[e.class_name] then
			local dx, dy = math.abs(x - e.x), math.abs(y - e.y)
			local distance = math.sqrt(dx * dx + dy * dy)
			if distance < radius then 
				return true
			end
		end
	end
	return false
end

return Query
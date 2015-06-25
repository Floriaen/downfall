local Query = require 'engine/component/Query'
local State = Class:extend('State')
State:implement(Query)

State.current = nil

function Stateswitch(class)
	G.logger:write("Stateswitch: "..class.class_name)
	local state = class()
	if state:is(State) then
		if State.current then
			State.current:stop()
		end
		State.current = state
		State.current:start()
	end
end

function State:new()
	self.entities = {}
	self.layers = {}
	self.orderingLayers = {'ENTITIES'}

	self.entitiesToAdd = {}
	self.entitiesToRemove = {}
end

function State:addEntity(e)
	table.insert(self.entitiesToAdd, e)
	return e
end

function State:removeEntity(e)
	for i = 1, #self.entities do
		-- remove only added entity
		if e == self.entities[i] then
			table.insert(self.entitiesToRemove, e)
			break
		end
	end
	return e
end

function State:removeAll()
	print('>>>>>>>>> removeAll')
	self.entities = {}
	self.layers = {}
	self.entitiesToAdd = {}
	self.entitiesToRemove = {}
end

function State:start()

end

function State:stop()
	self:removeAll()
end


function State:restart()
	self:stop()
	self:start()
end

function State:update(dt)
	self.layers = {}
	-- Purge remove entities
	local e = nil

	for _, e in ipairs(self.entitiesToRemove) do
		table.foreach(self.entities, function(k, v) 
				if v == e then
					table.remove(self.entities, k)
					if e.removed then e:removed() end
					e.world = nil
				end
			end)
	end
	self.entitiesToRemove = {}

	for _, e in ipairs(self.entitiesToAdd) do
		table.insert(self.entities, e)
		e.world = self
		if e.added then 
			e:added() 
		end
	end
	self.entitiesToAdd = {}

	for i = 1, #self.entities do
		e = self.entities[i]
		if e.update then
			e:update(dt)
		end

		-- prepare to draw:
		--if not e.onCamera or e:onCamera() then
			local layer = e.layer or 'ENTITIES'
			-- dispatch entities in the right layer
			if not self.layers[layer] then
				self.layers[layer] = {}
			end
			table.insert(self.layers[layer], e)
		--end
	end

	
	for key, layer in pairs(self.layers) do
		table.sort(layer, 
			function(object1, object2)
				if object1.z and object2.z then
					return object1.z < object2.z
				end
				return false
			end
		)
	end
end

function State:draw()
	for i = 1, #self.orderingLayers do
		if self.layers[self.orderingLayers[i]] then
			local layer = self.layers[self.orderingLayers[i]]
			for j = 1, #layer do
				if layer[j].draw then
					love.graphics.setColor(255, 255, 255)
					layer[j]:draw() -- entities
				end
			end
		end
	end
	love.graphics.setColor(255, 255, 255)
end

return State
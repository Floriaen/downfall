local Item = Entity:extend('Item')

Item.lifeDuration = 3.6

function Item:new(x, y)
	Item.super.new(self, x, y)
	self.timer = Timer()

	self.hitboxRadius = 10

	self.angle = 0
	self.damage = 0 -- TODO damage should be negative gain
	self.gain = 0

	table.insert(self.collidables, 'UFO')
end

function Item:added()
	Item.super.added(self)
	self.timer:after(self.lifeDuration, function()
		self:die()
		local explosion = self.world:createEntity(Explosion, self.x, self.y)
		explosion.radius = 3
		explosion.color = {128, 213, 255}
	end)
end

function Item:update(dt)
	Item.super.update(self, dt)
	self.timer:update(dt)
	self.angle = self.angle + dt

	-- UFO attraction
	local position = Vector(self.x, self.y)
	UFO.vector.x = State.current.player.x
	UFO.vector.y = State.current.player.y
	local offset = 	position - UFO.vector
	local distance = offset:len()
	if distance < 100 then
		offset:normalize_inplace()
		self.velocity.x = - offset.x * 100
		self.velocity.y = - offset.y * 100
	end

	-- Bounds: (TODO refactor this)
	local radius = Arena.radius * 0.5
	local center = Vector(self.world.arena.x, self.world.arena.y)
	local offset = 	position - center
	local distance = offset:len()

	if (radius < distance) then
		local direction = offset / distance
		position = center + direction * radius

		self.x = position.x
		self.y = position.y
	end
end

function Item:hitBy(e)
	Item.super.hitBy(self, e)
	-- e is UFO instance
	self:die()

	-- TODO move to player
	local gain = self.gain
	if (e.life + gain) > UFO.maxLife then
		gain = UFO.maxLife - e.life
		if gain < 0 then
			gain = 0
			e.life = UFO.maxLife -- current life is more than the max authorized!
		end
	end

	if gain > 0 then
		e.life = e.life + gain

		if e.life > UFO.maxLife then
			e.life = UFO.maxLife
		end

		-- display the gain
		local gainUI = self.world:createEntity(Gain, self.x, self.y)
		gainUI.value = '+' .. self.gain
	end
end

function Item:draw()
	Item.super.draw(self)
end

return Item
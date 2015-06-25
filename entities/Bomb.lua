local Bomb = Entity:extend('Bomb')

function Bomb:new(x, y)
	Bomb.super.new(self, x, y)
	self.hitboxRadius = 14

	self.zIncrement = 0
	self.z = 1.5

	self.timer = Timer()
	self.flipX = math.random() > 0.5 and 1 or -1
end

function Bomb:added()
	Bomb.super.added(self)
	self.timer:after(2, function()
		self:die()
	end)
end

function Bomb:removed()
	Bomb.super.removed(self)
	-- explosion
	self.world:createEntity(BombExplosion, self.x, self.y)
end

function Bomb:update(dt)
	Bomb.super.update(self, dt)
	self.timer:update(dt)
end

function Bomb:draw()
	love.graphics.draw(Assets.gfx.bomb, self.x, self.y, 0, self.flipX * 2, 2, Assets.gfx.bomb:getWidth() / 2, Assets.gfx.bomb:getHeight() / 2)
	Bomb.super.draw(self)
end

return Bomb


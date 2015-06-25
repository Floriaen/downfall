local Kamikaze = Plane:extend('Kamikaze')

function Kamikaze:new(x, y)
	Kamikaze.super.new(self, x, y)
	
end

function Kamikaze:hitBy(e)
	-- kill the player, one shot!
	if e:is(UFO) then
		self.life = 0
		e.life = 0
	else
		Kamikaze.super.hitBy(self, e)
	end
end

function Kamikaze:draw()
	self.scale = 1.5
	love.graphics.draw(Assets.gfx.kamikaze, self.x, self.y, self.angle + math.pi / 2, self.scale, self.scale, 12, 11)

	if self.colorableDuration > 0 then
		self.maskEffect:send('colorFill', self.color)
		love.graphics.setShader(self.maskEffect)
		love.graphics.draw(Assets.gfx.kamikaze, self.x, self.y, self.angle + math.pi / 2, self.scale, self.scale, 12, 11)
		love.graphics.setShader()
	end
	
	Plane.super.draw(self)
end

return Kamikaze
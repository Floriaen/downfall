local BulletParticles = Class:extend('BulletParticles')

function BulletParticles:new(x, y)
	self.particles = love.graphics.newParticleSystem(Assets.gfx.bulletParticle, 100)
	self.particles:setParticleLifetime(0.6)
	self.particles:setEmitterLifetime(3)
	self.particles:setEmissionRate(200)
	--self.particles:setSizes(0.8, 1.8)
	self.particles:setColors(200, 200, 10, 255)
	--self.particles:setLinearAcceleration(60, 60, 200, 200)

	--self.particles:stop()
end

function BulletParticles:update(dt)
	self.particles:update(dt)
end

function BulletParticles:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.particles)
end

return BulletParticles
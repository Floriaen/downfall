local LifeIndicator = Class:extend()

LifeIndicator.color = {255, 165, 0}

function LifeIndicator:lifeIndicatorNew(life, radius, lineWidth)
	self.lifeIndicatorMaxLife = life
	self.lifeIndicatorFromAngle = 0
	self.lifeIndicatorToAngle = 0
	self.showLifeIndicator = 0
	self.lifeIndicatorRadius = radius
	self.lifeIndicatorLineWidth = lineWidth or 1
end

function LifeIndicator:lifeIndicatorUpdate(dt)
	if self.showLifeIndicator > 0 then
		self.showLifeIndicator = self.showLifeIndicator - dt * 4
		local angle = self.life / self.lifeIndicatorMaxLife * math.pi * 2
		self.lifeIndicatorToAngle = self.lifeIndicatorFromAngle + angle
	end
end

function LifeIndicator:lifeIndicatorDraw(x, y)
	local x = x or self.x
	local y = y or self.y
	if self.showLifeIndicator > 0 then
		love.graphics.setLineWidth(self.lifeIndicatorLineWidth)
		love.graphics.setColor(LifeIndicator.color)
		love.graphics.drawArc(x, y, self.lifeIndicatorRadius, self.lifeIndicatorFromAngle, self.lifeIndicatorToAngle, 200)
	end
end

return LifeIndicator
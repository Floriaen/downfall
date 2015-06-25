-- TODO use Time.tween for this stuff
local Colorable = Class:extend()

function Colorable:colorableNew()
	self.color = {1, 1, 1, 1}
	self.colorStep = {1, 1, 1, 1}
		
	self.colorableDuration = 0
	self.colorableDurationStep = 0
	
	self.colorableCount = 1
	
	--self.timer = Timer()
end

function Colorable:colorableUpdate(dt)
	--self.timer:update()
	if self.colorableDuration > 0 then
		local c = 1 - self.colorableDuration / self.colorableDurationStep
		local na = math.lerp(self.color[4] or 1, 0, c)

		self.color = {self.color[1], self.color[2], self.color[3], na}
		
		self.colorableDuration = self.colorableDuration - dt
	else
		if self.colorableCount <= 1 then
			self.colorableDuration = 0
		else
			self.colorableCount = self.colorableCount - 1
			self.colorableDuration = self.colorableDurationStep
			self.color = self.colorStep
		end
	end
end

function Colorable:setTint(color, duration, count)
	self.colorableDurationStep = duration
	self.colorableDuration = self.colorableDurationStep
	self.colorStep = color
	self.color = self.colorStep
	self.colorableCount = count or 1
	--[[
	if self.timer:isClear() then
		self.timer:tween(duration, self, {color}, 'linear', function()
				self.timer:clear()
				end)
	end
	]]--
	
end

return Colorable
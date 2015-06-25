local AnimatedSprite = Class:extend()

function AnimatedSprite:animatedSpriteNew(sprite, width, height)
	
	self.spriteSheet = Spritesheet(sprite, width, height)
	self.animations = {}
	self.currentAnimationName = nil
	self.onAnimationCompleteClosure = createClosure(self, 'onAnimationComplete')

end

function AnimatedSprite:onAnimationComplete(animationName)
	-- hook
end

function AnimatedSprite:animatedSpriteDraw(...)
	local animation = self:getCurrentAnimation()
	if animation then
		animation:draw(...)
	end
end

function AnimatedSprite:playAnimation(name, reset)
	if reset ~= false or self.currentAnimationName ~= name then
		reset = true
		
	end
	self.currentAnimationName = name
	local animation = self:getCurrentAnimation()
	if animation then
	--	animation.loop = animation.loopCount
		animation:play(reset)
	end
end

function AnimatedSprite:getCurrentAnimation()
	if self.currentAnimationName then
		return self.animations[self.currentAnimationName]
	end
	return nil
end

function AnimatedSprite:addAnimation(name, frames, delay, loop)
	self.animations[name] = self.spriteSheet:createAnimation(name, self.onAnimationCompleteClosure)
	self.animations[name]:addFrames(frames)
	self.animations[name].delay = delay
	if loop == true or loop == false then
		self.animations[name].loop = loop
	else
		self.animations[name].loop = false
		self.animations[name].initialLoopCount = loop
		self.animations[name].loopCount = loop
	end
	self.animations[name].playing = false
end

function AnimatedSprite:animatedSpriteUpdate(dt)
	local animation = self:getCurrentAnimation()
	if animation then
		animation:update(dt)
	end
end

return AnimatedSprite
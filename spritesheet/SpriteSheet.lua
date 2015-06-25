local SpriteSheet = Class:extend('SpriteSheet')

function SpriteSheet:new(img, w, h)
	if type(img)=='string' then
		img=love.graphics.newImage(img)
	end
	self.img = img
	self.w = w
	self.h = h
	self.imgw = img:getWidth()
	self.imgh = img:getHeight()
	self.Animations={}
end

function SpriteSheet:createAnimation(name, onAnimationComplete)
	local a=Animation(self, name, onAnimationComplete)
	return a
end

return SpriteSheet
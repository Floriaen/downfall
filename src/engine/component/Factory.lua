local Factory = Class:extend()

function Factory:createEntity(className, x, y)
	--print('Factory:createEntity', className)
	if className then
		local e = className(x, y)
		
		if e then
			e.world = self
			self:addEntity(e)
			return e
		else
			print('no class found for '..className)
		end
	else
		print('no classname found')
	end
	return nil
end

return Factory
local DebugHelper = Class:extend('DebugHelper')

function DebugHelper:new()
	Monocle.new(
		{
			isActive = true,
			--filesToWatch = {'main.lua'},
			debugToggle = '<',
			customColor = {255, 255, 225, 255},
			customPrinter = true,
			printerPreffix = '[Monocle] '
		}
	)
	self:setDebugWindow()
end

function DebugHelper:setDebugWindow()
	Monocle.watch('FPS:', function()
			return love.timer.getFPS()
		end)

	Monocle.watch('Mem(kB):', function()
			return math.floor(collectgarbage("count"))
		end)
	
	Monocle.watch('UFO in bounds:', function()
			if State.current.player then
				return State.current.player.inBounds and 1 or 0
			end
			return 'nil'
		end)

	Monocle.watch('Entities:', function()
			if State.current and State.current.entities then
				return #State.current.entities
			end
			return 0
		end)
	
	Monocle.watch('Camera zoom:', function()
			if State.current and State.current.camera then
				return State.current.camera.scale
			end
			return 0
		end)
	
	Monocle.watch('UFO:', function()
			if State.current and State.current.player then
				return 'x='..math.floor(State.current.player.x)..' y='..math.floor(State.current.player.y) .. ' \\/ = '..State.current.player.life
			end
			return 0
		end)
	
end

function DebugHelper:update(dt)
	Monocle.update(dt)
end

function DebugHelper:draw()
	love.graphics.push()
	love.graphics.setFont(Font.system)
	love.graphics.translate(0, 0)--love.graphics.getHeight() - 140)
	Monocle.draw()
	love.graphics.pop()
end

return DebugHelper
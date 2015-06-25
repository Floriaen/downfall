local Input = Class:extend('Input')

function Input:new()
	self.prev_state = {}
	self.state = {}
	self.binds = {}
	self.joysticks = love.joystick.getJoysticks()
	self.vibrate = {left = 0, right = 0}
end

function Input:bind(key, action)
	if not self.binds[action] then self.binds[action] = {} end
	table.insert(self.binds[action], key)
end

function Input:pressed(action)
	for _, key in ipairs(self.binds[action]) do
		if self.state[key] and not self.prev_state[key] then
			return true
		end
	end
end

function Input:released(action)
	for _, key in ipairs(self.binds[action]) do
		if self.prev_state[key] and not self.state[key] then
			return true
		end
	end
end

local key_to_button = {mouse1 = 'l', mouse2 = 'r', mouse3 = 'm', wheelup = 'wu', wheeldown = 'wd', mouse4 = 'x1', mouse5 = 'x2'}
local gamepad_to_button = {fdown = 'a', fup = 'y', fleft = 'x', fright = 'b', back = 'back', guide = 'guide', start = 'start',
	leftstick = 'leftstick', rightstick = 'rightstick', l1 = 'leftshoulder', r1 = 'rightshoulder',
	dpup = 'dpup', dpdown = 'dpdown', dpleft = 'dpleft', dpright = 'dpright'}
local axis_to_button = {leftx = 'leftx', lefty = 'lefty', rightx = 'rightx', righty = 'righty', l2 = 'triggerleft', r2 = 'triggerright'}

function Input:down(action)
	for _, key in ipairs(self.binds[action]) do
		if (love.keyboard.isDown(key) or love.mouse.isDown(key_to_button[key] or '')) then
			return true
		end

		if self.joysticks[1] then
			--print(self.joysticks[1]:isGamepadDown("a"))
			if axis_to_button[key] then
				return self.state[key]
			elseif gamepad_to_button[key] then
				if self.joysticks[1]:isGamepadDown(gamepad_to_button[key]) then
					return true
				end
			end
		end
	end
end

function Input:unbind(key)
	for action, keys in pairs(self.binds) do
		for i = #keys, 1, -1 do
			if key == self.binds[action][i] then
				table.remove(self.binds[action], i)
			end
		end
	end
end

function Input:unbindAll()
	self.binds = {}
end

local copy = function(t1)
	local out = {}
	for k, v in pairs(t1) do out[k] = v end
	return out
end

function Input:update(dt)
	self.prev_state = copy(self.state)
	if self.joysticks[1] then
		if self.vibrate.right > 0.01 or self.vibrate.left > 0.01 then
			self.vibrate.right = math.lerp(self.vibrate.right, 0, dt * 3)
			self.vibrate.left = math.lerp(self.vibrate.left, 0, dt * 3)
			self.joysticks[1]:setVibration(self.vibrate.left, self.vibrate.right)
		else
			self.vibrate.right = 0
			self.vibrate.left = 0
		end
	end
end

function Input:keypressed(key)
	self.state[key] = true
end

function Input:keyreleased(key)
	self.state[key] = false
end

local button_to_key = {l = 'mouse1', r = 'mouse2', m = 'mouse3', wu = 'wheelup', wd = 'wheeldown', x1 = 'mouse4', x2 = 'mouse5'}

function Input:mousepressed(button)
	self.state[button_to_key[button]] = true
end

function Input:mousereleased(button)
	self.state[button_to_key[button]] = false
end

local button_to_gamepad = {a = 'fdown', y = 'fup', x = 'fleft', b = 'fright', back = 'back', guide = 'guide', start = 'start',
	leftstick = 'leftstick', rightstick = 'rightstick', leftshoulder = 'l1', rightshoulder = 'r1',
	dpup = 'dpup', dpdown = 'dpdown', dpleft = 'dpleft', dpright = 'dpright'}

function Input:gamepadpressed(joystick, button)
	self.state[button_to_gamepad[button]] = true 
end

function Input:gamepadreleased(joystick, button)
	self.state[button_to_gamepad[button]] = false
end

local button_to_axis = {leftx = 'leftx', lefty = 'lefty', rightx = 'rightx', righty = 'righty', triggerleft = 'l2', triggerright = 'r2'}

function Input:gamepadaxis(joystick, axis, newvalue)
	self.state[button_to_axis[axis]] = newvalue
end

function Input:vibration(left, right)
	self.vibrate.left = left
	self.vibrate.left = right
end

return Input

local Factory = require'engine/component/Factory'
local Query = require'engine/component/Query'

local Game = State:extend('Game')
Game:implement(Factory)
Game:implement(Query)

Game.speedRatio = 1
Game.ufoDamageRatio = 1

function Game:new()
	Game.super.new(self)
	self.orderingLayers = { 'ENTITIES' }
	self.arena = nil
	self.gt = 0
	self.scene = love.graphics.newCanvas()
	self.countDown = 10
	self.state = 'LOADING'
	self.timer = Timer()
	self.pause = false

	--self.inputModel = InputModel()
	--self.controller = KeyboardController(inputModel)

	self.poly = love.graphics.newShader(Shader.poly)
	self.mainSfx = love.audio.newSource(Assets.sfx.determined)
	self.mainSfx:setLooping(true)

	self.explode = { x = 0, y = 0, power = 1, time = 0 }

	self.shockwaves = {}

	Options()
end

function Game:changeBackgroundMusic(name)
	self.mainSfx:stop()
	self.mainSfx = love.audio.newSource(Assets.sfx[name])
	self.mainSfx:setLooping(true)
	self.mainSfx:play(0.8)
end

function Game:stop()
	self:restoreLevelBackup()
	Game.super.stop(self)
	self.mainSfx:stop()
	loveframes.SetState("")
end

function Game:start()
	self:initControls()

	self.arena = self:createEntity(Arena, love.window.halfWidth, love.window.halfHeight)
	self.arena.decorum = true
	self.ground = self:createEntity(Ground, love.window.halfWidth, love.window.halfHeight)
	self.ground.decorum = true

	self.bulletParticles = self:createEntity(BulletParticles)

	for i = 1, 80 do
		local ax = (love.window.halfWidth)
		local ay = (love.window.halfHeight)
		local rx, ry = math.randomInCircle()

		local x = ax + rx * Arena.radius * 0.45
		local y = ay + ry * Arena.radius * 0.45
		local grass = self:createEntity(Grass, x, y - 10)
		grass.z = grass.z + ry / 100

		local depth = 1 - (rx * rx + ry * ry)
		grass.decay = 3 * (1 - depth) -- appear first from middle to the edges
		grass.color = { 100 + 155 * depth, 100 + 155 * depth, 100 + 155 * depth } -- lighter in the middle
	end

	self.player = self:createEntity(UFO, love.window.halfWidth, love.window.halfHeight)

	self.life = Life((love.graphics.getWidth() - 400) / 2, love.graphics.getHeight() - 60)
	self.life.width = 400
	self.life.world = self

	self.camera = Camera({ follow_style = 'screen', target = self.arena, lerp = 0.3 })

	self.pulse = love.graphics.newShader('assets/shader/pulse.glsl')
	self.arena.waterRadius = Arena.radius * 0.5

	self.state = 'RUNNING'

--	self.mainSfx:play(0.8)

	self.shadow = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function Game:initControls()
	-- keyboard
	G.input:bind('right', 'FIRE_RIGHT')
	G.input:bind('left', 'FIRE_LEFT')
	G.input:bind('up', 'FIRE_UP')
	G.input:bind('down', 'FIRE_DOWN')
	-- game controller
	G.input:bind('fright', 'FIRE_RIGHT')
	G.input:bind('fleft', 'FIRE_LEFT')
	G.input:bind('fup', 'FIRE_UP')
	G.input:bind('fdown', 'FIRE_DOWN')

	-- keyboard
	G.input:bind(' ', 'SPECIAL')
	-- game controller
	G.input:bind('r1', 'SPECIAL')

	-- keyboard
	G.input:bind('d', 'GO_RIGHT')
	G.input:bind('q', 'GO_LEFT')
	G.input:bind('z', 'GO_UP')
	G.input:bind('s', 'GO_DOWN')

	-- qwerty support
	G.input:bind('a', 'GO_LEFT')
	G.input:bind('w', 'GO_UP')

	-- controller
	G.input:bind('dpright', 'GO_RIGHT')
	G.input:bind('dpleft', 'GO_LEFT')
	G.input:bind('dpup', 'GO_UP')
	G.input:bind('dpdown', 'GO_DOWN')

	G.input:bind('r', 'DEBUG')
	G.input:bind('p', 'DEBUG_PREVIOUS_LEVEL')
	G.input:bind('m', 'DEBUG_NEXT_LEVEL')
	G.input:bind('b', 'DEBUG_PAUSE')

	G.input:bind(' ', 'CONTINUE')
end

function Game:gameOver()
	self.arena.angle = 0
	-- backup...
	self:backupLevel()
	-- ... and replace
	self.arena.levels[self.arena.nextLevelIndex - 2] = {
		name = '', -- no name (death)
		arena = Assets.gfx.alienwall,
		Gates = {}
	}

	self.arena:goToPreviousLevel(function()
		self.timer:after(0.2, function()
			-- remove all enemies and items:
			for i = 1, #self.entities do
				local e = self.entities[i]
				if not e.decorum then
					if not e.die then
						print('can\'t die', e.class_name)
					else
						e:die()
					end
				end
			end

			self.arena.timer:clear() -- clear all running timer
			self.arena.waterRadius = Arena.radius * 0.5 -- TODO should be progressive
			self.arena.timer:cancel('every')

			self.countDown = 10
			self.state = 'GAME_OVER'
			-- restart after 10 seconds
			self.timer:every('restarting', 1, function()
				self.countDown = self.countDown - 1
				if self.countDown == 0 then
					if self.state == 'GAME_OVER' then -- TODO secury ?
						Stateswitch(MainScreen)
					end
				end
			end, 10)
		end)
	end)
end

function Game:exploding(x, y)
	local shockwave = love.graphics.newShader(Shader.shockwave)
	table.insert(self.shockwaves, { x = x, y = y, time = 0, shockwave = shockwave })
end

function Game:update(dt)

	if G.input:pressed('DEBUG_PAUSE') then
		self.pause = not self.pause
	end

	if self.state == 'GAME_OVER' then
		self.pause = false
	end

	if self.pause then
		return
	end

	Game.super.update(self, dt)
	self.camera:update(dt)
	self.life:update(dt)
	self.timer:update(dt)

	if G.input:pressed('DEBUG') then
		self:restart()
	end

	self.gt = self.gt + dt

	if self.explode.power > 1 then
		self.explode.time = self.explode.time + dt
	end

	if self.arena:immerged() then
		self.pulse:send("time", self.gt)
		self.pulse:send("width", love.graphics.getWidth())
		self.pulse:send("height", love.graphics.getHeight())
		Game.speedRatio = math.lerp(Game.speedRatio, 0.92, dt)
		Game.ufoDamageRatio = 0.5

		-- remove bullets in water:
		local bullets = self:getEntitiesForClassName({ 'Bullet' })
		for i = 1, #bullets do
			self:removeEntity(bullets[i])
		end
	else
		Game.ufoDamageRatio = 1
		Game.speedRatio = math.lerp(Game.speedRatio, 1, dt * 10)
	end

	if self.state == 'GAME_OVER' then
		if G.input:pressed('CONTINUE') then
			self:continue()
		end
	end

	-- update or remove shockwaves
	local temp = {}
	for i = 1, #self.shockwaves do
		if self.shockwaves[i].time < 2 then
			self.shockwaves[i].time = self.shockwaves[i].time + dt / 4
			table.insert(temp, self.shockwaves[i])
		end
	end
	self.shockwaves = temp
end

function Game:backupLevel()
	self.arena.tempLevel = {
		self.arena.nextLevelIndex - 2,
		self.arena.levels[self.arena.nextLevelIndex - 2]
	}
end

function Game:restoreLevelBackup()
	if self.arena.tempLevel then
		local index = self.arena.tempLevel[1]
		local level = self.arena.tempLevel[2]
		self.arena.levels[index] = level

		self.arena.tempLevel = nil
	end
end

function Game:continue()
	self.state = 'RUNNING'
	self.timer:cancel('restarting')
	self.coutDown = 10 -- reinitialize the countdown
	Game.speedRatio = 1
	-- TODO fix the bug of 2 players...
	-- spawn a new player:
	print(self.player.life)
	self.player = self:createEntity(UFO, love.window.halfWidth, love.window.halfHeight)
	self.arena:goToNextLevel(function()
		self:restoreLevelBackup()
	end)
end

function Game:draw()
	self.camera:attach()

	self.scene:clear()
	love.graphics.setCanvas(self.scene)
	Game.super.draw(self)
	love.graphics.setCanvas()

	-- shadow
	self.shadow:clear()
	love.graphics.setCanvas(self.shadow)

	local shadowRange = self.arena.nextLevelIndex - math.random(6)
	if shadowRange > 0 then
		shadowRange = 0
	end

	self.poly:send("lightPosition", { love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0 })
	self.poly:send("lightRange", love.graphics.getWidth() * (0.8 + shadowRange / 100))
	self.poly:send("lightColor", { 1, 1, 1 })
	self.poly:send("lightSmooth", 0.98)
	self.poly:send("lightGlow", { 4, 3 })
	--self.poly:send("lightAngle", 3)

	love.graphics.setShader(self.poly)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle('fill', love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.graphics.getWidth() * (0.8 + shadowRange / 100))
	love.graphics.setShader()
	love.graphics.setCanvas()

	-- process the shockwaves:
	if #self.shockwaves > 0 then
		local tempCanvas = love.graphics.newCanvas()
		for i = 1, #self.shockwaves do
			local s = self.shockwaves[i]
			s.shockwave:send("center", { s.x / love.graphics.getWidth(), s.y / love.graphics.getHeight() })
			s.shockwave:send("time", s.time)
			s.shockwave:send("shockParams", { 10.0, 0.4, 0.1 })

			love.graphics.setShader(s.shockwave)
			love.graphics.draw(self.scene)
			love.graphics.setShader()
		end
		love.graphics.draw(tempCanvas)
	else
		love.graphics.draw(self.scene)
	end

	love.graphics.setBlendMode("multiplicative")
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.shadow)
	love.graphics.setBlendMode("alpha")

	if self.arena.waterRadius > Arena.radius * 0.5 then
		if not self.arena.movementLocked then
			love.graphics.setStencil(function()
				love.graphics.circle("fill", self.arena.x, self.arena.y, self.arena.waterRadius)
			end)
			love.graphics.setShader(self.pulse)
			love.graphics.draw(self.scene)
			love.graphics.setShader()
			love.graphics.setStencil()

			love.graphics.setColor(100, 100, 255, 50)
			love.graphics.circle('line', self.arena.x, self.arena.y, self.arena.waterRadius)
		end
	end
	self.camera:detach()

	if self.state ~= 'GAME_OVER' then
		self.life:draw()

		love.graphics.setFont(Font.pressStart14)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(self.arena:getCurrentLevelName(), love.graphics.getWidth() - 320, 20, 300, "right")
	end

	if self.state == 'GAME_OVER' then

		love.graphics.setColor(0, 0, 0, 40)
		love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(Font.pressStart26)
		love.graphics.printf('Continue?', 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
		love.graphics.printf(self.countDown, 0, love.graphics.getHeight() / 2 + 22, love.graphics.getWidth(), "center")

	elseif self.pause then
		loveframes.SetState("options")

		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(Font.pressStart26)
		love.graphics.printf('Pause', 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
	else
		loveframes.SetState("")
	end
end

return Game
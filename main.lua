--require('lib/lovedebug')

loveframes = require("lib.loveframes") -- TODO why using lib/loveframes is causing an issue?

require('lib/helper/math')
require('lib/helper/table')
require('lib/graphics')
require('lib/class')

Class = require('lib/classic')
Logger = require('lib/Logger')

gaussian = require('gaussianblur/gaussianblur')

Vector = require('lib/hump/vector')
Timer = require('lib/timer')
Camera = require('lib/hump/camera')

G = {
	vector = Vector()
}
G.logger = Logger('enchained', 'error.log')



Monocle = require('lib/Monocle')

Animation = require "lib/spritesheet/Animation"
Spritesheet = require "lib/spritesheet/SpriteSheet"

ResourceLoader = require('engine/ResourceLoader')
Input = require('engine/Input')
DebugHelper = require('helper/DebugHelper')

State = require('engine/State')
Loading = require('state/Loading')
Settings = require('state/Settings')
MainScreen = require('state/MainScreen')
Game = require('state/Game')

Entity = require('engine/Entity')
Arena = require('decorum/Arena')
Ground = require('decorum/Ground')

UFO = require('entities/UFO')

Bullet = require('entities/Bullet')
Bomb = require('entities/Bomb')
Ball = require('entities/Ball')

Nuke = require('entities/Nuke')

Plane = require('entities/enemies/Plane')
Kamikaze = require('entities/enemies/Kamikaze')
AngelFace = require('entities/enemies/AngelFace')
Shark = require('entities/enemies/Shark')
Gate = require('entities/enemies/Gate')
Spikes = require('entities/enemies/Spikes')
Blowtorch = require('entities/enemies/Blowtorch')
Lazer = require('entities/enemies/Lazer')
Ring = require('entities/enemies/Ring')
Snake = require('entities/enemies/Snake')
Tower = require('entities/enemies/Tower')
Fireball = require('entities/enemies/Fireball')

Mine = require('entities/Mine')
MineDropper = require('entities/MineDropper')
TeleportTarget = require('entities/TeleportTarget')

Item = require('entities/pill/Item')
Energy = require('entities/pill/Energy')
Teleport = require('entities/pill/Teleport')
FirePill = require('entities/pill/FirePill')
WaterPill = require('entities/pill/WaterPill')

Rock = require('entities/Rock')
Grass = require('entities/Grass')

Explosion = require('fx/Explosion')
BombExplosion = require('fx/BombExplosion')
BulletParticles = require('fx/BulletParticles')

-- tutorial
Movement = require('entities/tutorial/Movement')
Fire = require('entities/tutorial/Fire')


Gain = require('ui/Gain')
Life = require('ui/Life')
Options = require('ui/Options')

Assets = {}
Font =  {
	system = love.graphics.getFont(),
	default = love.graphics.newFont('assets/font/upheavtt.ttf', 18),
	pressStart14 = love.graphics.newFont('assets/font/press-start-2p.regular.ttf', 14),
	pressStart18 = love.graphics.newFont('assets/font/press-start-2p.regular.ttf', 18),
	pressStart26 = love.graphics.newFont('assets/font/press-start-2p.regular.ttf', 26),
	pressStart42 = love.graphics.newFont('assets/font/press-start-2p.regular.ttf', 42)
}
Shader = {
	maskEffect = 'assets/shader/mask.glsl',
	poly = 'assets/shader/polyShadow.glsl',
	--fishEye = 'assets/shader/fisheye.glsl',
	shockwave = 'assets/shader/shockwave.glsl'
}

function love.load()
	G.logger:write("love.loading... ", false)
	if arg[#arg] == "-debug" then require("mobdebug").start() end

	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.window.halfWidth = love.window.getWidth() * 0.5
	love.window.halfHeight = love.window.getHeight() * 0.5

	gaussian.init()

	G.input = Input()
	G.debugHelper = DebugHelper()

	Stateswitch(Loading)
	--Entity.debug = true
	G.logger:write("done")
end

function love.update(dt)
	State.current:update(dt)
	G.input:update(dt)
	G.debugHelper:update(dt)

	loveframes.update(dt)
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	State.current:draw()
	love.graphics.setColor(255, 255, 255)
	G.debugHelper:draw()

	loveframes.draw()
end

function love.quit()
	G.logger:write("Level")
	G.logger:close()
end

function love.keypressed(key)
	if key == "escape" then
		--love.event.quit()
		State.current.pause = not State.current.pause
	end
	G.input:keypressed(key)
	loveframes.keypressed(key, unicode)
end

function love.keyreleased(key)
	G.input:keyreleased(key)
	loveframes.keyreleased(key)
end

function love.mousepressed(x, y, button)
	G.input:mousepressed(button)
	loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	G.input:mousereleased(button)
	loveframes.mousereleased(x, y, button)
end

function love.gamepadpressed(joystick, button)
	G.input:gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
	G.input:gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, newvalue)
	G.input:gamepadaxis(joystick, axis, newvalue)
end

function love.textinput(text)
	loveframes.textinput(text)
end
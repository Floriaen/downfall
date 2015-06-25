return {

	{
		name = 'Test',
		arena = Assets.gfx.arena2,
		loop = {
			duration = 100
		},
		Gates = {

			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 1,
				spawnClass = Fireball
			}
		}
	},

	{
		name = 'Fireball',
		arena = Assets.gfx.arena2,
		loop = {
			count = 10,
			rotation = 0,
			duration = 4
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi * 2,
				spawnCount = 1,
				spawnClass = Fireball
			},
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 3,
				delay = 1
			},
		}
	},
	{
		name = 'Move',
		arena = Assets.gfx.arena1,
		angle = 0, -- keep elements as is
		loop = {
			rotation = 0
		},
		Gates = {
			{
				class = Movement,
				isBoss = true,
				x = love.graphics.getWidth() / 2,
				y = love.graphics.getHeight() / 2
			}
		}
	},
	{
		name = 'Fire',
		arena = Assets.gfx.arena1,
		angle = 0, -- keep elements as is
		loop = {
			rotation = 0
		},
		Gates = {
			{
				class = Fire,
				isBoss = true,
				x = love.graphics.getWidth() / 2,
				y = love.graphics.getHeight() / 2
			}
		}
	},
	{
		name = 'Tower Defense',
		arena = Assets.gfx.arena1,
		Gates = {
			{
				class = Tower,
				isBoss = true,
				x = love.graphics.getWidth() / 2,
				y = love.graphics.getHeight() / 2
			},
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 3,
				delay = 1
			},
			{
				class = Gate,
				decay = 3 * math.pi / 2,
				spawnCount = 2,
				delay = 2
			},
			{
				class = Spikes,
				decay = 2 * math.pi / 3
			},
			{
				class = Spikes,
				decay = 5 * math.pi / 3
			},
		}

		--[[
		Gates = {
			{
				class = AngelFace,
				isBoss = true,
				x = 10,
				y = 10
			},
			{
				class = Spikes,
				decay = 5 * math.pi / 6
			},
			{
				class = Spikes,
				decay = 2 * math.pi / 3
			},
			{
				class = Spikes,
				decay = math.pi / 3
			},
			{
				class = Spikes,
				decay = math.pi / 6
			},
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 2,
				delay = 4
			}
		}
		]] --
	},
	{
		name = 'Test',
		arena = Assets.gfx.arena1,
		loop = {
			duration = 4
		},
		Gates = {
			{
				class = Gate,
				--mineCount = 20
			}
		}
	},
	{
		name = 'Test',
		arena = Assets.gfx.arena2,
		loop = {
			duration = 4
		},
		Gates = {
			{
				class = MineDropper,
				--mineCount = 20
			},
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 1,
				delay = 4
			},
			{
				class = Gate,
				decay = 3 * math.pi / 2,
				spawnCount = 1,
				delay = 5
			}

			--[[
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 3
			},

			{
				class = Snake,
				isBoss = true,
				x = love.graphics.getWidth() / 2,
				y = love.graphics.getHeight() / 2
			}
]] --

			--[[
			{
				class = Rock,
				x = love.graphics.getWidth() / 2,
				y = love.graphics.getHeight() / 2
			}
			]] --
		}
	}
}


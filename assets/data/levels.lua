return {

	{
		name = 'Castle',
		arena = Assets.gfx.parquet,
		scale = 0.5,
		loop = {
			duration = 0.2,
			rotation = 0
		},
		Gates = {}
	},

	{
		name = 'Planes',
		arena = Assets.gfx.arena2,
		loop = {
			duration = 1 --4
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 3
			}
		}
	},
	{
		name = 'Spikes',
		arena = Assets.gfx.arena1,
		loop = {
			duration = 4
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 4
			},
			{
				class = Spikes,
				decay = 3 * math.pi / 2
			}
		}
	},
	{
		name = 'Spikes x2',
		arena = Assets.gfx.arena3,
		loop = {
			duration = 4
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 4
			},
			{
				class = Spikes,
				decay = 5 * math.pi / 4
			},
			{
				class = Spikes,
				decay = 7 * math.pi / 4
			}
		}
	},
	{
		name = 'One shot',
		arena = Assets.gfx.arena1,
		Gates = {
			{
				class = Gate,
				decay = math.pi / 4,
				spawnCount = 1,
				delay = 1,
				spawnClass = Kamikaze
			},
			{
				class = Gate,
				decay = 3 * math.pi / 4,
				spawnCount = 5
			},
		}
	},
	{
		name = 'Lazer',
		arena = Assets.gfx.arena2,
		Gates = {
			{
				class = Lazer
			},
			{
				class = Gate,
				decay = math.pi * 2,
				spawnCount = 2
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
			}
			--[[
			{
				class = Spikes,
				decay = 2 * math.pi / 3
			},
			{
				class = Spikes,
				decay = 5 * math.pi / 3
			},
			]]
		}
	},
	{
		name = 'Gates...',
		arena = Assets.gfx.arena3,
		loop = {
			duration = 4,
			count = 8
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi / 3,
				spawnCount = 2,
				delay = 0.8
			},
			{
				class = Gate,
				decay = 5 * math.pi / 3,
				spawnCount = 2,
				delay = 2.4
			},
			{
				class = Gate,
				decay = math.pi,
				spawnCount = 2,
				delay = 4
			}
		}
	},
	{
		name = '... and Spikes',
		arena = Assets.gfx.arena3,
		loop = {
			duration = 4,
			count = 8
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi / 3,
				spawnCount = 2,
				delay = 0.8
			},
			{
				class = Spikes,
				decay = 0
			},
			{
				class = Gate,
				decay = 5 * math.pi / 3,
				spawnCount = 2,
				delay = 2.4
			},
			{
				class = Spikes,
				decay = 2 * math.pi / 3
			},
			{
				class = Gate,
				decay = math.pi,
				spawnCount = 2,
				delay = 4
			},
			{
				class = Spikes,
				decay = 4 * math.pi / 3
			}
		}
	},
	{
		name = 'Burn\'em all',
		arena = Assets.gfx.arena3,
		Gates = {
			{
				class = Gate,
				decay = 0,
				spawnCount = 4
			},
			{
				class = Blowtorch,
				decay = math.pi / 4
			},
			{
				class = Blowtorch,
				decay = 7 * math.pi / 4
			},
			{
				class = Spikes,
				decay = math.pi
			}
		}
	},
	{
		name = 'Spiky',
		arena = Assets.gfx.arena1,
		-- duration = // TODO
		Gates = {
			{
				class = Gate,
				spawnCount = 4,
				decay = math.pi / 2
			},
			{
				class = Spikes,
				decay = math.pi,
				delay = 1
			},
			{
				class = Spikes,
				decay = 1.5 * math.pi,
				delay = 1.5
			},
			{
				class = Spikes,
				decay = 0,
				delay = 0
			},
			{
				class = Spikes,
				decay = 5 * math.pi / 4,
				delay = 5 / 4
			},
			{
				class = Spikes,
				decay = 7 * math.pi / 4,
				delay = 7 / 4
			},
			{
				class = Spikes,
				decay = 3 * math.pi / 4,
				delay = 3 / 4
			},
			{
				class = Spikes,
				decay = math.pi / 4,
				delay = 1 / 4
			}
		}
	},

	--[[
	{
		name = 'High protection',
		arena = Assets.gfx.arena2,
		Gates = {
			{
				class = Lazer,
			},
			{
				class = Lazer
			},
			{
				class = Lazer,
			},
			{
				class = Lazer,
			}
		}
	},
	]] --
	{
		name = 'Waterfall',
		arena = Assets.gfx.arena2,
		water = true,
		loop = {
			duration = 4
		},
		Gates = {
			{
				class = Gate,
				decay = math.pi / 2,
				spawnCount = 8
			},
		}
	},
	{
		name = 'Mines',
		arena = Assets.gfx.arena1,
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
		}
	}
	--[[
	{
		name = 'Angel face',
		arena = Assets.gfx.arena3,
		angle = 0, -- keep elements as is
		loop = {
			rotation = 0
		},
		Gates = {
			{
				class = AngelFace,
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
	}
	]]
}
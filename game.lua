local WorldSim = prism.worldsim.WorldSim

--- @class Game : Object
--- @field depth integer
--- @field rng RNG
--- @field level Level?
--- @field player Actor?
--- @field factions table<string, Actor>
--- @field debug boolean
--- @field worldSim WorldSim
local Game = prism.Object:extend("Game")

function Game:__new(seed)
	self.depth = 0
	self.rng = prism.RNG(seed)
	self.player = prism.actors.Player()
	self.debug = false

	self.worldSim = WorldSim()
end

--- Build one zone's terrain with this game's own generator. worldsim is never
--- told how this happens — it just receives the builder. Cavern draws its
--- randomness from the passed RNG, so seeding it from the zone seed keeps the
--- terrain stable across regenerations. nil player: the player is placed by
--- generateNextFloor, never baked into a zone.
--- @param zx integer
--- @param zy integer
--- @return LevelBuilder builder, table rooms
function Game:_buildZone(zx, zy)
	local seed = self:getZoneSeed(zx, zy)
	return prism.generators
		.Cavern()
		:generate({ w = 120, h = 120, depth = self.depth, seed = seed }, nil, prism.RNG(seed))
end

function Game:pregenerateZones()
	-- Zone files persist in the LÖVE save directory across sessions, so a new
	-- game must not inherit a previous world's terrain. Wipe any stale files.
	for _, name in ipairs(love.filesystem.getDirectoryItems("")) do
		if name:match("^zone_%-?%d+_%-?%d+%.lz4$") then
			love.filesystem.remove(name)
		end
	end

	for zy = 0, 1 do
		for zx = 0, 1 do
			local builder, rooms = self:_buildZone(zx, zy)
			self.worldSim:pregenerateZone(zx, zy, builder, rooms)
		end
	end

	local beetle = prism.actors.Beetle()
	beetle:give(prism.components.Position(prism.Vector2(16, 16)))
	self.worldSim:addDormantActor(beetle, 0, 1)
end

function Game:getLevelSeed()
	return tostring(self.rng:random())
end

function Game:getZoneSeed(zoneX, zoneY)
	return tostring(love.math.noise(zoneX * 127.1 + 311.7, zoneY * 269.5 + 183.3) * 1e9)
end

function Game:generateNextFloor()
	local builder, rooms = self.worldSim:hydrateZone(self.worldSim.zoneX, self.worldSim.zoneY)
	builder:addActor(self.player, 12, 12)
	return builder, rooms
end

_G.Game = Game(tostring(os.time()))

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

	self.factions = {
		PlayerFaction = prism.factions.PlayerFaction(),
		KoboldFaction = prism.factions.KoboldFaction(),
		OlmFaction = prism.factions.OlmFaction(),
		BeetleFaction = prism.factions.BeetleFaction(),
		SalamanderFaction = prism.factions.SalamanderFaction(),
		FireFaction = prism.factions.FireFaction(),
	}

	self.factions.PlayerFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.KoboldFaction
	)
	self.factions.PlayerFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.SalamanderFaction
	)
	self.factions.BeetleFaction:addRelation(prism.relations.FactionRelationshipRelation(0), self.factions.KoboldFaction)
	self.factions.PlayerFaction:addRelation(prism.relations.FactionRelationshipRelation(-100), self.factions.OlmFaction)
	self.factions.OlmFaction:addRelation(prism.relations.FactionRelationshipRelation(-100), self.factions.KoboldFaction)
	self.factions.OlmFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.SalamanderFaction
	)
	self.factions.OlmFaction:addRelation(prism.relations.FactionRelationshipRelation(-100), self.factions.OlmFaction)
	self.factions.OlmFaction:addRelation(prism.relations.FactionRelationshipRelation(-100), self.factions.BeetleFaction)

	for _, faction in pairs(self.factions) do
		faction:addRelation(prism.relations.FactionRelationshipRelation(-100), self.factions.FireFaction)
	end
end

function Game:pregenerateZones()
	-- Pre-generate a 3×3 world grid so all zones exist from the start.
	-- The beetle is placed in zone (0,1) by pregenerateZones.
	self.worldSim:pregenerateZones(3, 3, 0, 0)
end
function Game:getLevelSeed()
	return tostring(self.rng:random())
end

function Game:getZoneSeed(zoneX, zoneY)
	return tostring(love.math.noise(zoneX * 127.1 + 311.7, zoneY * 269.5 + 183.3) * 1e9)
end

function Game:generateNextFloor()
	local builder = self.worldSim:hydrateZone(self.worldSim.zoneX, self.worldSim.zoneY)
	builder:addActor(self.player, 12, 12)
	return builder
end

_G.Game = Game(tostring(os.time()))

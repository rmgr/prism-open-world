--local levelgen = require("levelgen")

--- @class Game : Object
--- @field depth integer
--- @field rng RNG
--- @field level Level?
--- @field player Actor?
--- @field factions table<string, Actor>
--- @field debug boolean

--- @overload fun(seed: string): Game
local Game = prism.Object:extend("Game")

--- @param seed string
function Game:__new(seed)
	self.depth = 0
	self.rng = prism.RNG(seed)
	self.player = prism.actors.Player()
	self.debug = false
	self.level_width = 120
	self.level_height = 120

	-- Initialize factions once
	self.factions = {
		PlayerFaction = prism.factions.PlayerFaction(),
		KoboldFaction = prism.factions.KoboldFaction(),
		OlmFaction = prism.factions.OlmFaction(),
		BeetleFaction = prism.factions.BeetleFaction(),
		SalamanderFaction = prism.factions.SalamanderFaction(),
		FireFaction = prism.factions.FireFaction(),
		LeechFaction = prism.factions.LeechFaction(),
	}

	-- Establish initial faction relationships
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
	self.factions.LeechFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.KoboldFaction
	)
	self.factions.LeechFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.SalamanderFaction
	)
	self.factions.LeechFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.BeetleFaction
	)
	self.factions.LeechFaction:addRelation(prism.relations.FactionRelationshipRelation(-100), self.factions.OlmFaction)
	self.factions.LeechFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.PlayerFaction
	)

	for i, faction in ipairs(self.factions) do
		faction:addRelation(prism.relations.FactionRelationshipRelation(-100, self.factions.FireFaction))
	end
end

--- @return string
function Game:getLevelSeed()
	return tostring(self.rng:random())
end

--- @param builder? LevelBuilder
--- @return LevelBuilder builder, table rooms
function Game:generateNextFloor()
	self.depth = self.depth + 1

	local generator = prism.generators.FloodedCavern()
	return generator:generate(
		{ w = self.level_width, h = self.level_height, seed = self:getLevelSeed(), depth = self.depth },
		self.player,
		self.rng
	) --, 100, 160, builder
end

_G.Game = Game(tostring(os.time()))

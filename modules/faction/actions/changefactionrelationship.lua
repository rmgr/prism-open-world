--- @class ChangeFactionRelationship : Action
--- @field fromFactionName string
--- @field toFactionName string
--- @field deltaStrength number
--- @overload fun(owner: Actor, fromFactionName: string, toFactionName: string, deltaStrength: number): ChangeFactionRelationship
local ChangeFactionRelationship = prism.Action:extend("ChangeFactionRelationship")

---@param owner Actor
---@param fromFactionName string
---@param toFactionName string
---@param deltaStrength number
function ChangeFactionRelationship:__new(owner, fromFactionName, toFactionName, deltaStrength)
	self.super.__new(self, owner)
	self.fromFactionName = fromFactionName
	self.toFactionName = toFactionName
	self.deltaStrength = deltaStrength
end

function ChangeFactionRelationship:canPerform(level)
	-- Find the faction actors by name
	local fromFaction = nil
	local toFaction = nil

	for factionActor in level:query(prism.components.Faction):iter() do
		local name = prism.components.Name.get(factionActor)
		if name == self.fromFactionName then
			fromFaction = factionActor
		elseif name == self.toFactionName then
			toFaction = factionActor
		end
	end

	return fromFaction ~= nil and toFaction ~= nil
end

function ChangeFactionRelationship:perform(level)
	-- Find the faction actors by name
	local fromFaction = nil
	local toFaction = nil

	for factionActor in level:query(prism.components.Faction):iter() do
		local name = prism.components.Name.get(factionActor)
		if name == self.fromFactionName then
			fromFaction = factionActor
		elseif name == self.toFactionName then
			toFaction = factionActor
		end
	end

	if not fromFaction or not toFaction then
		return
	end

	-- Get the relationship from fromFaction to toFaction
	local relations = fromFaction:getRelations(prism.relations.FactionRelationshipRelation)
	local relationship = relations[toFaction]
	---@cast relationship FactionRelationshipRelation

	if relationship then
		-- Update existing relationship (clamped to -100 to 100)
		relationship.strength = math.max(-100, math.min(100, relationship.strength + self.deltaStrength))
	else
		-- Create new relationship if it doesn't exist
		fromFaction:addRelation(
			prism.relations.FactionRelationshipRelation(math.max(-100, math.min(100, self.deltaStrength))),
			toFaction
		)
	end
end

return ChangeFactionRelationship

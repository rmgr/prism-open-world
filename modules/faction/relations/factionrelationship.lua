--- A relation representing the relationship strength between two factions.
--- Strength ranges from -100 (hostile) to 100 (friendly)
--- @class FactionRelationshipRelation : Relation
--- @field strength number The relationship strength from -100 to 100
--- @overload fun(strength: number): FactionRelationshipRelation
local FactionRelationshipRelation = prism.Relation:extend("FactionRelationshipRelation")

function FactionRelationshipRelation:__new(strength)
	self.strength = strength or 0
end

--- Generates the inverse relation of this one.
--- The inverse has the same strength value.
--- @return FactionRelationshipRelation The inverse relation with the same strength.
function FactionRelationshipRelation:generateInverse()
	return prism.relations.FactionRelationshipRelation(self.strength)
end

return FactionRelationshipRelation

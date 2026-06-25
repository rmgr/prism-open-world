--- A relation representing that a faction contains an entity.
--- This is the inverse of the `BelongsToFaction` relation.
--- @class FactionContainsRelation : Relation
--- @overload fun(): FactionContainsRelation
local FactionContainsRelation = prism.Relation:extend("FactionContainsRelation")

--- Generates the inverse relation of this one.
--- @return Relation The inverse `BelongsToFaction` relation.
function FactionContainsRelation:generateInverse()
	return prism.relations.BelongsToFactionRelation
end

return FactionContainsRelation

--- A relation representing that an entity belongs to a faction.
--- This is the inverse of the `FactionContains` relation.
--- @class BelongsToFactionRelation : Relation
--- @overload fun(): BelongsToFactionRelation
local BelongsToFactionRelation = prism.Relation:extend("BelongsToFactionRelation")

--- Generates the inverse relation of this one.
--- @return Relation The inverse `FactionContains` relation.
function BelongsToFactionRelation:generateInverse()
	return prism.relations.FactionContainsRelation
end

return BelongsToFactionRelation

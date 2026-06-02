--- A relation representing that an entity is a foe of another entity.
--- @class FearsRelation : Relation
--- @overload fun(): FearsRelation
local FearsRelation = prism.Relation:extend("FearsRelation")

function FearsRelation:generateInverse()
	return prism.relations.FearedByRelation()
end
return FearsRelation

--- A relation representing that an entity is a foe of another entity.
--- @class FearedByRelation : Relation
--- @overload fun(): FearedByRelation
local FearedByRelation = prism.Relation:extend("FearedByRelation")

function FearedByRelation:generateInverse()
	return prism.relations.FearsRelation()
end
return FearedByRelation

--- A relation representing that an entity is a foe of another entity.
--- This is a symmetric relation - being foes is mutual.
--- @class FoeRelation : Relation
--- @overload fun(): FoeRelation
local FoeRelation = prism.Relation:extend("FoeRelation")

--- Generates the symmetric relation - being foes is mutual.
--- @return Relation The symmetric `Foe` relation.
function FoeRelation:generateSymmetric()
	return prism.relations.FoeRelation()
end

return FoeRelation

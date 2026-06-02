--- A relation representing that an entity is a foe of another entity.
--- @class AttackedRelation : Relation
--- @overload fun(): AttackedRelation
local AttackedRelation = prism.Relation:extend("AttackedRelation")

function AttackedRelation:generateInverse()
	return prism.relations.AttackedByRelation()
end
return AttackedRelation

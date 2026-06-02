--- A relation representing that an entity is a foe of another entity.
--- @class AttackedByRelation : Relation
--- @overload fun(): AttackedByRelation
local AttackedByRelation = prism.Relation:extend("AttackedByRelation")

function AttackedByRelation:generateInverse()
	return prism.relations.AttackedRelation()
end
return AttackedByRelation

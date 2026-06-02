--- A relation representing that an entity is friends with another entity.
--- This is a symmetric relation - friendship is mutual.
--- @class FriendRelation : Relation
--- @overload fun(): FriendRelation
local FriendRelation = prism.Relation:extend("FriendRelation")

--- Generates the symmetric relation - friendship is mutual.
--- @return Relation The symmetric `Friend` relation.
function FriendRelation:generateSymmetric()
	return prism.relations.FriendRelation()
end

return FriendRelation

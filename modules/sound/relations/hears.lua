--- A relation representing that an actor can smell another actor.
--- This is a one-way relation - the smeller detects the smelled.
--- @class HearsRelation : Relation
--- @overload fun(): HearsRelation
local HearsRelation = prism.Relation:extend("HearsRelation")

return HearsRelation

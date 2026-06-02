--- A relation representing that an actor can smell another actor.
--- This is a one-way relation - the smeller detects the smelled.
--- @class SmellsRelation : Relation
--- @overload fun(): SmellsRelation
local SmellsRelation = prism.Relation:extend("SmellsRelation")

return SmellsRelation

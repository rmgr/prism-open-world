--- @class AfraidOf : Component
--- @field factions table
local AfraidOf = prism.Component:extend("AfraidOf")
AfraidOf.name = "AfraidOf"

--- @param factions table
function AfraidOf:__new(factions)
	self.factions = factions
end

return AfraidOf

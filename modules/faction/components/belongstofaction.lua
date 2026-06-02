--- @class BelongsToFaction : Component
--- @field factions table
--- @overload fun(factions: table): BelongsToFaction
local BelongsToFaction = prism.Component:extend("BelongsToFaction")

function BelongsToFaction:__new(factions)
	self.factions = factions
end

return BelongsToFaction

--- Scent Component
--- Marks actors that emit scent into the environment
--- @class ScentOptions
--- @field strength integer How strong is the scent? (1-100, higher = stronger)

--- @class Scent : Component
--- @field private strength integer Scent strength value
--- @overload fun(options: ScentOptions): Scent
local Scent = prism.Component:extend("Scent")

--- @param options ScentOptions
function Scent:__new(options)
	self.strength = options.strength or 50
end

--- Get the strength of this scent
--- @return integer
function Scent:getStrength()
	return self.strength
end

--- Set the strength of this scent
--- @param strength integer
function Scent:setStrength(strength)
	self.strength = strength
end

return Scent

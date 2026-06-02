--- @class Burning : Component
--- @overload fun(fuel: integer)
local Burning = prism.Component:extend("Burning")
Burning.name = "Burning"

--- @param fuel integer|nil
function Burning:__new(fuel)
	self.fuel = fuel or 5
end

return Burning

--- @class Flammable: Component
--- @overload fun(fuel: number, spentFuel: number)
local Flammable = prism.Component:extend("Flammable")
---@param fuel number|nil
function Flammable:__new(fuel)
	self.fuel = fuel or 8
	self.spentFuel = 0
end

return Flammable

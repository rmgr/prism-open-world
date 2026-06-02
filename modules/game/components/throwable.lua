--- @class Throwable : Component
--- @overload fun(damage: number): Throwable
local Throwable = prism.Component:extend("Throwable")

--- Constructor for the Throwable component.
--- @param damage number The initial damage value (default: 1)
function Throwable:__new(damage)
	self.damage = damage or 1
end

return Throwable

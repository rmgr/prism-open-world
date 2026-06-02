--- @class Edible : Component
--- @field healing integer
--- @field satiety integer
--- @overload fun(healing: integer, satiety: integer): Edible
local Edible = prism.Component:extend("Edible")

--- @param healing integer
--- @param satiety integer
function Edible:__new(healing, satiety)
	self.healing = healing
	self.satiety = satiety
end

return Edible

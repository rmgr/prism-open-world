--- @class DamageModifier : ConditionModifier
--- @field delta integer
--- @overload fun(delta: integer): DamageModifier

local DamageModifier = prism.condition.ConditionModifier:extend("DamageModifier")

function DamageModifier:__new(delta)
	self.delta = delta
end

return DamageModifier

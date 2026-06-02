--- @class DamageReductionModifier : ConditionModifier
--- @field mod integer
--- @overload fun(mod: integer): DamageReductionModifier

local DamageReductionModifier = prism.condition.ConditionModifier:extend("DamageReductionModifier")

function DamageReductionModifier:__new(mod)
	self.mod = mod
end

return DamageReductionModifier

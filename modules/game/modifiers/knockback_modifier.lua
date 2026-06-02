--- @class KnockbackModifier : ConditionModifier
--- @field delta integer
--- @overload fun(delta: integer): KnockbackModifier

local KnockbackModifier = prism.condition.ConditionModifier:extend("KnockbackModifier")

function KnockbackModifier:__new(delta)
	self.delta = delta
end

return KnockbackModifier

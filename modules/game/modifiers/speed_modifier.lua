--- @class SpeedModifier : ConditionModifier
--- @field delta integer
--- @overload fun(delta: integer): SpeedModifier

local SpeedModifier = prism.condition.ConditionModifier:extend("SpeedModifier")

function SpeedModifier:__new(delta)
	self.delta = delta
end

return SpeedModifier

--- @class HealthModifier : TickedConditionModifier
--- @field hpDelta integer
--- @overload fun(delta: integer): HealthModifier
local TickedConditionModifier = require("modules.game.modifiers.tickedmodifier")

local HealthModifier = TickedConditionModifier:extend("HealthModifier")

function HealthModifier:__new(delta)
	self.hpDelta = delta
end

--- @param owner Entity
function HealthModifier:tick(owner)
	local health = owner:get(prism.components.Health)
	if not health then
		return
	end
	health:heal(self.hpDelta)
end

return HealthModifier

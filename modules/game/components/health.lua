local ConditionHolder = prism.components.ConditionHolder
--- @class Health : Component
--- @field private maxHP integer
--- @field hp integer
--- @overload fun(hp: integer): Health
local Health = prism.Component:extend("Health")

function Health:__new(maxHP)
	self.maxHP = maxHP
	self.hp = maxHP
end

--- @param amount integer
function Health:heal(amount)
	self.hp = math.min(self.hp + amount, self:getMaxHP())
end

function Health:enforceBounds()
	self:heal(0)
end

function Health:getMaxHP()
	local modifiers = ConditionHolder.getActorModifiers(self.owner, prism.modifiers.HealthModifier)

	local modifiedMaxHP = self.maxHP
	for _, modifier in ipairs(modifiers) do
		modifiedMaxHP = modifiedMaxHP + modifier.hpDelta
	end

	return modifiedMaxHP
end
return Health

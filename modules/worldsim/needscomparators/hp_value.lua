--- Scores safety urgency as 1 - hp/maxHP. An actor at full health scores 0;
--- a critically wounded actor scores close to 1.
--- @class HpValueComparator : NeedsComparator
local HpValueComparator = prism.worldsim.NeedsComparator:extend("HpValueComparator")

function HpValueComparator:compare(actor)
	local health = actor:get(prism.components.Health)
	if not health then return 0 end
	return 1 - health.hp / health.maxHP
end

return HpValueComparator

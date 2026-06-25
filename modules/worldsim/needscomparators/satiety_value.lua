--- Scores hunger urgency as 1 - satiety/maxSatiety. A full actor scores 0;
--- a starving actor scores close to 1.
--- @class SatietyValueComparator : NeedsComparator
local SatietyValueComparator = prism.worldsim.NeedsComparator:extend("SatietyValueComparator")

function SatietyValueComparator:compare(actor)
	local satiety = actor:get(prism.components.Satiety)
	if not satiety then return 0 end
	return 1 - satiety.satiety / satiety.maxSatiety
end

return SatietyValueComparator

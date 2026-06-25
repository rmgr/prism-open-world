--- Drains satiety on dormant actors at the same rate as the live SatietySystem
--- (1 per turn). Satiety is clamped at 0 so the score stays in 0..1+.
--- @class SatietySimSystem : SimSystem
local SatietySimSystem = prism.worldsim.SimSystem:extend("SatietySimSystem")

--- @param record ZoneRecord
--- @param ticksDelta integer
--- @param rng RNG
--- @param worldSim WorldSim
function SatietySimSystem:onSimTick(record, ticksDelta, rng, worldSim)
	for actor in record.storage:query(prism.components.Satiety):iter() do
		local satiety = actor:get(prism.components.Satiety)
		if satiety.satiety > 0 then
			local before = satiety.satiety
			satiety.satiety = math.max(0, satiety.satiety - ticksDelta)
			-- Log when satiety hits zero for the first time.
			if satiety.satiety == 0 and before > 0 then
				print(("[sim] %s is starving"):format(actor:getName()))
			end
		end
	end
end

return SatietySimSystem

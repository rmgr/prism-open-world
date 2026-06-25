--- Produces a SeekFoodGoal targeting the nearest dormant zone that holds a
--- FoodSource landmark. Falls back to a random adjacent zone when none exists.
--- @class SeekFoodAction : NeedsAction
local SeekFoodAction = prism.worldsim.NeedsAction:extend("SeekFoodAction")

local function findZoneWithFoodSource(worldSim)
	for landmark in worldSim.allActors:query(prism.components.FoodSource):iter() do
		local r = worldSim.actorZoneIndex[landmark]
		if r then
			return prism.Vector2(r.zoneX, r.zoneY)
		end
	end
	return nil
end

function SeekFoodAction:evaluate(actor, worldSim, rng, record)
	local zone = findZoneWithFoodSource(worldSim) or self:randomAdjacentZone(worldSim, record, rng)
	local duration = 5 + rng:random(5)
	return prism.components.SeekFoodGoal(zone, "travelling", duration)
end

return SeekFoodAction

--- Produces a SeekRestGoal targeting the nearest dormant zone that holds a
--- RestSpot landmark. Falls back to a random adjacent zone when none exists.
--- @class SeekRestAction : NeedsAction
local SeekRestAction = prism.worldsim.NeedsAction:extend("SeekRestAction")

local function findZoneWithRestSpot(worldSim)
	for landmark in worldSim.allActors:query(prism.components.RestSpot):iter() do
		local r = worldSim.actorZoneIndex[landmark]
		if r then
			return prism.Vector2(r.zoneX, r.zoneY)
		end
	end
	return nil
end
function SeekRestAction:evaluate(actor, worldSim, rng, record)
	local zone = findZoneWithRestSpot(worldSim) or self:randomAdjacentZone(worldSim, record, rng)
	local duration = 5 + rng:random(5)
	return prism.components.SeekRestGoal(zone, "travelling", duration)
end

return SeekRestAction

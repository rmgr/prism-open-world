--- Base class for need goal-factories. An action reads only components
--- and the world sim, so it runs headless in the dormant sim.
--- @class NeedsAction : Object
local NeedsAction = prism.Object:extend("NeedsAction")

--- Build and return the Goal that satisfies this need, or nil if no
--- satisfying goal is currently constructable. Reads components only.
--- @param actor Actor
--- @param worldSim WorldSim
--- @param rng RNG
--- @param record ZoneRecord   the zone the actor currently sits in
--- @return Goal?
function NeedsAction:evaluate(actor, worldSim, rng, record)
	return nil
end

--- @param worldSim WorldSim
--- @param rng RNG
--- @param record ZoneRecord   the zone the actor currently sits in
--- @return Vector2
function NeedsAction:randomAdjacentZone(worldSim, record, rng)
	local DIRS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
	local order = { 1, 2, 3, 4 }
	for i = 4, 2, -1 do
		local j = rng:random(i)
		order[i], order[j] = order[j], order[i]
	end
	for _, idx in ipairs(order) do
		local d = DIRS[idx]
		local tx, ty = record.zoneX + d[1], record.zoneY + d[2]
		if worldSim.zones:get(tx, ty) then
			return prism.Vector2(tx, ty)
		end
	end
	return prism.Vector2(record.zoneX, record.zoneY)
end

return NeedsAction

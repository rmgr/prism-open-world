--- WanderSimSystem
--- Moves actors that have a Speed component between dormant zones.
--- Each sim tick, an actor accumulates "wander energy" proportional to its
--- Speed value. When energy hits the threshold (100), the actor takes one
--- migration step to a random adjacent zone.
---
--- This mirrors the SpeedScheduler's energy model so a Speed(50) beetle
--- migrates half as often as a Speed(100) kobold.
---
--- @class WanderSimSystem : SimSystem
local WanderSimSystem = prism.worldsim.SimSystem:extend("WanderSimSystem")

--- Energy required for one zone migration step.
WanderSimSystem.ENERGY_THRESHOLD = 2000

--- Cardinal neighbour offsets.
local DIRS = { { 1, 0 }, { -1, 0 } } --, { 0, 1 }, { 0, -1 } }

--- @param record ZoneRecord
--- @param ticksDelta integer
--- @param rng RNG
--- @param worldSim WorldSim
function WanderSimSystem:onSimTick(record, ticksDelta, rng, worldSim)
	-- Collect migrants first — modifying storage while iterating is unsafe.
	local migrants = {}
	for actor in record.storage:query(prism.components.Speed):iter() do
		local speed = actor:get(prism.components.Speed)
		local energy = (actor._wanderEnergy or 0) + speed.speed * ticksDelta

		if energy >= self.ENERGY_THRESHOLD then
			energy = energy - self.ENERGY_THRESHOLD
			table.insert(migrants, actor)
		end

		actor._wanderEnergy = energy
	end

	for _, actor in ipairs(migrants) do
		-- Pick a random adjacent zone that exists (has been created).
		-- We don't create new zones here — the actor stays put if all
		-- neighbours are unvisited.
		local dir = DIRS[rng:random(#DIRS)]
		local tx = record.zoneX + dir[1]
		local ty = record.zoneY + dir[2]
		local targetRecord = worldSim.zones:get(tx, ty)

		if targetRecord then
			print("Actor moving! (" .. record.zoneX .. "," .. record.zoneY .. ") -> (" .. tx .. "," .. ty .. ")")
			record.storage:removeActor(actor)
			worldSim.allActors:removeActor(actor)

			-- Centre of our 31×31 dummy room.
			actor:give(prism.components.Position(prism.Vector2(16, 16)))

			targetRecord.storage:addActor(actor)
			worldSim.allActors:addActor(actor)
		end
	end
end

return WanderSimSystem

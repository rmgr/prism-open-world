--- @class GoalSimSystem : SimSystem
local GoalSimSystem = prism.worldsim.SimSystem:extend("GoalSimSystem")

--- Energy required for one zone migration step.
GoalSimSystem.ENERGY_THRESHOLD = 1000

--- @param record ZoneRecord
--- @param ticksDelta integer
--- @param rng RNG
--- @param worldSim WorldSim
function GoalSimSystem:onSimTick(record, ticksDelta, rng, worldSim)
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
		local goal = actor:get(prism.components.Goal)
		if not goal then
			print(actor:getName() .. " is feeling sleepy")
			actor:give(
				prism.components.SeekRestGoal(prism.Vector2(rng:random(0, 2), rng:random(0, 2)), "travelling", 10)
			)
		else
			if goal.state == "travelling" then
				print(actor:getName() .. " is travelling")
				if goal:isAtTargetZone(record) then
					goal:resolve(actor, record.storage, worldSim)
					goal.state = "active"
					goal.elapsed = 0
				else
					local zx, zy = goal:nextZone(actor, record, worldSim, rng)
					local target = zx and worldSim.zones:get(zx, zy)
					if target then
						worldSim:moveActor(actor, zx, zy)
					end
				end
			elseif goal.state == "active" then
				print(actor:getName() .. " is resting")
				goal.elapsed = goal.elapsed + ticksDelta
				if goal.elapsed >= goal.duration then
					goal.state = "done"
				end
			elseif goal.state == "done" then
				actor:remove(goal)
			end
		end
	end
end
return GoalSimSystem

--- @class GoalSimSystem : SimSystem
local GoalSimSystem = prism.worldsim.SimSystem:extend("GoalSimSystem")

function GoalSimSystem:handleTravelling(goal, record, actor, worldSim, rng)
	local name = actor:getName()
	if goal:isAtTargetZone(record) then
		if goal:resolve(actor, record.storage, worldSim) then
			goal.state = "active"
			goal.elapsed = 0
			print(
				("[sim] %s arrived at (%d,%d), %s now active (duration %d)"):format(
					name,
					record.zoneX,
					record.zoneY,
					goal.className,
					goal.duration
				)
			)
		else
			print(
				("[sim] %s %s resolve failed at (%d,%d), clearing goal"):format(
					name,
					goal.className,
					record.zoneX,
					record.zoneY
				)
			)
			prism.worldsim:setGoal(actor, nil)
		end
	else
		local zx, zy = goal:nextZone(actor, record, worldSim, rng)
		local target = zx and worldSim.zones:get(zx, zy)
		if target then
			print(
				("[sim] %s travelling %s: (%d,%d) → (%d,%d)"):format(
					name,
					goal.className,
					record.zoneX,
					record.zoneY,
					zx,
					zy
				)
			)
			worldSim:moveActor(actor, zx, zy)
		else
			print(
				("[sim] %s %s: no passable step from (%d,%d)"):format(name, goal.className, record.zoneX, record.zoneY)
			)
		end
	end
end

function GoalSimSystem:handleActive(goal, record, actor, worldSim, rng, ticksDelta)
	local name = actor:getName()
	goal.elapsed = goal.elapsed + ticksDelta
	if goal.elapsed >= goal.duration then
		goal:complete(actor, record.storage, worldSim)
		goal.state = "done"
		print(("[sim] %s %s complete"):format(name, goal.className))
	end
end
--- @param record ZoneRecord
--- @param ticksDelta integer
--- @param rng RNG
--- @param worldSim WorldSim
function GoalSimSystem:onSimTick(record, ticksDelta, rng, worldSim)
	-- Collect migrants first — modifying storage while iterating is unsafe.
	local migrants = {}
	for actor in record.storage:query(prism.components.Controller):iter() do
		table.insert(migrants, actor)
	end

	for _, actor in ipairs(migrants) do
		local name = actor:getName()
		local goal = actor:get(prism.components.Goal)

		if not goal then
			local newGoal = prism.worldsim:pickNextGoal(actor, worldSim, rng, record)
			if newGoal then
				prism.worldsim:setGoal(actor, newGoal)
				goal = actor:get(prism.components.Goal)
				print(
					("[sim] %s picked new goal: %s → zone (%d,%d)"):format(
						name,
						goal.className,
						goal.targetZone.x,
						goal.targetZone.y
					)
				)
			else
				print(("[sim] %s has no goal and no needs fired"):format(name))
			end
		end

		if goal then
			if goal.state == "travelling" then
				self:handleTravelling(goal, record, actor, worldSim, rng)
			elseif goal.state == "active" then
				self:handleActive(goal, record, actor, worldSim, rng, ticksDelta)
			elseif goal.state == "done" then
				prism.worldsim:setGoal(actor, nil)
				local newGoal = prism.worldsim:pickNextGoal(actor, worldSim, rng, record)
				if newGoal then
					prism.worldsim:setGoal(actor, newGoal)
					print(
						("[sim] %s next goal: %s → zone (%d,%d)"):format(
							name,
							newGoal.className,
							newGoal.targetZone.x,
							newGoal.targetZone.y
						)
					)
				end
			end
		end
	end
end

return GoalSimSystem

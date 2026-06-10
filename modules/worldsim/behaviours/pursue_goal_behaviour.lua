--- @class PursueGoalBehaviour : BehaviorTree.Node
local PursueGoalBehaviour = prism.BehaviorTree.Node:extend("PursueGoalBehaviour")

function PursueGoalBehaviour:atTarget(actor, spot)
	local actorPos = actor:getPosition()
	local spotPos = spot:getPosition()

	if spotPos:distance(actorPos) < 2 then
		return true
	end
	return false
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function PursueGoalBehaviour:run(level, actor, controller)
	local goal = actor:get(prism.components.Goal) -- polymorphic
	if not goal then
		return false
	end -- fall through to wander/hunt

	if goal.state == "travelling" then
		--[[if not self:targetZoneIsHere(goal) then
			-- walk toward the relevant edge and linger (section 2 rule)
			controller.blackboard.short["target fal"] = self:edgeToward(level, goal)
			return false -- let MoveBehaviour consume it
		end]]
		--
		local spot = goal:findLiveTarget(actor, level)
		if not spot then
			actor:remove(goal)
			return false
		end -- fail clean

		if self:atTarget(actor, spot) then
			goal.state = "active"
			goal.elapsed = 0
		else
			controller.blackboard.short["target"] = spot
			return false -- MoveBehaviour walks us there, visibly
		end
	end

	if goal.state == "active" then
		goal.elapsed = goal.elapsed + 1
		print("Goal ticking: " .. goal.elapsed)
		if goal.elapsed >= goal.duration then
			goal.state = "done"
		end
		return goal:liveAction(actor, level) -- Wait / guard-swipe / mine-anim
	end

	if goal.state == "done" then
		actor:remove(goal) -- job-advance or needs comparator picks next
		return false
	end
	return false
end
return PursueGoalBehaviour

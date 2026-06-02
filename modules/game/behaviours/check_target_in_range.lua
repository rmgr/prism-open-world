--- @class CheckTargetInRangeBehaviour : BehaviorTree.Node
--- @field range number
local CheckTargetInRangeBehaviour = prism.BehaviorTree.Node:extend("CheckTargetInRangeBehaviour")

--- @param range number
function CheckTargetInRangeBehaviour:__new(range)
	self.range = range or 1
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function CheckTargetInRangeBehaviour:run(level, actor, controller)
	local target = controller.blackboard.short["target"]
	if not target then
		return false
	end

	if prism.Actor:is(target) then
		target = target:getPosition()
	end
	-- Check if player is within specified range
	local distance = actor:getPosition():distance(target)
	local inRange = distance <= self.range
	return inRange
end

return CheckTargetInRangeBehaviour

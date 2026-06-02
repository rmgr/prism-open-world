--- @class CheckRoomTargetBehaviour : BehaviorTree.Node
local CheckRoomTargetBehaviour = prism.BehaviorTree.Node:extend("CheckRoomTargetBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function CheckRoomTargetBehaviour:run(level, actor, controller)
	local roomTarget = controller.blackboard.long["room_target"]
	if roomTarget then
		controller.blackboard.short["target"] = roomTarget
		return true
	end
	return false
end

return CheckRoomTargetBehaviour

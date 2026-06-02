--- @class SpitFireBehaviour : BehaviorTree.Node
local SpitFireBehaviour = prism.BehaviorTree.Node:extend("SpitFireBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function SpitFireBehaviour:run(level, actor, controller)
	local target = controller.blackboard.short["target"]

	if not target then
		return false
	end
	if not prism.Actor:is(target) then
		return false
	end
	return prism.actions.SpitFire(actor, target)
end

return SpitFireBehaviour

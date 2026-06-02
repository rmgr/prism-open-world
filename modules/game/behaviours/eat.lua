--- @class EatBehaviour : BehaviorTree.Node
local EatBehaviour = prism.BehaviorTree.Node:extend("EatBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function EatBehaviour:run(level, actor, controller)
	local target = controller.blackboard.short["target"]

	if not target then
		return false
	end

	if not prism.Actor:is(target) then
		return false
	end

	local action = prism.actions.Eat(actor, nil, target)
	if level:canPerform(action) then
		return action
	else
		return false
	end
end

return EatBehaviour

--- @class AttackBehaviour : BehaviorTree.Node
local AttackBehaviour = prism.BehaviorTree.Node:extend("AttackBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function AttackBehaviour:run(level, actor, controller)
	local target = controller.blackboard.short["target"]

	if not target then
		return false
	end
	if not prism.Actor:is(target) then
		return false
	end

	local attackAction = prism.actions.Attack(actor, target)

	local x, y = level:canPerform(attackAction)
	if level:canPerform(attackAction) then
		return attackAction
	end

	return false
end

return AttackBehaviour

--- @class FearBehaviour : BehaviorTree.Node
local FearBehaviour = prism.BehaviorTree.Node:extend("FearBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function FearBehaviour:run(level, actor, controller)
	local target = level:query():relation(actor, prism.relations.AttackedByRelation):first()

	if not target then
		return false
	end

	local action = prism.actions.Fear(actor, target)
	if level:canPerform(action) then
		return action
	else
		return false
	end
end

return FearBehaviour

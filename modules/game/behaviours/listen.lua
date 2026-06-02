--- @class ListenBehaviour : BehaviorTree.Node
local ListenBehaviour = prism.BehaviorTree.Node:extend("ListenBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function ListenBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	if not senses then
		return false
	end

	local target =
		senses:query(level, prism.components.Controller):relation(actor, prism.relations.HearsRelation):first()
	if not target then
		return true
	end

	controller.blackboard.long["last_heard"] = target:getPosition()

	return true
end

return ListenBehaviour

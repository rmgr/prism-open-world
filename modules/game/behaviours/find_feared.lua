--- @class FindFearedBehaviour : BehaviorTree.Node
local FindFearedBehaviour = prism.BehaviorTree.Node:extend("FindFearedBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function FindFearedBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)

	if not senses then
		return false
	end

	local target =
		senses:query(level, prism.components.Controller):relation(actor, prism.relations.FearsRelation):first()
	--local target = level:query(prism.components.BTController):relation(actor, prism.relations.FearsRelation):first()
	if not target then
		return false
	end

	controller.blackboard.short["target"] = target

	return true
end

return FindFearedBehaviour

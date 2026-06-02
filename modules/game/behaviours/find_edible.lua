--- @class FindEdibleBehaviour : BehaviorTree.Node
local FindEdibleBehaviour = prism.BehaviorTree.Node:extend("FindEdibleBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function FindEdibleBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)

	if not senses then
		return false
	end

	local target = senses:query(level, prism.components.Edible):first()

	if not target then
		return false
	end

	controller.blackboard.short["target"] = target

	return true
end

return FindEdibleBehaviour

--- @class WaitBehaviour : BehaviorTree.Node
local WaitBehaviour = prism.BehaviorTree.Node:extend("WaitBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action
function WaitBehaviour:run(level, actor, controller)
	return prism.actions.Wait(actor)
end

return WaitBehaviour

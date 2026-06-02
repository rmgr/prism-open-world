--- @class FindHomeBehaviour : BehaviorTree.Node
--- @field relations table
--- @overload fun(relations: table): BehaviorTree.Node
local FindHomeBehaviour = prism.BehaviorTree.Node:extend("FindHomeBehaviour")

--- @param relations table
function FindHomeBehaviour:__new(relations)
	self.relations = relations or {} -- Provide default empty table
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function FindHomeBehaviour:run(level, actor, controller)
	local query = level:query():relation(actor, prism.relations.Home)
	local target = query:first()

	if not target then
		return false
	end

	controller.blackboard.short["target"] = target:getPosition()
	return true
end

return FindHomeBehaviour

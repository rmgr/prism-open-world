--- @class MoveBehaviour : BehaviorTree.Node
--- @field minDistance number
local MoveBehaviour = prism.BehaviorTree.Node:extend("MoveBehaviour")

--- @param minDistance number|nil
function MoveBehaviour:__new(minDistance)
	self.minDistance = minDistance or 1
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action|boolean
function MoveBehaviour:run(level, actor, controller)
	local target = controller.blackboard.short["target"]

	if not target then
		return false
	end

	-- Handle both Actor and Position targets
	if prism.Actor:is(target) then
		target = target:getPosition()
	end

	local mover = actor:get(prism.components.Mover)
	if not mover then
		return false
	end

	local path = level:findPath(actor:getPosition(), target, actor, mover.mask, self.minDistance)

	if not path then
		return false
	end

	local nextStep = path:pop()
	local move = prism.actions.Move(actor, nextStep)

	if level:canPerform(move) then
		return move
	end

	return false
end

return MoveBehaviour

--- @class RandomMoveBehaviour : BehaviorTree.Node
local RandomMoveBehaviour = prism.BehaviorTree.Node:extend("RandomMoveBehaviour")

function RandomMoveBehaviour:__new() end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action|boolean
function RandomMoveBehaviour:run(level, actor, controller)
	local mover = actor:get(prism.components.Mover)
	if not mover then
		return false
	end

	local currentPos = actor:getPosition()
	if not currentPos then
		return false
	end

	local dx = level.RNG:random(-1, 1)
	local dy = level.RNG:random(-1, 1)

	local x, y = currentPos:decompose()

	local targetPos = prism.Vector2(dx + x, dy + y)
	local move = prism.actions.Move(actor, targetPos)
	if level:canPerform(move) then
		return move
	else
		return false
	end
end

return RandomMoveBehaviour

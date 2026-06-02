--- @class FleeBehaviour : BehaviorTree.Node
--- @field distance number
local FleeBehaviour = prism.BehaviorTree.Node:extend("FleeBehaviour")

--- @param distance number|nil Distance to flee (default: 3)
function FleeBehaviour:__new(distance)
	self.distance = distance or 3
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function FleeBehaviour:run(level, actor, controller)
	-- Read the enemy target from blackboard (set by FindEnemyBehaviour)
	local enemy = controller.blackboard.short["target"]
	if not enemy then
		return false
	end

	-- Handle both Actor and Position targets
	local enemyPos = prism.Actor:is(enemy) and enemy:getPosition() or enemy

	-- Calculate flee position: opposite direction from enemy
	local direction = (actor:getPosition() - enemyPos):normalize()
	local fleeTarget = actor:getPosition() + (direction * self.distance)

	-- Store flee position in blackboard for MoveBehaviour to use
	controller.blackboard.short["target"] = fleeTarget

	return true
end

return FleeBehaviour

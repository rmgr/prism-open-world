--- @class RandomChanceBehaviour : BehaviorTree.Node
--- @field percentage number
local RandomChanceBehaviour = prism.BehaviorTree.Node:extend("RandomChanceBehaviour")

--- @param percentage number
function RandomChanceBehaviour:__new(percentage)
	self.percentage = percentage or 50
end
--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function RandomChanceBehaviour:run(level, actor, controller)
	return level.RNG:random(1, 100) > self.percentage
end

return RandomChanceBehaviour

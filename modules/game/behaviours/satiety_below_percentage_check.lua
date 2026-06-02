--- @class SatietyBelowPercentageCheckBehaviour : BehaviorTree.Node
--- @field percentage number
local SatietyBelowPercentageCheckBehaviour = prism.BehaviorTree.Node:extend("SatietyBelowPercentageCheckBehaviour")

--- @param percentage number
function SatietyBelowPercentageCheckBehaviour:__new(percentage)
	self.percentage = percentage or 100
end
--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function SatietyBelowPercentageCheckBehaviour:run(level, actor, controller)
	local satietyComponent = actor:get(prism.components.Satiety)

	if not satietyComponent then
		return false
	end
	local below = (satietyComponent.satiety / satietyComponent.maxSatiety) * 100 < self.percentage
	return below
end

return SatietyBelowPercentageCheckBehaviour

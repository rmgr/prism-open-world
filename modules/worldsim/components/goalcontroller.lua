--- @class GoalController : Controller
--- @overload fun() : GoalController
local GoalController = prism.components.Controller:extend("GoalController")

function GoalController:__new(tree)
	self.tree = tree
	self.blackboard = {}
	self.blackboard.long = {}
	self.blackboard.zone = nil
	self.blackboard.short = {}
end

function GoalController:act(level, actor)
	self.blackboard.short = {}
	local action = self.tree:run(level, actor, self)
	if action then
		if level:canPerform(action) then
			return action
		end
	end
	return prism.actions.Wait(actor)
end

return GoalController

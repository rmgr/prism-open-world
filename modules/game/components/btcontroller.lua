--- @class BTController : Controller
--- @overload fun() : BTController
local BTController = prism.components.Controller:extend("BTController")

function BTController:__new(tree)
	self.tree = tree
	self.blackboard = {}
	self.blackboard.long = {}
	self.blackboard.short = {}
end

function BTController:act(level, actor)
	self.blackboard.short = {}
	local action = self.tree:run(level, actor, self)
	if action then
		if level:canPerform(action) then
			return action
		else
			print("Lol found it: " .. action.name)
		end
	end
	return prism.actions.Wait(actor)
end

return BTController

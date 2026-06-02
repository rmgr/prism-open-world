local Log = prism.components.Log
local Name = prism.components.Name

local fearTarget = prism.Target(prism.components.Controller):optional()

---@class Fear : Action
---@overload fun(owner: Actor, food: Actor): Fear
local Fear = prism.Action:extend("Fear")

Fear.requiredComponents = {
	prism.components.Controller,
}

Fear.targets = {
	fearTarget,
}

--- @param level Level
---@param target Actor
function Fear:perform(level, target)
	local relation = self.owner:hasRelation(prism.relations.FearsRelation, target)

	if relation then
		return
	end

	self.owner:addRelation(prism.relations.FearsRelation, target)

	--target:addRelation(prism.relations.FearedByRelation, self.owner)

	Log.addMessage(self.owner, "You squeak in fear.")
	Log.addMessage(target, "The %s squeaks in fear.", Name.get(self.owner))
	Log.addMessageSensed(level, self, "The %s squeaks in fear.", Name.get(self.owner))
end

return Fear

---@class Fall : Action
---@overload fun(owner: Actor): Fall
local Fall = prism.Action:extend("Fall")

function Fall:perform(level)
	level:perform(prism.actions.Die(self.owner))
end

function Fall:canPerform(level)
	local position = self.owner:getPosition()
	if not position then
		return false
	end
	local x, y = position:decompose()
	local cell = level:getCell(x, y)
	if not cell then return false end
	if not cell:has(prism.components.Void) then
		return false
	end
	local cellMask = cell:getCollisionMask()
	local mover = self.owner:get(prism.components.Mover)
	if mover then
		return not prism.Collision.checkBitmaskOverlap(cellMask, mover.mask)
	end
end

return Fall

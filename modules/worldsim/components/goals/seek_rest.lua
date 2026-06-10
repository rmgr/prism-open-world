---@class SeekRestGoal: Goal
---@overload fun(): SeekRestGoal
local SeekRestGoal = prism.components.Goal:extend("SeekRestGoal")

---@param targetZone Vector2
---@param state string
---@param duration integer
function SeekRestGoal:__new(targetZone, state, duration)
	self.super:__new(targetZone, state, duration)
end

function SeekRestGoal:resolve(actor, storage, worldSim)
	local spot = storage:query(prism.components.Landmark, prism.components.RestSpot):first()
	if not spot then
		return false
	end

	local pos = spot:getPosition()
	pos.x = pos.x + 1
	actor:give(prism.components.Position(pos))
	return true
end

function SeekRestGoal:complete(actor, storage, worldSim)
	return true
end

function SeekRestGoal:findLiveTarget(actor, level)
	return level:query(prism.components.Landmark, prism.components.RestSpot):first()
end

return SeekRestGoal

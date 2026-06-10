---@class Goal: Component
---@overload fun(targetZone: Vector2, state: string, duration: integer): Goal
local Goal = prism.Component:extend("Goal")

--- @param targetZone Vector2
--- @param state string
--- @param duration integer
function Goal:__new(targetZone, state, duration)
	self.targetZone = targetZone
	self.state = state
	self.elapsed = 0
	self.duration = duration or 50
end

--- @param actor Actor
--- @param record ZoneRecord
--- @param worldSim WorldSim
--- @param rng RNG
--- @return integer? zx, integer? zy
function Goal:nextZone(actor, record, worldSim, rng)
	local dx = self.targetZone.x - record.zoneX
	local dy = self.targetZone.y - record.zoneY
	if self:isAtTarget(record) then
		return nil
	end -- already there
	local stepX = dx ~= 0 and (dx > 0 and 1 or -1) or 0
	local stepY = (stepX == 0 and dy ~= 0) and (dy > 0 and 1 or -1) or 0
	return record.zoneX + stepX, record.zoneY + stepY
end

--- @param record ZoneRecord   the zone the actor currently sits in
function Goal:isAtTarget(record)
	return self.targetZone.x == record.zoneX and self.targetZone.y == record.zoneY
end

function Goal:tryResolve(actor, storage, worldSim)
	return true
end

function Goal:complete(actor, storage, worldSim)
	return true
end

function Goal:findLiveTarget(actor, level)
	return nil
end

function Goal:liveAction(actor, level)
	return prism.actions.Wait(actor)
end

return Goal

--- Goal that resolves against a FoodSource landmark. On completion, restores
--- 50% of the actor's max satiety (if it has a Satiety component).
--- @class SeekFoodGoal: Goal
--- @overload fun(targetZone: Vector2, state: string, duration: integer): SeekFoodGoal
local SeekFoodGoal = prism.components.Goal:extend("SeekFoodGoal")

function SeekFoodGoal:__new(targetZone, state, duration)
	self.super:__new(targetZone, state, duration)
end

function SeekFoodGoal:resolve(actor, storage, worldSim)
	local spot = storage:query(prism.components.Landmark, prism.components.FoodSource):first()
	if not spot then
		return false
	end
	local pos = spot:getPosition()
	pos.x = pos.x + 1
	actor:give(prism.components.Position(pos))
	return true
end

function SeekFoodGoal:complete(actor, storage, worldSim)
	local satiety = actor:get(prism.components.Satiety)
	if satiety then
		satiety:updateSatiety(math.floor(satiety.maxSatiety))
	end
	return true
end

function SeekFoodGoal:findLiveTarget(actor, level)
	return level:query(prism.components.Landmark, prism.components.FoodSource):first()
end

return SeekFoodGoal

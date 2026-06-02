--- @class WaterSystem : System
local WaterSystem = prism.System:extend("WaterSystem")

function WaterSystem:onMove(level, actor, from, to)
	local x, y = from:decompose()
	local cell = level:getCell(x, y)
	local conditions = actor:get(prism.components.ConditionHolder)
	if conditions then
		if cell:has(prism.components.Water) then
			if not conditions:has(prism.conditions.WaterSpeedCondition) and not actor:has(prism.components.Swimmer) then
				conditions:add(prism.conditions.WaterSpeedCondition(prism.modifiers.SpeedModifier(-50)))
			end
		end
	end
end
return WaterSystem

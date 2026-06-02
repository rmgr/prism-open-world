--- @class SatietySystem : System
local SatietySystem = prism.System:extend("SatietySystem")

function SatietySystem:onTurn(level, actor)
	local satietyComponent = actor:get(prism.components.Satiety)
	if not satietyComponent then
		return
	end

	if satietyComponent.satiety > 0 then
		satietyComponent:updateSatiety(-1)
	end
	if satietyComponent.satiety <= 0 then
		satietyComponent:updateHungryTurns(1)
		if actor:has(prism.components.PlayerController) then
			local health = actor:expect(prism.components.Health)
			if satietyComponent.hungryTurns == 9 then
				if health.hp > 5 then
					level:tryPerform(prism.actions.Damage(actor, 5))
				end

				local Log = prism.components.Log
				Log.addMessage(actor, "Your stomach rumbles")
			end
		end
	end
end

return SatietySystem

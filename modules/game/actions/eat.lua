local Log = prism.components.Log
local Name = prism.components.Name

local InventoryTarget = prism.targets.InventoryTarget(prism.components.Edible):optional()
local FloorTarget = prism.Target(prism.components.Edible):optional()

---@class Eat : Action
---@overload fun(owner: Actor, food: Actor): Eat
local Eat = prism.Action:extend("Eat")

Eat.requiredComponents = {
	prism.components.Health,
}

Eat.targets = {
	InventoryTarget,
	FloorTarget,
}

--- @param level Level
---@param food Actor
function Eat:perform(level, food, food2)
	if not food then
		food = food2
	end
	local edible = food:expect(prism.components.Edible)
	local health = self.owner:expect(prism.components.Health)
	health:heal(edible.healing)

	local satiety = self.owner:get(prism.components.Satiety)
	if satiety then
		satiety:updateSatiety(satiety.satiety + edible.satiety)
	end

	local inventory = self.owner:get(prism.components.Inventory)
	if inventory then
		inventory:removeQuantity(food, 1)
	else
		level:removeActor(food)
	end

	Log.addMessage(self.owner, "You eat the %s.", Name.get(food))
	Log.addMessageSensed(level, self, "%s eats the %s.", Name.get(self.owner), Name.get(food))
end

return Eat

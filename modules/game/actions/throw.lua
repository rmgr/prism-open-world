local Log = prism.components.Log
local Name = prism.components.Name

local InventoryTarget = prism.targets.InventoryTarget(prism.components.Throwable)
local locationTarget = prism.Target():isPrototype(prism.Vector2):range(5)
---@class Throw : Action
---@overload fun(owner: Actor, target: Actor): Throw
local Throw = prism.Action:extend("Throw")

Throw.requiredComponents = {}

Throw.targets = {
	InventoryTarget,
	locationTarget,
}

--- @param level Level
---@param item Actor
---@param target Vector2
function Throw:perform(level, item, target)
	local throwable = item:expect(prism.components.Throwable)
	local sound = item:get(prism.components.Sound)
	local inventory = self.owner:get(prism.components.Inventory)
	if inventory then
		inventory:removeQuantity(item, 1)
	end
	local x, y = target:decompose()
	local targetActor = level:query(prism.components.Controller):at(x, y):first()
	local soundTarget = item
	if targetActor and throwable.damage > 0 then
		soundTarget = targetActor
		local damageAction = prism.actions.Damage(targetActor, throwable.damage)
		level:tryPerform(damageAction)
		Log.addMessage(self.owner, "You throw a %s at the %s.", Name.get(item), Name.get(targetActor))
		Log.addMessageSensed(
			level,
			self,
			"%s throws a %s at %s.",
			Name.get(self.owner),
			Name.get(item),
			Name.get(targetActor)
		)
	else
		item:give(prism.components.Position(self.owner:getPosition()))
		level:addActor(item, x, y)
	end
	local cell = level:getCell(x, y)
	local volume = 5
	if cell then
		if sound then
			volume = sound:getVolume()
		end
	end
	local emitSoundAction = prism.actions.EmitSound(soundTarget, volume, true, true)
	level:tryPerform(emitSoundAction)
end

return Throw

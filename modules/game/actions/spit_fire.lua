local Log = prism.components.Log
local Name = prism.components.Name
local SpitFireTarget = prism.Target(prism.components.Health):isActor():range(3)

--- @class SpitFire: Action
--- @overload fun(owner: Actor, attacked: Actor): SpitFire
local SpitFire = prism.Action:extend("SpitFire")
SpitFire.name = "SpitFire"
SpitFire.targets = { SpitFireTarget }

--- @param level Level
--- @param attacked Actor
function SpitFire:perform(level, attacked)
	local targetPos = attacked:getPosition()
	if not targetPos then
		return
	end

	local x, y = targetPos:decompose()
	local fire = prism.actors.Fire()
	level:addActor(fire, x, y)

	local attackName = Name.lower(attacked)
	local ownerName = Name.lower(self.owner)
	level:yield(prism.messages.AnimationMessage({
		animation = spectrum.animations.Burn(),
		actor = attacked,
	}))
	--[[
	level:yield(prism.messages.AnimationMessage({
		animation = spectrum.animations.SpitFire(self.owner, attacked:getPosition()),
	}))
   ]]
	Log.addMessage(self.owner, "You spit fire at the the %s!", attackName)
	Log.addMessage(attacked, "The %s spits fire at you!", ownerName)
	Log.addMessageSensed(level, self, "The %s spits fire at the %s!", ownerName, attackName)
end

return SpitFire

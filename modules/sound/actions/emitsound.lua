local VolumeTarget = prism.Target():isType("number")
local SkipAnimationsTarget = prism.Target():isType("boolean")
local ShowRadiusTarget = prism.Target():isType("boolean")

---@class EmitSound : Action
---@field volume integer
---@overload fun(owner: Actor, volume: integer): EmitSound
local EmitSound = prism.Action:extend("EmitSound")
EmitSound.targets = { VolumeTarget, SkipAnimationsTarget, ShowRadiusTarget }

function EmitSound:perform(level, volume, skipAnimations, showRadius)
	local position = self.owner:getPosition()
	if not position then
		return
	end

	--[[if skipAnimations then
		level:yield(prism.messages.SkipAnimationsMessage())
	end]]

	if showRadius then
		local ox, oy = position:decompose()
		level:yield(prism.messages.AnimationMessage({
			animation = spectrum.animations.SoundRadiusMarkersExpand(volume, self.owner),
			actor = self.owner,
			skippable = false,
			allowClobber = true,
		}))
	end

	self.owner:give(prism.components.Sound(volume))
end

function EmitSound:canPerform(level)
	return true
end

return EmitSound

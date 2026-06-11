local MoveTarget = prism.Target():isVector2():range(1)

--- @class Move : Action
--- @field name string
--- @field targets Target[]
--- @field previousPosition Vector2
--- @overload fun(owner: Actor, destination: Vector2): Move
local Move = prism.Action:extend("Move")
Move.targets = { MoveTarget }

Move.requiredComponents = {
	prism.components.Controller,
	prism.components.Mover,
}

--- @param level Level
--- @param destination Vector2
function Move:canPerform(level, destination)
	local mover = self.owner:expect(prism.components.Mover)
	return level:getCellPassableByActor(destination.x, destination.y, self.owner, mover.mask)
end

--- @param level Level
--- @param destination Vector2
function Move:perform(level, destination)
	local volume = 5
	local cell = level:getCell(destination.x, destination.y)
	if destination.x > 0 and destination.x <= 31 then
		if destination.y > 0 and destination.y <= 31 then
			if cell then
				local sound = cell:get(prism.components.Sound)
				if sound then
					volume = sound:getVolume()
				end
			end
		end
		local isPlayer = self.owner:has(prism.components.PlayerController)
		local emitSoundAction = prism.actions.EmitSound(self.owner, volume, isPlayer, isPlayer)
		--	level:getSystem(prism.systems.SoundSystem):playSound(level, destination.x, destination.y, volume, self.owner)
		level:moveActor(self.owner, destination)
		level:tryPerform(emitSoundAction)
	end
end

return Move

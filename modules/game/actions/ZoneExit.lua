--- Action performed when the player steps onto a zone-exit tile
--- (a map edge cell, a world portal, etc.).
--- Mirrors the pattern of Descend: removes the actor from the level, then
--- yields a message that GameLevelState catches to drive the transition.
---
--- @class ZoneExit : Action
--- @overload fun(owner: Actor, targetZoneX: integer, targetZoneY: integer, spawnX: integer, spawnY: integer): ZoneExit
local ZoneExit = prism.Action:extend("ZoneExit")

ZoneExit.requiredComponents = {
	prism.components.Controller,
	prism.components.Mover,
}

-- No targets — the zone coords are baked into the action at construction.
ZoneExit.targets = {}

--- @param owner Actor
--- @param targetZoneX integer
--- @param targetZoneY integer
--- @param spawnX integer   Where to place the actor in the destination zone
--- @param spawnY integer
function ZoneExit:__new(owner, targetZoneX, targetZoneY, spawnX, spawnY)
	self.super.__new(self, owner)
	self.targetZoneX = targetZoneX
	self.targetZoneY = targetZoneY
	self.spawnX = spawnX
	self.spawnY = spawnY
end

--- @param level Level
function ZoneExit:perform(level)
	-- Remove the actor from the level first, exactly like Descend does.
	-- This prevents any further system callbacks on the departing actor.
	level:removeActor(self.owner)

	-- Yield the message. GameLevelState:handleMessage will catch this.
	level:yield(
		prism.messages.EnterZoneMessage(self.owner, self.targetZoneX, self.targetZoneY, self.spawnX, self.spawnY)
	)
end

return ZoneExit

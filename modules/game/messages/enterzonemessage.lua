--- Message yielded by the ZoneExit action when the player walks off the edge
--- of the current zone (or uses a world-map portal, etc.).
--- GameLevelState listens for this and triggers deflation + hydration.
---
--- @class EnterZoneMessage : Message
--- @field traveller Actor      The actor crossing the zone boundary (usually the player)
--- @field targetZoneX integer  Destination zone X
--- @field targetZoneY integer  Destination zone Y
--- @field spawnX integer       Tile X to place the player at in the new zone
--- @field spawnY integer       Tile Y to place the player at in the new zone
local EnterZoneMessage = prism.Message:extend("EnterZoneMessage")

function EnterZoneMessage:__new(traveller, targetZoneX, targetZoneY, spawnX, spawnY)
	self.traveller = traveller
	self.targetZoneX = targetZoneX
	self.targetZoneY = targetZoneY
	self.spawnX = spawnX
	self.spawnY = spawnY
end

return EnterZoneMessage

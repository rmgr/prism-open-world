--- ZoneRecord is the in-memory truth for a zone: its dormant actor storage,
--- identity, and sim bookkeeping. It holds NO cells and NO room graph — those
--- live in the per-zone file on disk (see ZoneFile). This keeps the record
--- small and reference-clean, and keeps the serialised WorldSim blob free of
--- terrain.
---
--- Extends prism.Object so it serialises inside WorldSim — the deserialiser
--- reconstructs it by class name and restores its metatable after a load.
---
--- @class ZoneRecord : Object
--- @field zoneX integer
--- @field zoneY integer
--- @field seed string
--- @field storage ActorStorage              dormant actors currently in this zone
--- @field hasBeenVisited boolean             the PLAYER has been here at least once
--- @field visitCount integer
--- @field lastSimTick integer
--- @overload fun(zoneX: integer, zoneY: integer, seed: string): ZoneRecord
local ZoneRecord = prism.Object:extend("ZoneRecord")

--- @param zoneX integer
--- @param zoneY integer
--- @param seed string
function ZoneRecord:__new(zoneX, zoneY, seed)
	self.zoneX = zoneX
	self.zoneY = zoneY
	self.seed = seed
	self.storage = prism.ActorStorage()
	self.hasBeenVisited = false
	self.visitCount = 0
	self.lastSimTick = 0
end

return ZoneRecord


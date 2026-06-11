--- ZoneRecord is the single source of truth for a zone's state.
--- Extends prism.Object so it serialises correctly inside WorldSim — the
--- deserialiser reconstructs it by class name from prism._OBJECTREGISTRY,
--- restoring its metatable (and any methods) after a load.
---
--- @class ZoneRecord : Object
--- @field zoneX integer
--- @field zoneY integer
--- @field seed string
--- @field storage ActorStorage
--- @field cellOverrides table<string, Cell>   
--- @field roomGraph table
--- @field generator table?                   
--- @field hasBeenVisited boolean 
--- @field visitCount integer
--- @field lastSimTick integer
--- @overload fun(zoneX: integer, zoneY: integer, seed: string): ZoneRecord
local ZoneRecord = prism.Object:extend("ZoneRecord")

--- @param zoneX integer
--- @param zoneY integer
--- @param seed string
function ZoneRecord:__new(zoneX, zoneY, seed)
    self.zoneX          = zoneX
    self.zoneY          = zoneY
    self.seed           = seed
    self.storage        = prism.ActorStorage()
    self.cellOverrides  = {}
    self.roomGraph      = nil
    self.generator      = nil
    self.hasBeenVisited = false
    self.visitCount     = 0
    self.lastSimTick    = 0
end

return ZoneRecord
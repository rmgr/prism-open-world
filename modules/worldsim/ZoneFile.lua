--- ZoneFile is the on-disk payload for a single zone: its cells and room
--- graph, and NOTHING ELSE. Specifically: no actors and no actor references.
---
--- This is the load-bearing rule of the per-zone file architecture.
--- Object.serialize is reference-aware only WITHIN one call — identity is
--- preserved inside a single blob and lost across separate ones. The dormant
--- actor graph is laced with cross-zone references (Goal.itemRef, Home
--- relations, Job stages, SmartTerrain.occupants), so splitting actors across
--- per-zone files would deserialise duplicates with diverging state. Actors
--- therefore stay in WorldSim's single in-memory graph (saved as one blob,
--- like the whole-game save); only reference-free terrain lives in zone files.
---
--- @class ZoneFile : Object
--- @field cells table         list of { x, y, cell } produced from a builder/level
--- @field roomGraph table
--- @overload fun(cells: table, roomGraph: table?): ZoneFile
local ZoneFile = prism.Object:extend("ZoneFile")

--- @param cells table
--- @param roomGraph table?
function ZoneFile:__new(cells, roomGraph)
	self.cells = cells or {}
	self.roomGraph = roomGraph or {}
end

return ZoneFile

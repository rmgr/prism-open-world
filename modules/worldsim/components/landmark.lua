--- Landmark marks an actor as a point of interest inside a zone and carries
--- its identity metadata (what kind of place it is, for display/debugging).
---
--- What a landmark OFFERS is expressed as capability MARKER components on the
--- same actor — registered inline below (the beetle.lua pattern: the registry
--- scanner requires this file once, the inline prism.register calls run, and
--- the file returns Landmark as its own registrable). Goal subclasses query
--- for the capability they need; the query system filters natively:
---
---     storage:query(prism.components.Landmark, prism.components.RestSpot)
---
--- Markers compose as a set (a watering hole is Landmark + Water + FoodSource)
--- and work identically on live levels, dormant zone storage, and allActors.

--- Capability marker: offers rest. Queried by SeekRestGoal / Rest-need scoring.
--- @class RestSpot : Component
--- @overload fun(): RestSpot
prism.register(prism.Component:extend("RestSpot"))

--- Capability marker: offers food. Queried by forage/hunger goals.
--- @class FoodSource : Component
--- @overload fun(): FoodSource
prism.register(prism.Component:extend("FoodSource"))

--- Capability marker: offers water.
--- @class WaterSource : Component
--- @overload fun(): WaterSource
prism.register(prism.Component:extend("WaterSource"))

--- @class Landmark : Component
--- @field type string   e.g. "campsite", "watering_hole" — identity, not queried
--- @overload fun(type: string): Landmark
local Landmark = prism.Component:extend("Landmark")

--- @param landmarkType string
function Landmark:__new(landmarkType)
	self.type = landmarkType
end

return Landmark

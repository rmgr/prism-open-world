--- Landmark marks an actor as a point of interest inside a zone — a campsite,
--- a farmhouse, a water source, etc. Landmarks are real actors with a Position,
--- so they survive deflation in ActorStorage and are queryable identically on
--- live levels and dormant zones:
---
---     level:query(prism.components.Landmark)            -- live
---     record.storage:query(prism.components.Landmark)   -- dormant
---
--- The `type` is the specific landmark ("campsite"); `tags` is the category set
--- ({ shelter = true, food_source = true }) used for broad queries.
---
--- @class Landmark : Component
--- @field type string
--- @field tags table<string, boolean>
--- @overload fun(type: string, tags: string[]): Landmark
local Landmark = prism.Component:extend("Landmark")

--- @param landmarkType string
--- @param tags string[]?
function Landmark:__new(landmarkType, tags)
    self.type = landmarkType
    self.tags = {}
    for _, tag in ipairs(tags or {}) do
        self.tags[tag] = true
    end
end

--- @param tag string
--- @return boolean
function Landmark:hasTag(tag)
    return self.tags[tag] == true
end

return Landmark

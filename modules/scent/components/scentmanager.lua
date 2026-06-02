--- ScentManager Component
--- Stores the scent map for a level
--- Should be attached to a dedicated actor for serialization purposes
--- @class ScentManager : Component
--- @field scentMap SparseGrid Maps positions to {actor, strength} tables
--- @field dirty boolean
local ScentManager = prism.Component:extend("ScentManager")

function ScentManager:__new()
	self.scentMap = prism.SparseGrid()
	self.dirty = true
end

--- Clear all scents from the map
function ScentManager:clear()
	self.scentMap:clear()
end

--- Do we need a rebuild?
--- @return boolean
function ScentManager:isDirty()
	return self.dirty
end

--- We need a rebuild.
--- @param value boolean
function ScentManager:setDirty(value)
	self.dirty = value or true
end

--- Get all scents at a specific position
--- @param x integer
--- @param y integer
--- @return table? Map of {actor, strength} or nil if no scents
function ScentManager:getScent(x, y)
	return self.scentMap:get(x, y)
end

--- Set a scent at a specific position
--- @param x integer
--- @param y integer
--- @param actor Actor The actor emitting the scent
--- @param strength integer The strength of the scent at this position
function ScentManager:setScent(x, y, actor, strength)
	local scents = self.scentMap:get(x, y) or {}
	scents = { actor = actor, strength = strength }
	self.scentMap:set(x, y, scents)
end

--- Remove a specific actor's scent from a position
--- @param x integer
--- @param y integer
function ScentManager:removeScent(x, y)
	self.scentMap:set(x, y, nil)
end

return ScentManager

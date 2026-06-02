---@class LevelWithRooms: Level
---@field rooms: table
---@overload fun(builder:LevelBuilder, rooms: table)
local LevelWithRooms = prism.Level:extend("LevelWithRooms")

function LevelWithRooms:__new(builder)
	self.super:__new(builder)
	self.rooms = {}
end
---
--- Finds a path between two positions.
---@param start Vector2 The starting position.
---@param goal Vector2 The goal position.
---@param actor Actor The actor to find a path for.
---@param minDistance? integer The minimum distance away to pathfind to.
---@param distanceType? DistanceType An optional distance type to use for calculating the minimum distance. Defaults to prism._defaultDistance.
---@param passableCallback function
---@return Path? path A path to the goal, or nil if a path could not be found or the start is already at the minimum distance.
function LevelWithRooms:findPath(start, goal, actor, minDistance, distanceType, passableCallback)
	if not self.map:isInBounds(start.x, start.y) or not self.map:isInBounds(goal.x, goal.y) then
		return
	end

	self.actorStorage:removeSparseMapEntries(actor)
	local path = prism.astar(start, goal, passableCallback, nil, minDistance, distanceType)
	self.actorStorage:insertSparseMapEntries(actor)

	return path
end

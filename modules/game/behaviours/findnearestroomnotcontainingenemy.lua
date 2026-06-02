--- @class FindNearestRoomNotContainingEnemyBehaviour : BehaviorTree.Node
local FindNearestRoomNotContainingEnemyBehaviour =
	prism.BehaviorTree.Node:extend("FindNearestRoomNotContainingEnemyBehaviour")
--- @param self BehaviorTree.Node
--- @param level LevelWithRooms
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function FindNearestRoomNotContainingEnemyBehaviour:run(level, actor, controller)
	-- Helper function to find room containing a position
	local function findRoomContaining(rooms, pos)
		for roomId, room in pairs(rooms) do
			if pos.x >= room.x and pos.x < room.x + room.w and pos.y >= room.y and pos.y < room.y + room.h then
				return roomId, room
			end
		end
		return nil, nil
	end

	local actorPos = actor:getPosition()
	if not actorPos then
		return false
	end

	---@cast enemy Actor
	local enemy = controller.blackboard.short["target"]
	if not enemy then
		-- No enemy, clear cache
		controller.blackboard.long["enemy_room_cache"] = nil
		controller.blackboard.long["room_target"] = nil
		return false
	end

	local enemyPos = nil
	if prism.Actor:is(enemy) then
		enemyPos = enemy:getPosition()
	end

	if not enemyPos then
		-- Enemy position unknown, clear cache
		controller.blackboard.long["enemy_room_cache"] = nil
		controller.blackboard.long["room_target"] = nil
		return false
	end

	-- Find which room contains the enemy
	local enemyRoomId = findRoomContaining(level.rooms.rooms, enemyPos)

	-- Check if we already have a valid target room
	local roomTarget = controller.blackboard.long["room_target"]
	local cachedEnemyRoom = controller.blackboard.long["enemy_room_cache"]

	-- Check if actor has reached their target room
	if roomTarget then
		local myRoomId = findRoomContaining(level.rooms.rooms, actorPos)
		local targetRoomId = findRoomContaining(level.rooms.rooms, roomTarget)

		if myRoomId and targetRoomId and myRoomId == targetRoomId then
			-- Reached target room, clear cache and succeed
			controller.blackboard.long["enemy_room_cache"] = nil
			controller.blackboard.long["room_target"] = nil
			return false
		end
	end

	if roomTarget and cachedEnemyRoom == enemyRoomId then
		-- Enemy hasn't changed rooms, keep the same target
		return true
	end

	-- Enemy changed rooms or we don't have a target, find a new safe room
	controller.blackboard.long["enemy_room_cache"] = enemyRoomId

	-- Find nearest room that doesn't contain the enemy
	local nearestRoom = nil
	local nearestDistSq = math.huge

	for roomId, room in pairs(level.rooms.rooms) do
		if roomId ~= enemyRoomId then
			local centerX = room.x + room.w * 0.5
			local centerY = room.y + room.h * 0.5
			local dx = centerX - actorPos.x
			local dy = centerY - actorPos.y
			local distSq = dx * dx + dy * dy

			if distSq < nearestDistSq then
				nearestDistSq = distSq
				nearestRoom = room
			end
		end
	end
	if not nearestRoom then
		controller.blackboard.long["enemy_room_cache"] = nil
		controller.blackboard.long["room_target"] = nil
		return false
	end

	-- Store the nearest room's center as the target
	local targetPos = prism.Vector2(nearestRoom.x + nearestRoom.w * 0.5, nearestRoom.y + nearestRoom.h * 0.5)
	controller.blackboard.long["room_target"] = targetPos
	controller.blackboard.short["target"] = targetPos
	return true
end
return FindNearestRoomNotContainingEnemyBehaviour

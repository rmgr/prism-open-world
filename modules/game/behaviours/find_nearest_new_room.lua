--- @class FindNearestNewRoomBehaviour : BehaviorTree.Node
local FindNearestNewRoomBehaviour = prism.BehaviorTree.Node:extend("FindNearestNewRoomBehaviour")
--- @param self BehaviorTree.Node
--- @param level LevelWithRooms
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function FindNearestNewRoomBehaviour:run(level, actor, controller)
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

	-- Check if we already have a valid target room
	local prevRoomTarget = controller.blackboard.long["prev_room"]
	local roomTarget = controller.blackboard.long["room_target"]

	local prevRoomId
	if prevRoomTarget then
		prevRoomId = findRoomContaining(level.rooms.rooms, prevRoomTarget)
	end
	local myRoomId = findRoomContaining(level.rooms.rooms, actorPos)
	-- Check if actor has reached their target room
	if roomTarget then
		local targetRoomId = findRoomContaining(level.rooms.rooms, roomTarget)
		if myRoomId and targetRoomId and myRoomId == targetRoomId then
			-- Reached target room, clear cache and succeed
			controller.blackboard.long["prev_room"] = controller.blackboard.long["room_target"]
			controller.blackboard.long["room_target"] = nil
			roomTarget = nil
		end
	end

	if roomTarget then
		controller.blackboard.short["target"] = roomTarget
		return true
	end

	-- Find nearest room that doesn't contain the enemy
	local nearestRoom = nil
	local nearestDistSq = math.huge

	for roomId, room in pairs(level.rooms.rooms) do
		if roomId ~= prevRoomId and roomId ~= myRoomId then
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
		controller.blackboard.long["room_target"] = nil

		return false
	end

	-- Store the nearest room's center as the target
	local targetPos =
		prism.Vector2(math.floor(nearestRoom.x + nearestRoom.w * 0.5), math.floor(nearestRoom.y + nearestRoom.h * 0.5))

	level:addActor(
		prism.Actor.fromComponents({
			prism.components.Name("debug"),
			prism.components.Drawable({ index = "!", color = prism.Color4.PINK, layer = math.huge }),
			prism.components.Position(),
		}),
		targetPos.x,
		targetPos.y
	)
	controller.blackboard.long["room_target"] = targetPos
	controller.blackboard.short["target"] = targetPos
	return true
end
return FindNearestNewRoomBehaviour

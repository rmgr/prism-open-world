--- @class FindRandomRoomBehaviour : BehaviorTree.Node
local FindRandomRoomBehaviour = prism.BehaviorTree.Node:extend("FindRandomRoomBehaviour")
--- @param self BehaviorTree.Node
--- @param level LevelWithRooms
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function FindRandomRoomBehaviour:run(level, actor, controller)
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
	local roomTarget = controller.blackboard.long["room_target"]

	local myRoomId = findRoomContaining(level.rooms.rooms, actorPos)
	-- Check if actor has reached their target room
	if roomTarget then
		local targetRoomId = findRoomContaining(level.rooms.rooms, roomTarget)
		if myRoomId and targetRoomId and myRoomId == targetRoomId then
			-- Reached target room, clear cache and succeed
			controller.blackboard.long["room_target"] = nil
		else
			controller.blackboard.short["target"] = roomTarget
			return true
		end
	end

	local roomList = {}
	for roomId, room in pairs(level.rooms.rooms) do
		if roomId ~= myRoomId then
			table.insert(roomList, room)
		end
	end

	if #roomList > 0 then
		local selectedRoom = roomList[math.random(#roomList)]

		-- Store the nearest room's center as the target
		local targetPos = prism.Vector2(
			math.floor(selectedRoom.x + selectedRoom.w * 0.5),
			math.floor(selectedRoom.y + selectedRoom.h * 0.5)
		)
		--[[
      --for debugging
      level:addActor(
			prism.Actor.fromComponents({
				prism.components.Name("debug"),
				prism.components.Drawable({ index = "!", color = prism.Color4.PINK, layer = math.huge }),
				prism.components.Position(),
			}),
			targetPos.x,
			targetPos.y
		)]]
		controller.blackboard.long["room_target"] = targetPos
		controller.blackboard.short["target"] = targetPos
	end
	return true
end
return FindRandomRoomBehaviour

---@class RoomGraph
---@field rooms table<integer, table>
---@field connections table<integer, integer[]>
---@field roomIdCounter integer

---@class RoomManager
---@field roomGraph RoomGraph
local RoomManager = {
	roomGraph = {
		rooms = {},
		connections = {},
		roomIdCounter = 0,
	},
}

function RoomManager:new()
	self.roomGraph = {
		rooms = {},
		connections = {},
		roomIdCounter = 0,
	}
	return self
end

function RoomManager:reset()
	self.roomGraph = {
		rooms = {},
		connections = {},
		roomIdCounter = 0,
	}
end

function RoomManager:createRoomId()
	self.roomGraph.roomIdCounter = self.roomGraph.roomIdCounter + 1
	return self.roomGraph.roomIdCounter
end

function RoomManager:addRoom(room)
	room.id = self:createRoomId()
	self.roomGraph.rooms[room.id] = room
	self.roomGraph.connections[room.id] = {}
	return room.id
end

function RoomManager:connectRooms(room1Id, room2Id)
	if not self.roomGraph.connections[room1Id] then
		self.roomGraph.connections[room1Id] = {}
	end
	if not self.roomGraph.connections[room2Id] then
		self.roomGraph.connections[room2Id] = {}
	end

	for _, connId in ipairs(self.roomGraph.connections[room1Id]) do
		if connId == room2Id then
			return
		end
	end

	table.insert(self.roomGraph.connections[room1Id], room2Id)
	table.insert(self.roomGraph.connections[room2Id], room1Id)
end

function RoomManager:getRoomAtPosition(x, y)
	for _, room in pairs(self.roomGraph.rooms) do
		if x >= room.x and x < room.x + room.w and y >= room.y and y < room.y + room.h then
			return room
		end
	end
	return nil
end

function RoomManager:getRoomNeighbors(roomId)
	return self.roomGraph.connections[roomId] or {}
end

function RoomManager:getRooms()
	return self.roomGraph.rooms
end

function RoomManager:getConnections()
	return self.roomGraph.connections
end

return RoomManager

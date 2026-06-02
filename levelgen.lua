local BspGenerator = {}
BspGenerator.__index = BspGenerator

-- Debug mode: when true, generates a simple test map instead of BSP dungeon

-- Configuration constants
BspGenerator.MIN_PARTITION_SIZE = 8
BspGenerator.MAX_DEPTH = 14

function BspGenerator.new()
	local self = setmetatable({}, BspGenerator)
	self.roomGraph = {
		rooms = {},
		connections = {},
		roomIdCounter = 0,
	}
	return self
end

--- Create a unique room ID
function BspGenerator:createRoomId()
	self.roomGraph.roomIdCounter = self.roomGraph.roomIdCounter + 1
	return self.roomGraph.roomIdCounter
end

--- Add a room to the graph
function BspGenerator:addRoomToGraph(room)
	room.id = self:createRoomId()
	self.roomGraph.rooms[room.id] = room
	self.roomGraph.connections[room.id] = {}
	return room.id
end

--- Add a connection between two rooms
function BspGenerator:connectRooms(room1Id, room2Id)
	if not self.roomGraph.connections[room1Id] then
		self.roomGraph.connections[room1Id] = {}
	end
	if not self.roomGraph.connections[room2Id] then
		self.roomGraph.connections[room2Id] = {}
	end

	-- Check if already connected
	for _, connId in ipairs(self.roomGraph.connections[room1Id]) do
		if connId == room2Id then
			return
		end
	end

	-- Add bidirectional connection
	table.insert(self.roomGraph.connections[room1Id], room2Id)
	table.insert(self.roomGraph.connections[room2Id], room1Id)
end

--- Get room at position (for AI queries)
function BspGenerator:getRoomAtPosition(x, y)
	for _, room in pairs(self.roomGraph.rooms) do
		if x >= room.x and x < room.x + room.w and y >= room.y and y < room.y + room.h then
			return room
		end
	end
	return nil
end

--- Get neighbors of a room (for pathfinding)
function BspGenerator:getRoomNeighbors(roomId)
	return self.roomGraph.connections[roomId] or {}
end

--- Split a partition into two smaller partitions
function BspGenerator:split(partition, rng)
	local splitVertical = partition.w > partition.h
	local minSplit = math.floor((splitVertical and partition.w or partition.h) * 0.4)
	local maxSplit = math.floor((splitVertical and partition.w or partition.h) * 0.6)
	local splitPoint = rng:random(minSplit, maxSplit)

	if splitVertical then
		return {
			x = partition.x,
			y = partition.y,
			w = splitPoint,
			h = partition.h,
		}, {
			x = partition.x + splitPoint,
			y = partition.y,
			w = partition.w - splitPoint,
			h = partition.h,
		}
	else
		return {
			x = partition.x,
			y = partition.y,
			w = partition.w,
			h = splitPoint,
		}, {
			x = partition.x,
			y = partition.y + splitPoint,
			w = partition.w,
			h = partition.h - splitPoint,
		}
	end
end

function BspGenerator:splitPartition(partition, depth, rng)
	if
		partition.w < self.MIN_PARTITION_SIZE * 2
		or partition.h < self.MIN_PARTITION_SIZE * 2
		or depth >= self.MAX_DEPTH
	then
		return partition
	end

	local left, right = self:split(partition, rng)
	partition.left = self:splitPartition(left, depth + 1, rng)
	partition.right = self:splitPartition(right, depth + 1, rng)
	return partition
end

function BspGenerator:generateBspTree(width, height, rng)
	return self:splitPartition({ x = 1, y = 1, w = width, h = height }, 0, rng)
end

function BspGenerator:getAnyLeafRoom(partition)
	if not partition then
		return nil
	end

	if partition.room then
		return partition
	end

	return self:getAnyLeafRoom(partition.left) or self:getAnyLeafRoom(partition.right)
end

function BspGenerator:createLShapedCorridor(room1, room2, builder, rng)
	local x1, y1 = room1.centerX, room1.centerY
	local x2, y2 = room2.centerX, room2.centerY

	if rng:random() > 0.5 then
		builder:line(x1, y1, x2, y1, prism.cells.Floor)
		builder:line(x2, y1, x2, y2, prism.cells.Floor)
	else
		builder:line(x1, y1, x1, y2, prism.cells.Floor)
		builder:line(x1, y2, x2, y2, prism.cells.Floor)
	end

	if room1.id and room2.id then
		self:connectRooms(room1.id, room2.id)
	end
end

function BspGenerator:connectSiblings(partition, builder, rng)
	if not partition or not partition.left or not partition.right then
		return
	end

	self:connectSiblings(partition.left, builder, rng)
	self:connectSiblings(partition.right, builder, rng)

	local leftRoom = self:getAnyLeafRoom(partition.left)
	local rightRoom = self:getAnyLeafRoom(partition.right)

	if leftRoom and rightRoom and leftRoom.room and rightRoom.room then
		self:createLShapedCorridor(leftRoom.room, rightRoom.room, builder, rng)
	end
end

function BspGenerator:collectAllRooms(partition, rooms)
	if not partition then
		return
	end

	if partition.room then
		table.insert(rooms, partition.room)
	end

	self:collectAllRooms(partition.left, rooms)
	self:collectAllRooms(partition.right, rooms)
end

function BspGenerator:addExtraConnections(bspTree, builder, rng, numConnections)
	local allRooms = {}
	self:collectAllRooms(bspTree, allRooms)

	for i = 1, numConnections do
		if #allRooms < 2 then
			break
		end

		local room1 = allRooms[rng:random(#allRooms)]
		local room2 = allRooms[rng:random(#allRooms)]

		if room1 ~= room2 then
			self:createLShapedCorridor(room1, room2, builder, rng)
		end
	end
end

function BspGenerator:addRandomPits(builder, width, height, rng)
	local noiseOffsetX = rng:random(1, 10000)
	local noiseOffsetY = rng:random(1, 10000)
	local noiseScale = 5
	local pitThreshold = 0.5

	for x = 1, width do
		for y = 1, height do
			local noise = love.math.noise(x / noiseScale + noiseOffsetX, y / noiseScale + noiseOffsetY)
			if noise > pitThreshold then
				builder:set(x, y, prism.cells.Pit())
			end
		end
	end
end

function BspGenerator:createRoom(builder, x, y, w, h, rng)
	local roomW = rng:random(self.ROOM_SIZE_MIN, w - 2)
	local roomH = rng:random(self.ROOM_SIZE_MIN, h - 2)
	local roomX = x + rng:random(0, w - roomW - 1)
	local roomY = y + rng:random(0, h - roomH - 1)
	local centerX = roomX + math.floor(roomW / 2)
	local centerY = roomY + math.floor(roomH / 2)
	local room = {
		x = roomX,
		y = roomY,
		w = roomW,
		h = roomH,
		centerX = centerX,
		centerY = centerY,
	}
	self:addRoomToGraph(room)
	local roomShape = rng:random() > 0.5 and "circle" or "square"
	local noiseOffsetX = rng:random(1, 10000)
	local noiseOffsetY = rng:random(1, 10000)
	local noiseScale = 3
	local noiseThreshold = 0.6

	-- Collect valid floor positions
	local validPositions = {}

	for _x = roomX, roomX + roomW - 1 do
		for _y = roomY, roomY + roomH - 1 do
			local shouldPlace = true
			if roomShape == "circle" then
				local radius = math.min(roomW, roomH) / 2
				shouldPlace = self:insideCircle(centerX, centerY, _x, _y, radius)
			end
			if shouldPlace then
				local noise = love.math.noise(_x / noiseScale + noiseOffsetX, _y / noiseScale + noiseOffsetY)
				if noise > noiseThreshold then
					builder:set(_x, _y, prism.cells.Floor())
					table.insert(validPositions, { x = _x, y = _y })
				elseif noise < noiseThreshold and noise > 0.4 then
					builder:set(_x, _y, prism.cells.Grass())
				else
					builder:set(_x, _y, prism.cells.Gravel())
				end
			end
		end
	end
	if SPAWN_ENEMIES then
		-- Place random number of enemies
		local enemies = {
			prism.actors.Beetle,
			prism.actors.Kobold,
			prism.actors.Kobold,
			prism.actors.Kobold,
			prism.actors.Salamander,
			prism.actors.Olm,
		}

		local numEnemies = rng:random(0, 3) -- 0 to 3 enemies per room

		for i = 1, numEnemies do
			if #validPositions > 0 then
				local enemyType = enemies[rng:random(1, #enemies)]
				local actor = enemyType()

				if actor:has(prism.components.Olm) then
					if roomShape == "square" then
						local rect = prism.Rectangle(room.x, room.y, room.w, room.h)
						local corners = rect:toCorners()
						local randCorner = corners[rng:random(1, #corners)]
						builder:addActor(actor, randCorner.x, randCorner.y - 1)
					end
				else --if actor:has(prism.components.Kobold) then
					-- Pick random valid position and remove it from the list
					local posIndex = rng:random(1, #validPositions)
					local pos = validPositions[posIndex]
					table.remove(validPositions, posIndex)
					builder:addActor(actor, pos.x, pos.y)
				end
			end
		end
	end
	return room
end

function BspGenerator:insideCircle(centerX, centerY, tileX, tileY, radius)
	local dx = centerX - tileX
	local dy = centerY - tileY
	local distance = math.sqrt(dx * dx + dy * dy)
	return distance <= radius
end

function BspGenerator:generate(rng, player, width, height, builder)
	if not builder then
		builder = prism.LevelBuilder(prism.cells.Wall)
	end

	-- Reset graph for new generation
	self.roomGraph = {
		rooms = {},
		connections = {},
		roomIdCounter = 0,
	}

	-- Debug mode: generate simple test map
	if DEBUG then
		-- Outer wall border
		builder:rectangle("line", 0, 0, 32, 32, prism.cells.Wall)
		-- Fill the interior with floor tiles
		builder:rectangle("fill", 1, 1, 31, 31, prism.cells.Floor)
		-- Add a small block of walls within the map
		builder:rectangle("fill", 5, 5, 7, 7, prism.cells.Wall)
		-- Add a pit area to the southeast
		builder:rectangle("fill", 20, 20, 25, 25, prism.cells.Pit)
		-- Place the player character at a starting location
		builder:addActor(player, 12, 12)

		return builder
	end

	local bspTree = self:generateBspTree(width, height, rng)
	local visited = {}
	local stack = { bspTree }
	local placedPlayer = false

	-- Fill with walls
	for x = 1, width do
		for y = 1, height do
			builder:set(x, y, prism.cells.Wall())
		end
	end
	self:addRandomPits(builder, width, height, rng)

	-- Create rooms and add to graph
	while #stack > 0 do
		local item = table.remove(stack)
		if not visited[item] then
			visited[item] = true
			if item.left then
				table.insert(stack, item.left)
			end
			if item.right then
				table.insert(stack, item.right)
			end
			if not item.left and not item.right then
				if item.x + item.w < width and item.y + item.h < width and item.x - item.w > 0 and item.y - item.h then
					local room = self:createRoom(builder, item.x, item.y, item.w, item.h, rng)
					if not placedPlayer then
						builder:addActor(player, room.centerX, room.centerY)
						placedPlayer = true
					end
					item.room = room
				end
			end
		end
	end

	self:connectSiblings(bspTree, builder, rng)

	local extraConnections = rng:random(6, 10)
	self:addExtraConnections(bspTree, builder, rng, extraConnections)

	builder:pad(1, prism.cells.Wall)

	return builder
end

return function(rng, player, width, height, builder)
	local generator = BspGenerator.new()
	local result = generator:generate(rng, player, width, height, builder)
	return result, generator.roomGraph
end

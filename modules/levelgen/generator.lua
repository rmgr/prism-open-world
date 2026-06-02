local BspGenerator = prism.levelgen.util.BspGenerator
local RoomManager = prism.levelgen.util.RoomManager

local SPAWN_ENEMIES = true
local ROOM_SIZE_MIN = 10

--- @class GeneratorInfo
--- @field w integer
--- @field h integer
--- @field seed any
--- @field depth integer

--- @class Generator : Object
local Generator = prism.Object:extend("Generator")

--- @param generatorInfo GeneratorInfo
--- @param player Actor
--- @param rng RNG
function Generator.generate(generatorInfo, player, rng)
	error("This must be overriden!")
end

function Generator:insideCircle(centerX, centerY, tileX, tileY, radius)
	local dx = centerX - tileX
	local dy = centerY - tileY
	local distance = math.sqrt(dx * dx + dy * dy)
	return distance <= radius
end

function Generator:createRoom(builder, x, y, w, h, rng)
	local roomW = rng:random(ROOM_SIZE_MIN, w - 2)
	local roomH = rng:random(ROOM_SIZE_MIN, h - 2)
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
	RoomManager:addRoom(room)
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
				builder:set(_x, _y, prism.cells.Floor())
			end
		end
	end
	return room
end
function Generator:createLShapedCorridor(room1, room2, builder, rng)
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
		RoomManager:connectRooms(room1.id, room2.id)
	end
end

function Generator:connectSiblings(partition, builder, rng)
	if not partition or not partition.left or not partition.right then
		return
	end

	self:connectSiblings(partition.left, builder, rng)
	self:connectSiblings(partition.right, builder, rng)

	local leftRoom = BspGenerator:getAnyLeafRoom(partition.left)
	local rightRoom = BspGenerator:getAnyLeafRoom(partition.right)

	if leftRoom and rightRoom and leftRoom.room and rightRoom.room then
		self:createLShapedCorridor(leftRoom.room, rightRoom.room, builder, rng)
	end
end

function Generator:addExtraConnections(bspTree, builder, rng, numConnections)
	local allRooms = {}
	BspGenerator:collectAllRooms(bspTree, allRooms)

	for _ = 1, numConnections do
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

return Generator

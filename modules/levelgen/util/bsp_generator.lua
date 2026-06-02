---@class BspGenerator
---@field MIN_PARTITION_SIZE integer
---@field MAX_DEPTH integer
---@field ROOM_SIZE_MIN integer
local BspGenerator = {
	MIN_PARTITION_SIZE = 8,
	MAX_DEPTH = 14,
	ROOM_SIZE_MIN = 10,
}

function BspGenerator:new()
	self.MIN_PARTITION_SIZE = 8
	self.MAX_DEPTH = 14
	self.ROOM_SIZE_MIN = 10
	return self
end
---
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
	if not partition or not partition.w or not partition.h then
		return partition
	end
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

return BspGenerator

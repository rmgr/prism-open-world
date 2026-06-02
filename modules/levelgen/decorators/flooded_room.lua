local FloodedRoomDecorator = prism.levelgen.Decorator:extend("FloodedRoomDecorator")

function FloodedRoomDecorator.tryDecorate(generatorInfo, rng, builder, room)
	local voidEdges = {}
	local newVoidEdges = {}
	local depth = 0
	local maxDepth = 30
	local noiseOffsetX = rng:random(1, 10000)
	local noiseOffsetY = rng:random(1, 10000)
	local noiseScale = 1
	local spreadThreshold = 0.25
	local roomSize = room.h * room.w
	local leechCount = rng:random(roomSize / 16, roomSize / 8)
	local placedLeeches = 0
	for x = room.x, (room.x + room.w) do
		for y = room.y, room.y + room.h do
			local noise = love.math.noise(x / noiseScale + noiseOffsetX, y / noiseScale + noiseOffsetY)
			if noise > spreadThreshold then
				builder:setCell(x, y, prism.cells.Water())
				if placedLeeches < leechCount then
					placedLeeches = placedLeeches + 1
					builder:addActor(prism.actors.Leech(), x, y)
				end
				for _, dir in ipairs(prism.neighborhood) do
					local dx, dy = dir:decompose()
					local cell = builder:getCell(x + dx, dy + y)
					if cell and not cell:has(prism.components.Wall) then
						local nx = x + dx
						local ny = y + dy
						newVoidEdges[nx .. "," .. ny] = prism.Vector2(nx, ny)
					end
				end
			end
		end
	end
	voidEdges = newVoidEdges
	newVoidEdges = {}
	repeat
		if depth == maxDepth then
			break
		end
		for _, pos in pairs(voidEdges) do
			local x, y = pos:decompose()

			local noise = love.math.noise(x / noiseScale + noiseOffsetX, y / noiseScale + noiseOffsetY)
			if noise > spreadThreshold + ((depth * 6) / 100) then
				builder:setCell(x, y, prism.cells.Water())

				for _, dir in ipairs(prism.neighborhood) do
					local dx, dy = dir:decompose()
					local cell = builder:getCell(x + dx, dy + y)
					if cell and not cell:has(prism.components.Wall) then
						local nx = x + dx
						local ny = y + dy
						newVoidEdges[nx .. "," .. ny] = prism.Vector2(nx, ny)
					end
				end
			end
		end
		depth = depth + 1
		voidEdges = newVoidEdges
		newVoidEdges = {}
	until next(voidEdges) == nil -- until #voidEdges == 0
end

return FloodedRoomDecorator

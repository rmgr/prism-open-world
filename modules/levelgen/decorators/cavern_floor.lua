local util = prism.levelgen.util
local CavernFloorDecorator = prism.levelgen.Decorator:extend("CavernFloorDecorator")

function CavernFloorDecorator.tryDecorate(generatorInfo, rng, builder, room)
	local noiseOffsetX = rng:random(1, 10000)
	local noiseOffsetY = rng:random(1, 10000)
	local noiseScale = 3
	local noiseThreshold = 0.6
	for x = room.x, room.x + room.w - 1 do
		for y = room.y, room.y + room.h - 1 do
			local cell = builder:get(x, y)
			if not cell:has(prism.components.Void) then
				local noise = love.math.noise(x / noiseScale + noiseOffsetX, y / noiseScale + noiseOffsetY)
				if noise > noiseThreshold then
					builder:set(x, y, prism.cells.Floor())
				elseif noise < noiseThreshold and noise > 0.2 and noise < 0.35 then
					builder:set(x, y, prism.cells.Grass())
				elseif noise < noiseThreshold and noise > 0.35 then
					builder:set(x, y, prism.cells.TallGrass())
				else
					builder:set(x, y, prism.cells.Gravel())
				end
			end
		end
	end
end
return CavernFloorDecorator

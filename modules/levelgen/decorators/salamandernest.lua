local util = prism.levelgen.util
local SalamanderNestDecorator = prism.levelgen.Decorator:extend("SalamanderNestDecorator")

function SalamanderNestDecorator.tryDecorate(generatorInfo, rng, builder, room)
	builder:addActor(prism.actors.SalamanderNest(), room.centerX, room.centerX)
	local items = {
		prism.actors.MeatBrick,
		prism.actors.MeatBrick,
		prism.actors.MeatBrick,
		prism.actors.MeatBrick,
		prism.actors.LargeBranch,
		prism.actors.LargeBranch,
		prism.actors.LargeBranch,
	}

	for i = 1, rng:random(1 + generatorInfo.depth, 4 + generatorInfo.depth) do
		local x = room.centerX + rng:random(-2, 2) + (rng:random(-1, 1) * (i % 3))
		local y = room.centerY + rng:random(-2, 2) + (rng:random(-1, 1) * (i % 3))
		local cell = builder:get(x, y)
		if not cell:has(prism.components.Void) then
			builder:addActor(prism.actors.Salamander(), x, y)
		end
	end

	for i = 1, rng:random(1 + generatorInfo.depth, 4 + generatorInfo.depth) do
		local item = items[rng:random(1, #items)]
		local x = room.centerX + rng:random(-2, 2) + (rng:random(-1, 1) * (i % 3))
		local y = room.centerY + rng:random(-2, 2) + (rng:random(-1, 1) * (i % 3))

		local cell = builder:get(x, y)
		if not cell:has(prism.components.Void) then
			builder:addActor(item(), x, y)
		end
	end
end
return SalamanderNestDecorator

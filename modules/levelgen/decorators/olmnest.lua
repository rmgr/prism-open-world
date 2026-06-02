local util = prism.levelgen.util
local OlmNestDecorator = prism.levelgen.Decorator:extend("OlmNestDecorator")

function OlmNestDecorator.tryDecorate(generatorInfo, rng, builder, room)
	if generatorInfo.depth > 1 then
		builder:addActor(prism.actors.OlmNest(), room.centerX, room.centerY)
		builder:addActor(prism.actors.Olm(), room.centerX, room.centerY)

		builder:ellipse(
			"fill",
			room.centerX,
			room.centerY,
			math.floor(room.w / 4),
			math.floor(room.h / 4),
			prism.cells.TallGrass
		)
		for i = 1, rng:random(7, 10) do
			local x = room.centerX + rng:random(-i, i) + (rng:random(-i, i))
			local y = room.centerY + rng:random(-i, i) + (rng:random(-i, i))

			builder:set(x, y, prism.cells.TallGrass())
		end
	end
end
return OlmNestDecorator

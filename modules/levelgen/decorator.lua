--- @class Decorator : Object
local Decorator = prism.Object:extend("Decorator")

--- @param generatorInfo GeneratorInfo
--- @param rng RNG
--- @param builder LevelBuilder
--- @param room table
--- @return boolean success
function Decorator.tryDecorate(generatorInfo, rng, builder, room)
	assert("This must be overriden.")
	return false
end

return Decorator

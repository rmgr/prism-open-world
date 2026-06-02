--- Smell Component
--- Allows actors to detect scents in their environment
--- @class SmellOptions
--- @field threshold integer Minimum scent strength to detect (lower = better sense of smell)
--- @field range integer? Maximum distance to smell scents (optional, defaults to 10)

--- @class Smell : Component
--- @field private threshold integer Sensitivity threshold
--- @field private range integer? Detection range
--- @overload fun(options: SmellOptions): Smell
local Smell = prism.Component:extend("Smell")
Smell.requirements = { "Senses" }

function Smell:getRequirements()
	return prism.components.Senses
end

--- @param options SmellOptions
function Smell:__new(options)
	self.threshold = options.threshold or 10
	self.range = options.range or 10
end

--- Get the minimum scent strength this actor can detect
--- Lower values mean better sense of smell
--- @return integer
function Smell:getThreshold()
	return self.threshold
end

--- Get the maximum distance this actor can smell
--- @return integer?
function Smell:getRange()
	return self.range
end

--- Set the sensitivity threshold
--- @param threshold integer
function Smell:setThreshold(threshold)
	self.threshold = threshold
end

--- Set the detection range
--- @param range integer?
function Smell:setRange(range)
	self.range = range
end

return Smell

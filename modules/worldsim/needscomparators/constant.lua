--- Always returns a fixed score. Used for baseline needs that win only
--- when nothing more urgent clears its own threshold (e.g. rest at 0.3).
--- @class ConstantComparator : NeedsComparator
--- @overload fun(value: number): ConstantComparator
local ConstantComparator = prism.worldsim.NeedsComparator:extend("ConstantComparator")

--- @param value number constant urgency score 0..1
function ConstantComparator:__new(value)
	self.value = value or 0
end

function ConstantComparator:compare(actor)
	return self.value
end

return ConstantComparator

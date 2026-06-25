--- Base class for need scoring. A comparator reads only components,
--- so it runs headless in the dormant sim as well as in the live level.
--- @class NeedsComparator : Object
local NeedsComparator = prism.Object:extend("NeedsComparator")

--- Urgency in 0..1. Reads components only. Override.
--- @param actor Actor
--- @return number
function NeedsComparator:compare(actor) return 0 end

return NeedsComparator

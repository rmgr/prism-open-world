--- Holds the actor's needs list. Each entry in the needs table maps a name
--- to a {threshold, score, goal} triple, where score is a NeedsComparator
--- and goal is a NeedsAction. The comparator is the only gating mechanism:
--- a need whose score is below its threshold is never chosen.
---
--- Example construction:
---   prism.components.Needs({
---       safety = { threshold = 0.5, score = prism.needscomparators.HpValueComparator(),   goal = prism.needsactions.SeekRest() },
---       hunger = {                  score = prism.needscomparators.SatietyValueComparator(), goal = prism.needsactions.SeekFood() },
---       rest   = {                  score = prism.needscomparators.ConstantComparator(0.3),  goal = prism.needsactions.SeekRest() },
---   })
---
--- @class NeedEntry
--- @field threshold number?      minimum score before this need is actionable (defaults to 0)
--- @field score NeedsComparator  scores urgency 0..1
--- @field goal NeedsAction       builds the Goal when this need wins

--- @class Needs : Component
--- @field needs table<string, NeedEntry>
--- @overload fun(needs: table<string, NeedEntry>): Needs
local Needs = prism.Component:extend("Needs")

--- @param needs table<string, NeedEntry>
function Needs:__new(needs)
	self.needs = needs or {}
end

return Needs

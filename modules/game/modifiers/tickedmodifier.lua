--- @class TickedConditionModifier : ConditionModifier
--- @overload fun(): TickedConditionModifier
local TickedConditionModifier = prism.condition.ConditionModifier:extend("TickedConditionModifier")

function TickedConditionModifier:__new() end

--- Called every tick while this modifier is active.
--- Override this method in subclasses to implement tick behavior.
--- @param owner Actor
--- @return nil
function TickedConditionModifier:tick(owner) end

return TickedConditionModifier

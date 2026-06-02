--- @class AttackedSystem : System
local AttackedSystem = prism.System:extend("AttackedSystem")

function AttackedSystem:onTurn(level, actor)
	if not actor:has(prism.components.PlayerController) then
		return
	end
	actor:removeAllRelations(prism.relations.AttackedBy)
end

return AttackedSystem

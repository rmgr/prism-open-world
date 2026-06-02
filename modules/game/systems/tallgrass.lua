--- @class TallGrassSystem : System
local TallGrassSystem = prism.System:extend("TallGrassSystem")

function TallGrassSystem:onMove(level, actor, from, to)
	local x, y = from:decompose()
	local cell = level:getCell(x, y)
	if not cell then
		return
	end

	if not cell:has(prism.components.TallGrass) then
		return
	end

	level:setCell(x, y, prism.cells.Grass())
end

return TallGrassSystem

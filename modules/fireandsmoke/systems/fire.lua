local Log = prism.components.Log
--- @class FireSystem : System
--- @overload fun(seed: string): SystemManager
local FireSystem = prism.System:extend("FireSystem")

--- @param seed string
function FireSystem:__new(seed)
	self.rng = prism.RNG(seed)
end

local function biasedRandom(rng)
	return math.min(8, math.ceil(math.sqrt(rng:random(1, 64))))
end

function FireSystem:onTurnEnd(level, actor)
	if actor:has(prism.components.Burning) then
		level:yield(prism.messages.AnimationMessage({
			animation = spectrum.animations.Burn(),
			actor = actor,
		}))
	end
	-- run after the player has acted, effectively once per "loop" of the
	-- actors in the level.
	if not actor:has(prism.components.PlayerController) then
		return
	end
	local flammableCells = {}
	local fires = level:query(prism.components.Fire):gather()
	local burning = level:query(prism.components.Burning):gather()
	local firePositions = {}
	local removeFires = {}
	for _, fire in ipairs(fires) do
		local x, y = fire:getPosition():decompose()
		firePositions[x .. "," .. y] = true
	end
	for _, burner in ipairs(burning) do
		if burner:has(prism.components.Burning) then
			local burningComponent = burner:get(prism.components.Burning)
			if burningComponent then
				burningComponent.fuel = burningComponent.fuel - 1
				if burningComponent.fuel <= 0 then
					burner:remove(burningComponent)
				end
			end
			local x, y = burner:getPosition():decompose()
			local dealt = 1
			local damage = prism.actions.Damage(burner, dealt)
			level:tryPerform(damage)
			Log.addMessage(burner, "You burn for %i damage!", dealt)
			local fire = level:query(prism.components.Fire):at(x, y):first()
			if not fire then
				self:placeFire(x, y, level)
			end
		end
	end
	for _, fire in ipairs(fires) do
		local x, y = fire:getPosition():decompose()
		local actorsAtPosition = level:query(prism.components.Controller):at(x, y):gather()
		for _, actorAtPosition in ipairs(actorsAtPosition) do
			if
				not actorAtPosition:has(prism.components.Fire) and not actorAtPosition:has(prism.components.FireProof)
			then
				actorAtPosition:give(prism.components.Burning())
			end
		end
		local cell = level:getCell(x, y)
		if cell and cell:has(prism.components.Flammable) then
			local fuel = cell:get(prism.components.Flammable)
			if fuel then
				fuel.spentFuel = fuel.spentFuel + 1
				if fuel.spentFuel >= fuel.fuel then
					level:setCell(x, y, prism.cells.Floor())
					table.insert(removeFires, fire)
				end
			else
				table.insert(removeFires, fire)
			end
		else
			table.insert(removeFires, fire)
		end
		for _, neighbor in ipairs(prism.neighborhood) do
			local nx, ny = neighbor:decompose()
			local neighbourCell = level:getCell(x + nx, y + ny)
			if neighbourCell then
				if not firePositions[(x + nx) .. "," .. (y + ny)] then
					if neighbourCell:has(prism.components.Flammable) then
						table.insert(flammableCells, prism.Vector2(x + nx, y + ny))
					end
				end
			end
		end
	end
	local spreadCount = biasedRandom(self.rng)
	for i = 1, math.min(spreadCount, #flammableCells) do
		local cell = flammableCells[i]
		local x, y = cell:decompose()
		self:placeFire(x, y, level)
	end
	for _, fire in ipairs(removeFires) do
		level:removeActor(fire)
	end
end

function FireSystem:placeFire(x, y, level)
	level:addActor(prism.actors.Fire(), x, y)
	if self.rng:random(0, 1) == 1 then
		level:addActor(prism.actors.Smoke(), x, y)
	end
end
--[[ there is a bug wherein when you have a single flammable tile in a circle of non flammable tiles the game locks up and I don't know why]]
--
return FireSystem

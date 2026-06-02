---@class ScentSystem : System
local ScentSystem = prism.System:extend("ScentSystem")

function ScentSystem:getRequirements()
	return prism.systems.SensesSystem
end

--- Called when the level is initialized
--- @param level Level
function ScentSystem:postInitialize(level)
	-- Only rebuild if manager exists
	local manager = self:getScentManager(level)
	if manager then
		self.scentManager = manager
		self:rebuildScentMap(level)
	end
end

function ScentSystem:propagateScent(actor, level)
	local scent = actor:get(prism.components.Scent)
	if not scent then
		return
	end

	local x, y = actor:getPosition():decompose()
	local strength = scent.strength
	local frontier = prism.Queue()

	frontier:push({ x = x, y = y, strength = strength })

	while not frontier:empty() do
		local current = frontier:pop()

		if self:canHoldScent(level, current.x, current.y) then
			local existing = self.scentManager:getScent(current.x, current.y)
			if not existing or current.strength > existing.strength then
				self.scentManager:setScent(current.x, current.y, actor, current.strength)
				if current.strength and current.strength > 2 then
					for _, dir in ipairs(prism.neighborhood) do
						local nx, ny = current.x + dir.x, current.y + dir.y
						frontier:push({ x = nx, y = ny, strength = current.strength - 1 })
					end
				end
			end
		end
	end
end
--- Check if a cell can hold scent (cached per rebuild)
--- @param level Level
--- @param x integer
--- @param y integer
--- @return boolean
function ScentSystem:canHoldScent(level, x, y)
	-- Check bounds first
	if not level:inBounds(x, y) then
		return false
	end

	-- Use cache if available
	local cacheKey = x .. "," .. y
	if self._passableCache[cacheKey] ~= nil then
		return self._passableCache[cacheKey]
	end

	local cell = level:getCell(x, y)
	if not cell then
		return false
	end
	local collider = cell:get(prism.components.Collider)
	if not collider then
		self._passableCache[cacheKey] = false
		return false
	end

	local walkBit = prism.Collision.createBitmaskFromMovetypes({ "walk", "fly" })
	local mask = collider:getMask()
	if not mask then
		self._passableCache[cacheKey] = false
		return false
	end

	local passable = bit.band(mask, walkBit) == walkBit
	self._passableCache[cacheKey] = passable
	return passable
end

function ScentSystem:rebuildScentMap(level)
	if not self.scentManager then
		return
	end
	-- Initialize passable cache for this rebuild
	self._passableCache = {}
	self.scentManager:clear()
	for stinker in level:query(prism.components.Scent):iter() do
		self:propagateScent(stinker, level)
	end
end

--- Get the scent manager for a level
--- @param level Level
--- @return ScentManager?
function ScentSystem:getScentManager(level)
	-- Query for actors with ScentManager component
	local manager = level:query(prism.components.ScentManager):first()
	if manager then
		return manager:get(prism.components.ScentManager)
	end
	return nil
end

function ScentSystem:onMove(level, actor)
	if not self.scentManager then
		return
	end
	self.scentManager:setDirty(true)
end

function ScentSystem:onActorAdded(level, actor)
	if not self.scentManager then
		return
	end
	self.scentManager:setDirty(true)
end

function ScentSystem:onTurnEnd(level, actor)
	if not actor:has(prism.components.PlayerController) then
		return
	end
	if not self.scentManager then
		return
	end
	if self.scentManager:isDirty() then
		self:rebuildScentMap(level)
		self.scentManager:setDirty(false)
	end
end

--- Called by SensesSystem for each actor with Smell component
--- This is triggered via the onSenses event
--- @param level Level
--- @param actor Actor
function ScentSystem:onSenses(level, actor)
	if not self.scentManager then
		return
	end
	local smell = actor:get(prism.components.Smell)
	if not smell then
		return
	end

	local sensesComponent = actor:get(prism.components.Senses)
	if not sensesComponent then
		return
	end

	local actorPos = actor:getPosition()
	if not actorPos then
		return
	end

	-- Remove old smell relations
	actor:removeAllRelations(prism.relations.SmellsRelation)

	-- Check scents in range
	local smellRange = smell:getRange() or 10

	for x = actorPos.x - smellRange, actorPos.x + smellRange do
		for y = actorPos.y - smellRange, actorPos.y + smellRange do
			local scent = self.scentManager:getScent(x, y)
			if scent and scent.strength >= smell:getThreshold() then
				local scentPos = scent.actor:getPosition()
				if scentPos then
					local cell = level:getCell(scentPos.x, scentPos.y)
					if cell then
						actor:addRelation(prism.relations.SmellsRelation, scent.actor)
						actor:addRelation(prism.relations.SensesRelation, scent.actor)
						sensesComponent.cells:set(scentPos.x, scentPos.y, cell)
					end
				end
			end
		end
	end
end
return ScentSystem

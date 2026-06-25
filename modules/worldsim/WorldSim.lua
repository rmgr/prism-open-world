--- @class WorldSim
--- @field zones SparseGrid
--- @field allActors ActorStorage
--- @field simSystems table
--- @field currentTick integer
--- @field zoneX integer
--- @field zoneY integer
--- @field actorZoneIndex table<Actor, ZoneRecord>
local WorldSim = prism.Object:extend("WorldSim")

function WorldSim:__new()
	self.zones = prism.SparseGrid()
	self.allActors = prism.ActorStorage()
	self.currentTick = 0
	self.tickInterval = 5
	self.zoneX = 0
	self.zoneY = 0
	self.actorZoneIndex = {}

	self.simSystems = {
		prism.simsystems.SatietySimSystem(),
		prism.simsystems.GoalSimSystem(),
	}

	-- One-time setup for each system, mirroring how a Level initialises Systems.
	for _, system in ipairs(self.simSystems) do
		system:initialize(self)
	end
end

--- @param zx integer
--- @param zy integer
--- @return ZoneRecord
function WorldSim:getOrCreateZone(zx, zy)
	local record = self.zones:get(zx, zy)
	if not record then
		record = prism.worldsim.ZoneRecord(zx, zy, Game:getZoneSeed(zx, zy))
		self.zones:set(zx, zy, record)
	end
	return record
end

--- @param zx integer
--- @param zy integer
--- @return string
--- @private
function WorldSim:_zonePath(zx, zy)
	return ("zone_%d_%d.lz4"):format(zx, zy)
end

--- @param zx integer
--- @param zy integer
--- @param cells table
--- @param roomGraph table?
--- @private
function WorldSim:_writeZone(zx, zy, cells, roomGraph)
	local file = prism.worldsim.ZoneFile(cells, roomGraph)
	local blob = prism.Object.serialize(file)
	local packed = prism.messagepack.pack(blob)
	local lz = love.data.compress("string", "lz4", packed)
	love.filesystem.write(self:_zonePath(zx, zy), lz)
end

--- @param zx integer
--- @param zy integer
--- @return table cells, table roomGraph
--- @private
function WorldSim:_readZone(zx, zy)
	local lz = assert(love.filesystem.read(self:_zonePath(zx, zy)), "no zone file for (" .. zx .. "," .. zy .. ")")
	local packed = love.data.decompress("string", "lz4", lz)
	local blob = prism.messagepack.unpack(packed)
	local file = prism.Object.deserialize(blob)
	return file.cells, file.roomGraph
end

--- Collect a builder/level's cells into the serialisable { x, y, cell } list.
--- @param source table   anything with eachCell()
--- @return table
--- @private
function WorldSim:_collectCells(source)
	local cells = {}
	for x, y, cell in source:eachCell() do
		local name = cell.__factory:match("[^.]+$")
		cells[#cells + 1] = { x, y, name }
	end
	return cells
end

--- @param zx integer
--- @param zy integer
--- @param builder LevelBuilder   host-built; queried for actors and cells
--- @param roomGraph table?       optional, written into the zone file
function WorldSim:pregenerateZone(zx, zy, builder, roomGraph)
	local record = self:getOrCreateZone(zx, zy)

	for actor in builder:query():iter() do
		local pos = actor:getPosition()
		if pos then
			record.storage:addActor(actor)
			self.allActors:addActor(actor)
			self.actorZoneIndex[actor] = record
		end
	end

	self:_writeZone(zx, zy, self:_collectCells(builder), roomGraph)
end

--- Place an actor directly into a dormant zone's storage (boot seeding,
--- scripted spawns). The actor should already carry a Position.
--- @param actor Actor
--- @param zx integer
--- @param zy integer
function WorldSim:addDormantActor(actor, zx, zy)
	local record = self:getOrCreateZone(zx, zy)
	record.storage:addActor(actor)
	self.allActors:addActor(actor)
	self.actorZoneIndex[actor] = record
end

--- @param activeZoneX integer
--- @param activeZoneY integer
function WorldSim:advance(activeZoneX, activeZoneY)
	self.currentTick = self.currentTick + 1
	if self.currentTick % self.tickInterval == 0 then
		for zx, zy, record in self.zones:each() do
			if zx ~= activeZoneX or zy ~= activeZoneY then
				local delta = self.currentTick - record.lastSimTick
				if delta > 0 then
					self:_tickZone(record, delta)
					record.lastSimTick = self.currentTick
				end
			end
		end
	end
end

--- @param record ZoneRecord
--- @param ticksDelta integer
--- @private
function WorldSim:_tickZone(record, ticksDelta)
	local rng = prism.RNG(record.seed .. self.currentTick)
	for _, system in ipairs(self.simSystems) do
		system:onSimTick(record, ticksDelta, rng, self)
	end
end

function WorldSim:deflateZone(level, zoneX, zoneY)
	local record = self:getOrCreateZone(zoneX, zoneY)

	record.storage = prism.ActorStorage()

	local toRemove = {}
	for actor in level:query():iter() do
		if not actor:has(prism.components.PlayerController) then
			table.insert(toRemove, actor)
		end
	end

	for _, actor in ipairs(toRemove) do
		level:removeActor(actor)
		record.storage:addActor(actor)
		self.allActors:addActor(actor)
		self.actorZoneIndex[actor] = record
	end

	-- Cells go to the zone file, not into the record. Continuous persistence:
	-- the world's terrain is written to disk every time the player leaves.
	self:_writeZone(zoneX, zoneY, self:_collectCells(level), level.rooms)

	record.lastSimTick = self.currentTick
	record.hasBeenVisited = true
	record.visitCount = record.visitCount + 1

	for _, system in ipairs(self.simSystems) do
		system:onZoneDeflated(record, self)
	end
end

function WorldSim:hydrateZone(zoneX, zoneY)
	local record = self:getOrCreateZone(zoneX, zoneY)

	for _, system in ipairs(self.simSystems) do
		system:onZoneHydrating(record, self)
	end

	local builder = prism.LevelBuilder()

	local cells, roomGraph = self:_readZone(zoneX, zoneY)
	for _, entry in ipairs(cells) do
		if entry[3] then
			local cell = prism.cells[entry[3]]()
			builder:set(entry[1], entry[2], cell)
		end
	end

	-- Seat the in-memory population. The zone file contains no actors by
	-- design; the actors are whatever the sim has done to storage since the
	-- zone was last live.
	for _, actor in ipairs(record.storage:getAllActors()) do
		local pos = actor:getPosition()
		if pos then
			builder:addActor(actor, pos.x, pos.y)
		end
		self.allActors:removeActor(actor)
		self.actorZoneIndex[actor] = nil
	end

	record.storage = prism.ActorStorage()

	return builder, roomGraph or {}
end

function WorldSim:moveActor(actor, targetZoneX, targetZoneY)
	local fromZone = self.actorZoneIndex[actor]
	local toZone = self:getOrCreateZone(targetZoneX, targetZoneY)
	if not fromZone or not toZone then
		return
	end

	fromZone.storage:removeActor(actor)

	if targetZoneX == self.zoneX and targetZoneY == self.zoneY then
		-- Entering the player's LIVE zone: the actor stops being dormant, so
		-- it must leave the dormant bookkeeping entirely — findActor's
		-- contract is "nil = in the active level".
		self.allActors:removeActor(actor)
		self.actorZoneIndex[actor] = nil

		local x = 0
		local y = 0
		local w, h = Game.level:getSize()
		if fromZone.zoneX > self.zoneX then
			x = w - 1
			y = h / 2
		elseif fromZone.zoneX < self.zoneX then
			x = 0
			y = h / 2
		elseif fromZone.zoneY > self.zoneY then
			x = w / 2
			y = h - 1
		elseif fromZone.zoneY < self.zoneY then
			x = w / 2
			y = 0
		end
		x = math.floor(x)
		y = math.floor(y)
		Game.level:addActor(actor, x, y)
		return
	end

	-- Dormant → dormant: allActors membership unchanged; only the zone
	-- index and storage move.
	actor:give(prism.components.Position(prism.Vector2(16, 16)))
	toZone.storage:addActor(actor)
	self.actorZoneIndex[actor] = toZone
end

function WorldSim:findActor(actor)
	return self.actorZoneIndex[actor] -- nil = in the active level
end

function WorldSim:queryAll(component)
	local results = {}
	for _, record in self.zones:each() do
		for actor in record.storage:query(component):iter() do
			table.insert(results, actor)
		end
	end
	if Game.level then
		for actor in Game.level:query(component):iter() do
			table.insert(results, actor)
		end
	end
	return results
end

--- The only sanctioned way to assign a goal. Removes any existing goal first,
--- because give() does NOT auto-replace sibling subclasses of Goal.
--- @param actor Actor
--- @param newGoal Goal?
function prism.worldsim:setGoal(actor, newGoal)
	local existing = actor:get(prism.components.Goal)
	if existing then
		actor:remove(existing)
	end
	if newGoal then
		actor:give(newGoal)
	end
end

--- Pick the highest-scoring need above its threshold and return its goal.
--- Returns nil when the actor has no Needs component or no need clears its threshold.
--- Reads only components — headless safe.
--- @param actor Actor
--- @param worldSim WorldSim
--- @param rng RNG
--- @param record ZoneRecord   the zone the actor currently sits in
--- @return Goal?
function prism.worldsim:pickNextGoal(actor, worldSim, rng, record)
	local needs = actor:get(prism.components.Needs)
	if not needs then
		return nil
	end

	local best, bestScore = nil, -1
	for _, entry in pairs(needs.needs) do
		local threshold = entry.threshold or 0
		local score = entry.score:compare(actor)
		if score >= threshold and score > bestScore then
			bestScore = score
			best = entry
		end
	end

	return best and best.goal:evaluate(actor, worldSim, rng, record) or nil
end

return WorldSim

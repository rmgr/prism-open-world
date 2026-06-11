--- @class WorldSim
--- @field zones SparseGrid              ZoneRecord per world-grid position
--- @field allActors ActorStorage        Every dormant actor in the world (the
---                                       single in-memory actor graph — actors
---                                       NEVER live in zone files)
--- @field simSystems table              Ordered list of SimSystem instances
--- @field currentTick integer           Advances once per player action
--- @field zoneX integer                 Currently Active Zone X Position
--- @field zoneY integer                 Currently Active Zone Y Position
--- @field actorZoneIndex table<Actor, ZoneRecord>
local WorldSim = prism.Object:extend("WorldSim")

function WorldSim:__new()
	self.zones = prism.SparseGrid()
	self.allActors = prism.ActorStorage()
	self.currentTick = 0
	self.zoneX = 0
	self.zoneY = 0
	self.actorZoneIndex = {}

	self.simSystems = {
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

--- -------------------------------------------------------------------------
---  ZONE FILES  (cells + roomGraph only — never actors; see ZoneFile)
---
---  worldsim is entirely generation-ignorant. The HOST builds a zone with
---  whatever generator it likes and hands the builder to pregenerateZone;
---  worldsim harvests its actors into memory and writes its CELLS to disk.
---  Hydration is then one uniform path — read the file — for every zone,
---  visited or not.
--- -------------------------------------------------------------------------

--- @param zx integer
--- @param zy integer
--- @return string
--- @private
function WorldSim:_zonePath(zx, zy)
	return ("zone_%d_%d.lz4"):format(zx, zy)
end

--- @param zx integer
--- @param zy integer
--- @param cells table       list of { x, y, cell }
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
		cells[#cells + 1] = { x, y, cell }
	end
	return cells
end

--- -------------------------------------------------------------------------
---  BOOT  —  the host hands us a freshly generated builder per zone
--- -------------------------------------------------------------------------

--- Harvest the builder's generated actors (nest populations, landmarks, ...)
--- into the in-memory dormant graph, and write the builder's cells to the
--- zone file. The builder is discarded afterwards. worldsim never knows what
--- kind of level this is — it only reads actors and cells off the builder.
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

--- -------------------------------------------------------------------------
---  SIM TICK
--- -------------------------------------------------------------------------

--- @param activeZoneX integer
--- @param activeZoneY integer
function WorldSim:advance(activeZoneX, activeZoneY)
	self.currentTick = self.currentTick + 1

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

--- @param record ZoneRecord
--- @param ticksDelta integer
--- @private
function WorldSim:_tickZone(record, ticksDelta)
	local rng = prism.RNG(record.seed .. self.currentTick)
	for _, system in ipairs(self.simSystems) do
		system:onSimTick(record, ticksDelta, rng, self)
	end
end

--- -------------------------------------------------------------------------
---  DEFLATION  —  player leaves a zone: actors → memory, cells → disk
--- -------------------------------------------------------------------------

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

--- -------------------------------------------------------------------------
---  HYDRATION  —  one uniform path: read the file, seat the live actors
--- -------------------------------------------------------------------------

function WorldSim:hydrateZone(zoneX, zoneY)
	local record = self:getOrCreateZone(zoneX, zoneY)

	for _, system in ipairs(self.simSystems) do
		system:onZoneHydrating(record, self)
	end

	local builder = prism.LevelBuilder()

	-- Cells come from the zone file — identical whether this is the first
	-- visit (written at pregeneration) or a return (written at deflation).
	local cells, roomGraph = self:_readZone(zoneX, zoneY)
	for _, entry in ipairs(cells) do
		builder:set(entry[1], entry[2], entry[3])
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

--- -------------------------------------------------------------------------
---  HELPERS
--- -------------------------------------------------------------------------

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

return WorldSim

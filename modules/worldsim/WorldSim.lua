--- @class WorldSim
--- @field zones SparseGrid              ZoneRecord per world-grid position
--- @field allActors ActorStorage        Every dormant actor in the world
--- @field simSystems table              Ordered list of SimSystem instances
--- @field currentTick integer           Advances once per player action
--- @field zoneX integer                 Currently Active Zone X Position
--- @field zoneY integer                 Currently Active Zone Y Position
--- @field actorZoneIndex table<Actor, ZoneRecord>
local WorldSim = prism.Object:extend("WorldSim")

-- The landmark types we sprinkle into each zone, and where in the 31×31 dummy
-- room they sit. Coordinates avoid the wall block (5..7) and pit (20..25).
-- One landmark is chosen per slot per zone, deterministically from the seed,
-- so a zone always has the same landmarks across visits.
local LANDMARK_SLOTS = {
	{ x = 25, y = 6 }, -- NE corner area
	{ x = 7, y = 25 }, -- SW corner area
}

local LANDMARK_FACTORIES = { "Campsite", "WateringHole" }

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
---  BOOT  —  pre-generate a grid of zones so the world exists from turn one
--- -------------------------------------------------------------------------

--- @param w integer
--- @param h integer
--- @param originX integer
--- @param originY integer
function WorldSim:pregenerateZones(w, h, originX, originY)
	for zy = originY, originY + h - 1 do
		for zx = originX, originX + w - 1 do
			local record = self:getOrCreateZone(zx, zy)

			-- Build the dummy room (now including landmarks) and snapshot cells.
			local builder = self:_buildDummyRoom(zx, zy, record.seed)

			-- Place the beetle in zone (0,1) on first generation.
			if zx == 0 and zy == 1 then
				local beetle = prism.actors.Beetle()
				builder:addActor(beetle, 16, 16)
			end

			record.cellOverrides = {}
			for x, y, cell in builder:eachCell() do
				record.cellOverrides[x .. "," .. y] = cell
			end

			-- Snapshot actors (landmarks + beetle) into storage.
			record.storage = prism.ActorStorage()
			for actor in builder:query():iter() do
				local pos = actor:getPosition()
				if pos then
					record.storage:addActor(actor)
					self.allActors:addActor(actor)
					self.actorZoneIndex[actor] = record
				end
			end

			record.hasBeenVisited = true
			record.visitCount = 0
		end
	end
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
---  DEFLATION
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

	record.cellOverrides = {}
	for x, y, cell in level:eachCell() do
		record.cellOverrides[x .. "," .. y] = cell
	end

	if level.rooms then
		record.roomGraph = level.rooms
	end

	record.lastSimTick = self.currentTick
	record.hasBeenVisited = true
	record.visitCount = record.visitCount + 1

	for _, system in ipairs(self.simSystems) do
		system:onZoneDeflated(record, self)
	end
end

--- -------------------------------------------------------------------------
---  HYDRATION
--- -------------------------------------------------------------------------

function WorldSim:hydrateZone(zoneX, zoneY)
	local record = self:getOrCreateZone(zoneX, zoneY)

	if not record.hasBeenVisited then
		local builder = self:_buildDummyRoom(zoneX, zoneY, record.seed)
		return builder, {}
	end

	local builder = prism.LevelBuilder()

	for _, system in ipairs(self.simSystems) do
		system:onZoneHydrating(record, self)
	end

	for key, cell in pairs(record.cellOverrides) do
		local x, y = key:match("(-?%d+),(-?%d+)")
		builder:set(tonumber(x), tonumber(y), cell)
	end

	for _, actor in ipairs(record.storage:getAllActors()) do
		local pos = actor:getPosition()
		if pos then
			builder:addActor(actor, pos.x, pos.y)
		end
		self.allActors:removeActor(actor)
		self.actorZoneIndex[actor] = nil
	end

	record.storage = prism.ActorStorage()

	return builder, record.roomGraph or {}
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
		local x = 0
		local y = 0
		local w, h = Game.level:getSize()
		if fromZone.zoneX > self.zoneX then
			--coming from right
			x = w - 1
			y = h / 2
		elseif fromZone.zoneX < self.zoneX then
			--coming from left
			x = 0
			y = h / 2
		elseif fromZone.zoneY > self.zoneY then
			--coming from below
			x = w / 2
			y = h - 1
		elseif fromZone.zoneY < self.zoneY then
			-- coming from top
			x = w / 2
			y = 0
		end
		x = math.floor(x)
		y = math.floor(y)
		Game.level:addActor(actor, x, y)
	else
		-- allActors stays in sync: actor is dormant before and after, so it remains
		-- a member; we only re-point its zone index.
		actor:give(prism.components.Position(prism.Vector2(16, 16)))

		toZone.storage:addActor(actor)
	end
	self.actorZoneIndex[actor] = toZone

	print("moved actor to (" .. targetZoneX .. "," .. targetZoneY .. ")")
end

function WorldSim:findActor(actor)
	return self.actorZoneIndex[actor]
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

--- Build the 31×31 dummy room, then subdivide it with a couple of landmarks
--- chosen deterministically from the zone seed so they're stable across visits.
--- @param zoneX integer
--- @param zoneY integer
--- @param seed string
--- @return LevelBuilder
function WorldSim:_buildDummyRoom(zoneX, zoneY, seed)
	local builder = prism.LevelBuilder()
	builder:rectangle("fill", 1, 1, 31, 31, prism.cells.Floor)
	builder:rectangle("fill", 5, 5, 7, 7, prism.cells.Wall)
	builder:rectangle("fill", 20, 20, 25, 25, prism.cells.Pit)

	-- Deterministic landmark pick: same seed → same landmarks every time.
	local rng = prism.RNG(seed)
	for _, slot in ipairs(LANDMARK_SLOTS) do
		local factoryName = LANDMARK_FACTORIES[rng:random(#LANDMARK_FACTORIES)]
		local landmark = prism.actors[factoryName]()
		builder:addActor(landmark, slot.x, slot.y)
	end

	return builder
end

return WorldSim

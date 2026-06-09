local controls = require("controls")

--- @class GameLevelState : LevelState
local GameLevelState = spectrum.gamestates.LevelState:extend("GameLevelState")

--- @param display Display
--- @param builderOrLevel LevelBuilder|Level
--- @param rooms table
--- @param seed string
function GameLevelState:__new(display, builderOrLevel, rooms, seed)
	local level

	if prism.Level:is(builderOrLevel) then
		level = builderOrLevel
	else
		local builder = builderOrLevel
		builder:addSeed(seed)
		builder:addScheduler(prism.schedulers.SpeedScheduler())
		builder:addSystems(
			prism.systems.SensesSystem(),
			prism.systems.SightSystem(),
			prism.systems.SoundSystem(),
			prism.systems.FallSystem(),
			prism.systems.FearSystem(),
			prism.systems.FactionSystem(Game.factions),
			prism.systems.DiffusionSystem(),
			prism.systems.FireSystem(seed),
			prism.systems.TickSystem(),
			prism.systems.SatietySystem(),
			prism.systems.AttackedSystem(),
			prism.systems.NestingSystem(),
			prism.systems.TallGrassSystem()
		)
		local scentManager = prism.Actor()
		scentManager:give(prism.components.ScentManager())
		builder:addActor(scentManager)
		level = builder:build(prism.cells.Wall)
		---@cast level LevelWithRooms
		level.rooms = rooms
	end

	self.super.__new(self, level, display)
end

function GameLevelState:handleMessage(message)
	self.super.handleMessage(self, message)

	if prism.messages.LoseMessage:is(message) then
		self.manager:enter(spectrum.gamestates.GameOverState(self.display))
	end

	if prism.messages.WinMessage:is(message) then
		self.manager:enter(spectrum.gamestates.WinState(self.display))
	end

	if prism.messages.SkipAnimationsMessage:is(message) then
		self.display:skipAnimations()
	end

	if prism.messages.DescendMessage:is(message) then
		---@cast message DescendMessage
		local builder, rooms = Game:generateNextFloor()
		self.manager:enter(spectrum.gamestates.GameLevelState(self.display, builder, rooms, Game:getLevelSeed()))
	end

	if prism.messages.EnterZoneMessage:is(message) then
		---@cast message EnterZoneMessage

		-- 1. Deflate: snapshot the current level into its ZoneRecord.
		Game.worldSim:deflateZone(self.level, Game.worldSim.zoneX, Game.worldSim.zoneY)

		-- 2. Hydrate: build the destination zone from its ZoneRecord.
		local builder, rooms = Game.worldSim:hydrateZone(message.targetZoneX, message.targetZoneY)

		-- 3. Place the player at the correct spawn edge of the new zone.
		builder:addActor(message.traveller, message.spawnX, message.spawnY)
		print("(" .. message.targetZoneX .. "," .. message.targetZoneY .. ")")
		Game.worldSim.zoneX = message.targetZoneX
		Game.worldSim.zoneY = message.targetZoneY
		-- 4. Enter the new state, passing zone coords so it can deflate correctly.
		self.manager:enter(
			spectrum.gamestates.GameLevelState(
				self.display,
				builder,
				rooms,
				Game:getZoneSeed(message.targetZoneX, message.targetZoneY),
				message.targetZoneX,
				message.targetZoneY
			)
		)
	end
end

function GameLevelState:updateDecision(dt, owner, decision)
	Game.level = self.level
	controls:update()

	if controls.move.pressed then
		Game.worldSim:advance(Game.worldSim.zoneX, Game.worldSim.zoneY)
		local destination = owner:getPosition() + controls.move.vector

		local openable = self.level:query(prism.components.Container):at(destination:decompose()):first()
		if self:setAction(prism.actions.OpenContainer(owner, openable)) then
			return
		end

		local orbTarget = self.level:query(prism.components.OrbOfYendor):at(destination:decompose()):first()
		if orbTarget then
			self:setAction(prism.actions.Win(owner))
			return
		end

		local descendTarget = self.level:query(prism.components.Stair):at(destination:decompose()):first()
		if self:setAction(prism.actions.Descend(owner, descendTarget)) then
			return
		end

		-- Zone exit check must come before Move so walking off the edge
		-- triggers a transition rather than a failed move.
		local zoneExit = self:_resolveZoneExit(owner, destination)
		if zoneExit and self:setAction(zoneExit) then
			return
		end

		if self:setAction(prism.actions.Move(owner, destination)) then
			return
		end

		local target = self.level:query():at(destination:decompose()):first()
		self:setAction(prism.actions.Attack(owner, target))
	end

	if controls.inventory.pressed then
		local inventory = owner:get(prism.components.Inventory)
		local equipper = owner:get(prism.components.Equipper)
		if inventory and equipper then
			self.manager:push(
				spectrum.gamestates.InventoryState(self.display, decision, self.level, inventory, equipper)
			)
		end
	end

	if controls.pickup.pressed then
		local target = self.level:query(prism.components.Item):at(owner:getPosition():decompose()):first()
		if self:setAction(prism.actions.Pickup(owner, target)) then
			return
		end
	end

	if controls.wait.pressed then
		self:setAction(prism.actions.Wait(owner))
	end
end

--- Determine whether moving to `destination` crosses a zone boundary.
--- Returns a ZoneExit action if so, nil otherwise.
--- @param owner Actor
--- @param destination Vector2
--- @return ZoneExit?
function GameLevelState:_resolveZoneExit(owner, destination)
	local w, h = self.level:getSize()

	if destination.x >= 1 and destination.x <= w and destination.y >= 1 and destination.y <= h then
		return nil
	end

	-- Dummy room is 31×31 with no pad/normalize, so cells (1,1)→(31,31) are
	-- all explicitly set Floor/Wall/Pit. Spawning at x=2 or x=30 lands safely
	-- on Floor regardless of edge. INSET=2 keeps us off the corner cells.
	-- When swapping in the real Cavern generator, update ZW/ZH to 122 and
	-- INSET to 2 (the pad border is 1 cell wide, so 2 clears it).
	local ZW, ZH = 31, 31
	local INSET = 2

	local targetZoneX = Game.worldSim.zoneX
	local targetZoneY = Game.worldSim.zoneY
	local spawnX, spawnY
	local pos = owner:getPosition()

	local cx = math.max(INSET, math.min(ZW - INSET + 1, pos.x))
	local cy = math.max(INSET, math.min(ZH - INSET + 1, pos.y))

	if destination.x < 1 then
		targetZoneX = Game.worldSim.zoneX - 1
		spawnX, spawnY = ZW - INSET + 1, cy
	elseif destination.x > w then
		targetZoneX = Game.worldSim.zoneX + 1
		spawnX, spawnY = INSET, cy
	elseif destination.y < 1 then
		targetZoneY = Game.worldSim.zoneY - 1
		spawnX, spawnY = cx, ZH - INSET + 1
	else
		targetZoneY = Game.worldSim.zoneY + 1
		spawnX, spawnY = cx, INSET
	end

	return prism.actions.ZoneExit(owner, targetZoneX, targetZoneY, spawnX, spawnY)
end

-- draw() and resume() unchanged — omitted for brevity.

return GameLevelState

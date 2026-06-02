local controls = require("controls")

--- @class GameLevelState : LevelState
--- A custom game level state responsible for initializing the level map,
--- handling input, and drawing the state to the screen.
---
--- @overload fun(display: Display, builder: LevelBuilder, seed: string): GameLevelState
--- @overload fun(display: Display, level: Level): GameLevelState
local GameLevelState = spectrum.gamestates.LevelState:extend("GameLevelState")

--- @param display Display
--- @param builderOrLevel LevelBuilder|LevelWithRooms
--- @param rooms table
--- @param seed? string
function GameLevelState:__new(display, builderOrLevel, rooms, seed)
	local level

	-- Check if we're loading a saved level or building a new one
	if prism.Level:is(builderOrLevel) then
		-- Loading a saved game - builderOrLevel is a Level
		level = builderOrLevel
	else
		-- Building a new level - builderOrLevel is a LevelBuilder
		local builder = builderOrLevel
		builder:addSeed(seed)
		builder:addScheduler(prism.schedulers.SpeedScheduler())
		builder:addSystems(
			prism.systems.SensesSystem(),
			prism.systems.SightSystem(),
			--prism.systems.ScentSystem(),
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
			prism.systems.TallGrassSystem(),
			prism.systems.WaterSystem()
		)
		local scentManager = prism.Actor()
		scentManager:give(prism.components.ScentManager())
		builder:addActor(scentManager)
		level = builder:build(prism.cells.Wall)
		---@cast level LevelWithRooms
		level.rooms = rooms
	end

	-- Initialize with the created level and display, the heavy lifting is done by
	-- the parent class.
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
		--- @cast message DescendMessage
		local builder, rooms = Game:generateNextFloor()
		self.manager:enter(spectrum.gamestates.GameLevelState(self.display, builder, rooms, Game:getLevelSeed()))
	end
	-- Handle any messages sent to the level state from the level. LevelState
	-- handles a few built-in messages for you, like the decision you fill out
	-- here.

	-- This is where you'd process custom messages like advancing to the next
	-- level or triggering a game over.
end

-- updateDecision is called whenever there's an ActionDecision to handle.
function GameLevelState:updateDecision(dt, owner, decision)
	-- Controls need to be updated each frame.
	Game.level = self.level
	controls:update()

	-- Controls are accessed directly via table index.
	if controls.move.pressed then
		local destination = owner:getPosition() + controls.move.vector

		-- Check for chest FIRST, before trying to descend
		local openable = self.level:query(prism.components.Container):at(destination:decompose()):first()

		local openContainer = prism.actions.OpenContainer(owner, openable)
		if self:setAction(openContainer) then
			return
		end

		-- Check for stairs, before trying to move
		local orbTarget = self.level:query(prism.components.OrbOfYendor):at(destination:decompose()):first()
		if orbTarget then
			local win = prism.actions.Win(owner)
			self:setAction(win)
			return
		end

		-- Check for stairs, before trying to move
		local descendTarget = self.level:query(prism.components.Stair):at(destination:decompose()):first()
		local descend = prism.actions.Descend(owner, descendTarget)
		if self:setAction(descend) then
			return
		end

		-- If no stairs, try to move
		local move = prism.actions.Move(owner, destination)
		if self:setAction(move) then
			return
		end

		-- If can't move, try to attack
		local target = self.level:query():at(destination:decompose()):first()
		local attack = prism.actions.Attack(owner, target)
		self:setAction(attack)
	end

	if controls.inventory.pressed then
		local inventory = owner:get(prism.components.Inventory)
		local equipper = owner:get(prism.components.Equipper)
		if inventory and equipper then
			local spriteAtlas = spectrum.SpriteAtlas.fromASCIIGrid("display/wanderlust_16x16.png", 16, 16)
			local inventoryState =
				spectrum.gamestates.InventoryState(self.display, decision, self.level, inventory, equipper)
			self.manager:push(inventoryState)
		end
	end

	if controls.pickup.pressed then
		local target = self.level:query(prism.components.Item):at(owner:getPosition():decompose()):first()

		local pickup = prism.actions.Pickup(owner, target)
		if self:setAction(pickup) then
			return
		end
	end

	if controls.wait.pressed then
		self:setAction(prism.actions.Wait(owner))
	end
end

function GameLevelState:draw()
	self.display:clear()

	local player = self.level:query(prism.components.PlayerController):first()

	if not player then
		-- You would normally transition to a game over state
		self.display:putLevel(self.level)
	else
		local position = player:expectPosition()

		local x, y = self.display:getCenterOffset(position:decompose())
		self.display:setCamera(x, y)

		local primary, secondary = self:getSenses()
		-- Render the level using the player’s senses
		self.display:beginCamera()
		self.display:putSenses(primary, secondary, self.level)
		self.display:endCamera()
	end

	-- custom terminal drawing goes here!
	local health = player:get(prism.components.Health)

	local satiety = player:get(prism.components.Satiety)
	if health then
		self.display:print(1, 1, "HP: " .. health.hp .. "/" .. health:getMaxHP())
	end
	self.display:print(1, 2, "Depth: " .. Game.depth)
	if satiety then
		self.display:print(1, 4, "Satiety: " .. satiety.satiety .. "/" .. satiety.maxSatiety)
	end

	local log = player:get(prism.components.Log)
	if log then
		local offset = 0
		for line in log:iterLast(5) do
			self.display:print(1, self.display.height - offset, line)
			offset = offset + 1
		end
	end

	-- Actually render the terminal out and present it to the screen.
	-- You could use love2d to translate and say center a smaller terminal or
	-- offset it for custom non-terminal UI elements. If you do scale the UI
	-- just remember that display:getCellUnderMouse expects the mouse in the
	-- display's local pixel coordinates
	self.display:print(1, 3, "Current FPS: " .. tostring(love.timer.getFPS()))
	self.display:draw()
	-- custom love2d drawing goes here!
end

function GameLevelState:resume()
	-- Run senses when we resume from e.g. Geometer.
	self.level:getSystem(prism.systems.SensesSystem):postInitialize(self.level)
end

return GameLevelState

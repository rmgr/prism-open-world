local controls = require("controls")

--- @class GameMenuState: GameState
--- @field display Display
--- @overload fun(display:Display) : GameMenuState
local GameMenuState = spectrum.GameState:extend("GameMenuState")

function GameMenuState:__new(display)
	self.display = display
	self.save = love.filesystem.read("save.lz4")

	self.options = { "play" }
	if self.save then
		table.insert(self.options, "load")
	end
	table.insert(self.options, "quit")

	self.selectedIndex = 1
end

function GameMenuState:draw()
	local midpoint = math.floor(self.display.height / 2)
	self.display:clear()
	self.display:print(1, midpoint, "Prism is pretty cool", nil, nil, nil, "center", self.display.width)

	local labels = {
		play = "Play",
		load = "Load Game",
		quit = "Quit",
	}

	for i, option in ipairs(self.options) do
		local label = labels[option]
		local prefix = i == self.selectedIndex and "> " or "  "
		self.display:print(1, midpoint + 2 + i, prefix .. label, nil, nil, nil, "center", self.display.width)
	end

	self.display:draw()
end

function GameMenuState:update(dt)
	controls:update()

	if controls.move.pressed then
		local moveVec = controls.move.vector
		if moveVec and moveVec.y ~= 0 then
			self.selectedIndex = self.selectedIndex + moveVec.y
			if self.selectedIndex < 1 then
				self.selectedIndex = #self.options
			elseif self.selectedIndex > #self.options then
				self.selectedIndex = 1
			end
		end
	end

	if controls.select.pressed then
		self:confirmSelection()
		return
	end

	-- Keep keyboard shortcuts as fallback
	if controls.quit.pressed then
		love.event.quit()
	elseif controls.play.pressed then
		self:startNewGame()
	elseif controls.load.pressed and self.save then
		self:loadGame()
	end
end

function GameMenuState:confirmSelection()
	local option = self.options[self.selectedIndex]
	if option == "play" then
		self:startNewGame()
	elseif option == "load" then
		self:loadGame()
	elseif option == "quit" then
		love.event.quit()
	end
end

function GameMenuState:startNewGame()
	love.filesystem.remove("save.lz4")
	local builder, rooms = Game:generateNextFloor()
	self.manager:enter(spectrum.gamestates.GameLevelState(self.display, builder, rooms, Game:getLevelSeed()))
end

function GameMenuState:loadGame()
	if not self.save then
		return
	end
	local mp = love.data.decompress("string", "lz4", self.save)
	local save = prism.Object.deserialize(prism.messagepack.unpack(mp))
	Game = save
	self.manager:enter(spectrum.gamestates.GameLevelState(self.display, Game.level))
end

return GameMenuState

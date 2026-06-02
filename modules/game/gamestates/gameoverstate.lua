local controls = require("controls")

--- @class GameOverState: GameState
--- @field display Display
--- @overload fun(display:Display) : GameOverState
local GameOverState = spectrum.GameState:extend("GameOverState")

function GameOverState:__new(display)
	self.display = display
	self.options = { "restart", "quit" }
	self.selectedIndex = 1
end

function GameOverState:draw()
	local midpoint = math.floor(self.display.height / 2)
	self.display:clear()
	self.display:print(1, midpoint, " Rekt", nil, nil, nil, "center", self.display.width)

	local labels = {
		restart = "Restart",
		quit = "Quit",
	}

	for i, option in ipairs(self.options) do
		local prefix = i == self.selectedIndex and "> " or "  "
		self.display:print(1, midpoint + 2 + i, prefix .. labels[option], nil, nil, nil, "center", self.display.width)
	end

	self.display:draw()
end

function GameOverState:update(dt)
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

	-- Keyboard shortcuts as fallback
	if controls.quit.pressed then
		love.event.quit()
	elseif controls.restart.pressed then
		love.event.restart()
	end
end

function GameOverState:confirmSelection()
	local option = self.options[self.selectedIndex]
	if option == "restart" then
		love.event.restart()
	elseif option == "quit" then
		love.event.quit()
	end
end

return GameOverState

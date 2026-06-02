local controls = require("controls")
--- @class WinState: GameState
--- @field display Display
--- @overload fun(display:Display) : WinState
local WinState = spectrum.GameState:extend("WinState")

function WinState:__new(display)
	self.display = display
end

function WinState:draw()
	local midpoint = math.floor(self.display.height / 2) - 3

	self.display:clear()
	self.display:print(
		1,
		midpoint,
		"You seize the fabulous Orb of Yendor and a blinding ",
		nil,
		nil,
		nil,
		"center",
		self.display.width
	)
	self.display:print(1, midpoint + 1, "white light shines out from it!", nil, nil, nil, "center", self.display.width)
	self.display:print(
		1,
		midpoint + 3,
		"When you open your eyes, you are in your bed.",
		nil,
		nil,
		nil,
		"center",
		self.display.width
	)
	self.display:print(1, midpoint + 4, "It was all a dream.", nil, nil, nil, "center", self.display.width)
	self.display:print(1, midpoint + 7, "[r] to restart", nil, nil, nil, "center", self.display.width)
	self.display:print(1, midpoint + 8, "[q] to quit", nil, nil, nil, "center", self.display.width)
	self.display:draw()
end

function WinState:update(dt)
	controls:update()
	if controls.quit.pressed then
		love.event.quit()
	elseif controls.restart.pressed then
		love.event.restart()
	end
end

return WinState

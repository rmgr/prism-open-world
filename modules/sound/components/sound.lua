---@class Sound : Component
---@field private volume integer 1-100
local Sound = prism.Component:extend("Sound")

--- @param volume integer
function Sound:__new(volume)
	self.volume = volume
end

function Sound:getVolume()
	return self.volume
end

return Sound

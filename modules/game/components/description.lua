--- @class Description : Component
--- @field text string
local Description = prism.Component:extend("Description")
Description.name = "Description"

--- @param text string
function Description:__new(text)
	self.text = text
end

return Description

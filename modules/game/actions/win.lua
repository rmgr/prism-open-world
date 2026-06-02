---@class Win: Action
---@overload fun(owner: Actor): Win
local Win = prism.Action:extend("Win")

function Win:perform(level)
	level:yield(prism.messages.WinMessage())
end

return Win

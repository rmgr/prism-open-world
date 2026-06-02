local ConditionHolder = prism.components.ConditionHolder
--- The 'Speed' component stores an actor's movement/action speed.
--- Higher speed values mean the actor gets more turns in the scheduler.
--- @class Speed : Component
--- @overload fun(speed: number): Speed
local Speed = prism.Component:extend("Speed")

--- Constructor for the Speed component.
--- @param speed number The initial speed value (default: 100)
function Speed:__new(speed)
	self.speed = speed or 100
end

--- Gets the current speed value.
--- @return number The actor's speed.
function Speed:getSpeed()
	local modifiers = ConditionHolder.getActorModifiers(self.owner, prism.modifiers.SpeedModifier)
	local modifiedSpeed = self.speed
	for _, modifier in ipairs(modifiers) do
		modifiedSpeed = modifiedSpeed + modifier.delta
	end
	return math.max(modifiedSpeed, 10)
end

--- Sets the speed value.
--- @param speed number The new speed value.
function Speed:setSpeed(speed)
	self.speed = speed
end

return Speed

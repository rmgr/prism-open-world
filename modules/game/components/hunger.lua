--- @class Satiety : Component
--- @field satiety integer
--- @field maxSatiety integer
--- @field hungryTurns integer
--- @overload fun(maxSatiety: integer): Satiety
local Satiety = prism.Component:extend("Satiety")

function Satiety:__new(maxSatiety)
	self.satiety = maxSatiety
	self.maxSatiety = maxSatiety
	self.hungryTurns = 0
end

function Satiety:updateHungryTurns(value)
	self.hungryTurns = (self.hungryTurns + value) % 10
end

function Satiety:updateSatiety(value)
	self.satiety = self.satiety + value
	if self.satiety > self.maxSatiety then
		self.satiety = self.maxSatiety
	end
	if self.satiety > 0 then
		self.hungryTurns = 0
	end
end

return Satiety

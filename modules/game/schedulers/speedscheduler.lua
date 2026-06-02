--- The 'SpeedScheduler' manages a queue of actors and schedules their actions based on speed.
--- This implementation uses an energy/time system where faster actors get more turns.
--- Each actor accumulates energy based on their speed, and acts when they have enough energy.
--- @class SpeedScheduler : Scheduler
--- @overload fun(): SpeedScheduler
local SpeedScheduler = prism.Scheduler:extend("SpeedScheduler")

--- Constructor for the SpeedScheduler class.
--- Initializes the actor energy tracking and sets the time counter to 0.
function SpeedScheduler:__new()
	-- Don't call super.__new since base Scheduler throws an error
	self.actorList = {} -- List of all actors in the scheduler
	self.energy = {} -- Energy accumulated by each actor
	self.time = 0 -- Global time counter
	self.energyThreshold = 100 -- Energy needed to take a turn
end

--- Adds an actor to the scheduler.
--- @param actor Actor|string The actor, or special tick, to add.
function SpeedScheduler:add(actor)
	if not self:has(actor) then
		table.insert(self.actorList, actor)
		self.energy[actor] = 0
	end
end

--- Removes an actor from the scheduler.
--- @param actor Actor The actor to remove.
function SpeedScheduler:remove(actor)
	for i, a in ipairs(self.actorList) do
		if a == actor then
			table.remove(self.actorList, i)
			self.energy[actor] = nil
			break
		end
	end
end

--- Checks if an actor is in the scheduler.
--- @param actor Actor The actor to check.
--- @return boolean True if the actor is in the scheduler, false otherwise.
function SpeedScheduler:has(actor)
	for _, a in ipairs(self.actorList) do
		if a == actor then
			return true
		end
	end
	return false
end

--- Returns the next actor to act.
--- Advances time and accumulates energy for all actors based on their speed.
--- Returns the actor with the most energy once they reach the threshold.
--- @return Actor The actor who is next to act.
function SpeedScheduler:next()
	-- Advance time until at least one actor can act
	while true do
		local readyActor = nil
		local maxEnergy = -1

		-- Check if any actor has enough energy
		for _, actor in ipairs(self.actorList) do
			if self.energy[actor] >= self.energyThreshold then
				if self.energy[actor] > maxEnergy then
					maxEnergy = self.energy[actor]
					readyActor = actor
				end
			end
		end

		-- If we found a ready actor, return them
		if readyActor then
			self.energy[readyActor] = self.energy[readyActor] - self.energyThreshold
			return readyActor
		end

		-- Otherwise, advance time and accumulate energy
		self:advanceTime()
	end
end

--- Advances time by one tick and accumulates energy for all actors.
function SpeedScheduler:advanceTime()
	self.time = self.time + 1

	for _, actor in ipairs(self.actorList) do
		local speed = self:getActorSpeed(actor)
		self.energy[actor] = self.energy[actor] + speed
	end
end

--- Gets the speed of an actor.
--- @param actor Actor The actor to get the speed for.
--- @return number The actor's speed value.
function SpeedScheduler:getActorSpeed(actor)
	-- Handle special tick strings
	if type(actor) == "string" then
		return 100 -- Default speed for special ticks
	end

	local speedComponent = actor:get(prism.components.Speed)
	if speedComponent then
		return speedComponent:getSpeed()
	end

	return 100 -- Default speed if no speed component
end

--- Checks if the scheduler is empty.
--- @return boolean True if there are no actors, false otherwise.
function SpeedScheduler:empty()
	return #self.actorList == 0
end

--- Returns the current time as a timestamp.
--- @return number The current time value.
function SpeedScheduler:timestamp()
	return self.time
end

return SpeedScheduler

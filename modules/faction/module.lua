-- Create a faction registry similar to prism.actors and prism.cells
prism.factions = {}

--- Registers a faction factory function
--- @param name string The name of the faction
--- @param factory fun(): Actor A function that creates and returns a faction actor
function prism.registerFaction(name, factory)
	prism.factions[name] = factory
end

---@class FearSystem : System
local FearSystem = prism.System:extend("FearSystem")

function FearSystem:__new()
	self.super.__new(self)
end

--- At level initialisation time, loop through all entities
---@param level Level
function FearSystem:postInitialize(level)
	-- Apply fear relationships
	for actor in level:query(prism.components.AfraidOf):iter() do
		self:updateActorFearRelationships(level, actor)
	end
end

---@param level Level
---@param actor Actor
function FearSystem:onActorAdded(level, actor)
	-- If this actor is afraid of something, update their fear relationships
	if actor:get(prism.components.AfraidOf) then
		self:updateActorFearRelationships(level, actor)
	end

	-- If this actor belongs to a faction, rebuild fear relationships for all actors
	-- who might be afraid of this actor's faction
	if actor:get(prism.components.BelongsToFaction) then
		self:rebuildAllFearRelationships(level)
	end
end

---@param level Level
function FearSystem:rebuildAllFearRelationships(level)
	-- Rebuild fear relationships for all actors who are afraid of something
	for actor in level:query(prism.components.AfraidOf):iter() do
		self:updateActorFearRelationships(level, actor)
	end
end

---@param level Level
---@param actor Actor
function FearSystem:updateActorFearRelationships(level, actor)
	local afraidOf = actor:get(prism.components.AfraidOf)
	if not afraidOf then
		return
	end

	-- Iterate through each faction the actor is afraid of
	for _, factionName in ipairs(afraidOf.factions) do
		local members = self:getFactionMembers(level, factionName)
		self:applyFearRelations(actor, members)
	end
end

---@param level Level
---@param factionName string
---@return Actor[]
function FearSystem:getFactionMembers(level, factionName)
	local members = {}
	for actor in level:query(prism.components.BelongsToFaction):iter() do
		local belongsToFaction = actor:get(prism.components.BelongsToFaction)
		if belongsToFaction then
			for _, name in ipairs(belongsToFaction.factions) do
				if name == factionName then
					table.insert(members, actor)
					break
				end
			end
		end
	end
	return members
end

---@param actor Actor
---@param members Actor[]
function FearSystem:applyFearRelations(actor, members)
	for _, member in ipairs(members) do
		if actor ~= member and not actor:hasRelation(prism.relations.FearsRelation, member) then
			print("    -> ", actor:getName(), " fears ", member:getName())
			actor:addRelation(prism.relations.FearsRelation(), member)
			print("    -> ", member:getName(), " feared by ", actor:getName())
			member:addRelation(prism.relations.FearedByRelation(), actor)
		end
	end
end

return FearSystem

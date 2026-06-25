---@class FactionSystem : System
---@field factions table<string, Actor>?
local FactionSystem = prism.System:extend("FactionSystem")

---@param factions table<string, Actor>?
function FactionSystem:__new(factions)
	self.super.__new(self)
	self.factions = factions
end

--- At level initialisation time, loop through all entities
---@param level Level
function FactionSystem:postInitialize(level)
	-- If factions were provided, add them to the level
	if self.factions then
		for _, factionActor in pairs(self.factions) do
			-- Remove from old level if it exists in one
			if factionActor.level then
				factionActor.level:removeActor(factionActor)
			end
			level:addActor(factionActor)
		end
	end

	-- Now establish relationships for all actors
	for actor in level:query(prism.components.BelongsToFaction):iter() do
		self:linkActorToFactions(level, actor)
	end

	-- Apply Friend/Foe relations based on initial faction relationships
	self:updateActorRelationships(level)
end

---@param level Level
---@param actor Actor
function FactionSystem:linkActorToFactions(level, actor)
	local belongsToFaction = actor:get(prism.components.BelongsToFaction)
	if not belongsToFaction then
		return
	end

	for _, factionName in ipairs(belongsToFaction.factions) do
		for factionActor in level:query(prism.components.Faction):iter() do
			local name = prism.components.Name.get(factionActor)
			if name == factionName then
				print("  -> Linking", actor:getName(), "to faction", factionName)
				actor:addRelation(prism.relations.BelongsToFactionRelation, factionActor)
			end
		end
	end
end

---@param level Level
---@param actor Actor
function FactionSystem:onActorAdded(level, actor)
	-- For dynamically added actors (after initialization), link them to their factions
	local belongsToFaction = actor:get(prism.components.BelongsToFaction)
	if belongsToFaction then
		self:linkActorToFactions(level, actor)
		self:updateActorRelationships(level)
	end
end

---@param level Level
---@param actor Actor
---@param action Action
function FactionSystem:afterAction(level, actor, action)
	if prism.actions.ChangeFactionRelationship:is(action) then
		self:updateActorRelationships(level)
	end
end

---@param level Level
---@param factionName string
---@return Actor[]
function FactionSystem:getFactionMembers(level, factionName)
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

---@param members1 Actor[]
---@param members2 Actor[]
function FactionSystem:applyFriendRelations(members1, members2)
	for _, member1 in ipairs(members1) do
		for _, member2 in ipairs(members2) do
			if not member1:hasRelation(prism.relations.FriendRelation, member2) then
				-- Remove Foe relation if exists (mutually exclusive)
				if member1:hasRelation(prism.relations.FoeRelation, member2) then
					member1:removeRelation(prism.relations.FoeRelation, member2)
				end
				member1:addRelation(prism.relations.FriendRelation(), member2)
			end
		end
	end
end

---@param members Actor[]
function FactionSystem:applySameFactionFriendRelations(members)
	-- Make all members of the same faction friends with each other
	for i = 1, #members do
		for j = i + 1, #members do
			local member1 = members[i]
			local member2 = members[j]

			-- Add bidirectional friend relations
			if not member1:hasRelation(prism.relations.FriendRelation, member2) then
				member1:addRelation(prism.relations.FriendRelation(), member2)
			end
			if not member2:hasRelation(prism.relations.FriendRelation, member1) then
				member2:addRelation(prism.relations.FriendRelation(), member1)
			end
		end
	end
end

---@param members1 Actor[]
---@param members2 Actor[]
function FactionSystem:applyFoeRelations(members1, members2)
	for _, member1 in ipairs(members1) do
		for _, member2 in ipairs(members2) do
			if not member1:hasRelation(prism.relations.FoeRelation, member2) then
				-- Remove Friend relation if exists (mutually exclusive)
				if member1:hasRelation(prism.relations.FriendRelation, member2) then
					member1:removeRelation(prism.relations.FriendRelation, member2)
				end
				member1:addRelation(prism.relations.FoeRelation(), member2)
			end
		end
	end
end

---@param level Level
---@param faction1 Actor
---@param faction2 Actor
function FactionSystem:updateRelationshipBetweenFactions(level, faction1, faction2)
	-- Get relationship strength between these factions
	local relations = faction1:getRelations(prism.relations.FactionRelationshipRelation)
	local relationship = relations[faction2]
	---@cast relationship FactionRelationshipRelation

	if not relationship then
		return
	end

	local strength = relationship.strength
	local faction1Name = prism.components.Name.get(faction1)
	local faction2Name = prism.components.Name.get(faction2)

	local faction1Members = self:getFactionMembers(level, faction1Name)
	local faction2Members = self:getFactionMembers(level, faction2Name)

	-- Apply Friend or Foe relations based on strength
	if strength >= 50 then
		-- Friendly factions (>= 50)
		self:applyFriendRelations(faction1Members, faction2Members)
	elseif strength <= -50 then
		-- Hostile factions (<= -50)
		self:applyFoeRelations(faction1Members, faction2Members)
	end
	-- Neutral factions (between -50 and 50) get no Friend/Foe relations
end

---@param level Level
function FactionSystem:updateActorRelationships(level)
	-- Get all faction entities
	local factions = {}
	for factionActor in level:query(prism.components.Faction):iter() do
		table.insert(factions, factionActor)
	end

	-- First, make members of the same faction friends with each other
	for _, factionActor in ipairs(factions) do
		local factionName = prism.components.Name.get(factionActor)
		local members = self:getFactionMembers(level, factionName)
		self:applySameFactionFriendRelations(members)
	end

	-- Then, reclassify based on inter-faction relationships
	for i = 1, #factions do
		for j = i + 1, #factions do
			self:updateRelationshipBetweenFactions(level, factions[i], factions[j])
		end
	end
end

return FactionSystem

local Log = prism.components.Log
local Name = prism.components.Name
local ConditionHolder = prism.components.ConditionHolder
local AttackTarget = prism.Target(prism.components.Health):isActor():range(1)
local mask = prism.Collision.createBitmaskFromMovetypes({ "fly" })

--- @class Attack: Action
--- @overload fun(owner: Actor, attacked: Actor): Attack
local Attack = prism.Action:extend("Attack")
Attack.name = "Attack"
Attack.targets = { AttackTarget }

--- @param level Level
--- @param attacked Actor
function Attack:perform(level, attacked)
	local direction = (attacked:getPosition() - self.owner:getPosition())
	local attacker = self.owner:get(prism.components.Attacker)

	local baseDmg = 1
	if attacker then
		baseDmg = attacker.damage
	end

	local damageReductionModifiers =
		ConditionHolder.getActorModifiers(attacked, prism.modifiers.DamageReductionModifier)
	local modifiedDamage = baseDmg
	for _, modifier in ipairs(damageReductionModifiers) do
		modifiedDamage = modifiedDamage - modifier.mod
	end

	local damageModifiers = ConditionHolder.getActorModifiers(self.owner, prism.modifiers.DamageModifier)
	for _, modifier in ipairs(damageModifiers) do
		modifiedDamage = modifiedDamage + modifier.delta
	end

	local modifiers = ConditionHolder.getActorModifiers(self.owner, prism.modifiers.KnockbackModifier)
	local modifiedKnockback = 0
	for _, modifier in ipairs(modifiers) do
		modifiedKnockback = modifiedKnockback + modifier.delta
	end
	local final = attacked:expectPosition()
	for _ = 1, modifiedKnockback do
		local nextpos = final + direction
		if not level:getCellPassable(nextpos.x, nextpos.y, mask) then
			break
		end
		final = nextpos
	end

	level:moveActor(attacked, final)
	local damage = prism.actions.Damage(attacked, modifiedDamage)
	level:tryPerform(damage)

	local attackName = Name.lower(attacked)
	local ownerName = Name.lower(self.owner)
	local dealt = damage.dealt or 0
	attacked:addRelation(prism.relations.AttackedByRelation, self.owner)
	self.owner:addRelation(prism.relations.AttackedRelation, attacked)
	if Game.player:hasRelation(prism.relations.SeesRelation, self.owner) then
		level:yield(prism.messages.AnimationMessage({
			animation = spectrum.animations.Attack(self.owner, attacked:getPosition()),
		}))
	end

	local attackerFactionComponent = self.owner:get(prism.components.BelongsToFaction)
	local attackedFactionComponent = attacked:get(prism.components.BelongsToFaction)
	local attackerFactions = nil
	local attackedFactions = nil
	if attackerFactionComponent then
		attackerFactions = attackerFactionComponent.factions
	end
	if attackedFactionComponent then
		attackedFactions = attackedFactionComponent.factions
	end
	if not attackerFactionComponent and self.owner:has(prism.components.PlayerController) then
		attackerFactions = { "PlayerFaction" }
	end
	if attackerFactions and attackedFactions then
		for _, attackerFaction in ipairs(attackerFactions) do
			for _, attackedFaction in ipairs(attackedFactions) do
				local changeFactionRelationshipAction =
					prism.actions.ChangeFactionRelationship(attacked, attackedFaction, attackerFaction, -1)
				level:tryPerform(changeFactionRelationshipAction)
			end
		end
	end
	Log.addMessage(self.owner, "You attack the %s for %i damage!", attackName, dealt)
	Log.addMessage(attacked, "The %s attacks you for %i damage!", ownerName, dealt)
	Log.addMessageSensed(level, self, "The %s attacks the %s for %i damage!", ownerName, attackName, dealt)
end

return Attack

prism.registerActor("SquadMate", function()
	return prism.Actor.fromComponents({
		prism.components.Name("SquadMate"),
		prism.components.Drawable({ index = "@", color = prism.Color4.GREEN, layer = math.huge - 10 }),
		prism.components.Position(),
		prism.components.Collider(),
		prism.components.BTController(prism.BehaviorTree.Root({
			-- First, we find player
			prism.behaviours.FindActorBehaviour(
				{ prism.relations.FriendRelation },
				{ prism.components.PlayerController }
			),
			prism.BehaviorTree.Selector({
				prism.BehaviorTree.Sequence({
					prism.behaviours.CheckTargetInRangeBehaviour(5),
					prism.behaviours.ListenBehaviour(),
					prism.BehaviorTree.Selector({
						-- Hunger Subroutine
						prism.behaviours.HungerSubroutine(40),
						-- Flee scary monsters
						prism.behaviours.FleeSubroutine(),
						-- Hunt Subroutine (only actual foes)
						prism.behaviours.HuntSubroutine(10, 1),
					}),
					prism.behaviours.WaitBehaviour(),
				}),
				prism.behaviours.MoveBehaviour(),
				prism.behaviours.WaitBehaviour(),
			}),
		})),
		prism.components.Senses(),
		prism.components.Sight({ range = 4, fov = true }),
		prism.components.Mover({ "walk" }),
		prism.components.Health(100),
		prism.components.Log(),
		prism.components.BelongsToFaction({ "PlayerFaction" }),
		prism.components.Inventory({
			limitCount = 25,
		}),
		prism.components.ConditionHolder(),
		prism.components.Scent({ strength = 30 }),
		prism.components.Hearing(),
		prism.components.Attacker(10),
		prism.components.Satiety(250),
		prism.components.Equipper({
			"hand",
			"armour",
		}),
	})
end)

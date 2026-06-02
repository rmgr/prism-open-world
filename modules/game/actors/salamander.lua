prism.register(prism.Component:extend("SalamanderNest"))
prism.register(prism.Component:extend("Salamander"))
prism.registerActor("Salamander", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Salamander"),
		prism.components.Position(),
		prism.components.Drawable({ index = "S", color = prism.Color4.ORANGE, layer = math.huge - 5 }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Satiety(300),
		prism.components.Sight({ range = 4, fov = true }),
		prism.components.Mover({ "swim", "walk" }),
		prism.components.Smell({ threshold = 20 }),
		prism.components.Hearing(),
		prism.components.FireProof(),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.behaviours.ListenBehaviour(),
			prism.BehaviorTree.Selector({
				-- Hunger Subroutine
				prism.behaviours.HungerSubroutine(40),
				-- Flee scary monsters
				prism.behaviours.FleeOrFireSubroutine(),
				-- Hunt Subroutine (only actual foes)
				prism.behaviours.HuntSubroutine(34, 1, 3),
			}),
			prism.BehaviorTree.Sequence({
				prism.behaviours.FindRandomRoomBehaviour(),
				prism.behaviours.MoveBehaviour(1),
			}),
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(30),
		prism.components.AfraidOf({ "OlmFaction", "FireFaction" }),
		prism.components.Attacker(10),
		prism.components.BelongsToFaction({ "SalamanderFaction" }),
		prism.components.DropTable({
			chance = 0.8,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Salamander(),
		prism.components.Nesting(prism.components.SalamanderNest),
		prism.components.Speed(100),
	})
end)

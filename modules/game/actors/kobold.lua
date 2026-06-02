prism.register(prism.Component:extend("KoboldNest"))
prism.register(prism.Component:extend("Kobold"))
prism.registerActor("Kobold", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Kobold"),
		prism.components.Position(),
		prism.components.Drawable({ index = "k", color = prism.Color4.RED, layer = math.huge - 5 }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Satiety(500),
		prism.components.Sight({ range = 5, fov = true }),
		prism.components.Mover({ "walk", "swim" }),
		prism.components.Smell({ threshold = 20 }),
		prism.components.Hearing(),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.behaviours.ListenBehaviour(),
			prism.BehaviorTree.Selector({
				-- Hunger Subroutine
				prism.behaviours.HungerSubroutine(40),
				-- Flee scary monsters
				prism.behaviours.FleeSubroutine(),
				-- Hunt Subroutine (only actual foes)
				prism.behaviours.HuntSubroutine(34, 1),
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
		prism.components.BelongsToFaction({ "KoboldFaction" }),
		prism.components.DropTable({
			chance = 0.8,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Kobold(),
		prism.components.Nesting(prism.components.KoboldNest),
		prism.components.Speed(100),
	})
end)

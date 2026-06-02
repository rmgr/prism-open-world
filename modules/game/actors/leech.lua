prism.register(prism.Component:extend("LeechNest"))
prism.register(prism.Component:extend("Leech"))
prism.registerActor("Leech", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Leech"),
		prism.components.Position(),
		prism.components.Drawable({ index = "~", color = prism.Color4.WHITE, layer = math.huge - 5 }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Sight({ range = 16, fov = false }),
		prism.components.Mover({ "swim" }),
		prism.components.Smell({ threshold = 200 }),
		prism.components.Hearing(),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.behaviours.ListenBehaviour(),
			prism.BehaviorTree.Selector({
				-- Hunt Subroutine (only actual foes)
				prism.behaviours.HuntSubroutine(1, 1),
			}),
			prism.behaviours.RandomMoveBehaviour(),
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(5),
		prism.components.AfraidOf({ "OlmFaction" }),
		prism.components.Attacker(1),
		prism.components.BelongsToFaction({ "LeechFaction" }),
		prism.components.DropTable({
			chance = 0.8,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Leech(),
		prism.components.Nesting(prism.components.LeechNest),
		prism.components.Speed(100),
		prism.components.Swimmer(),
	})
end)

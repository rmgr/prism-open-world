prism.register(prism.Component:extend("Beetle"))
prism.registerActor("Beetle", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Beetle"),
		prism.components.Position(),
		prism.components.Drawable({ index = "B", color = prism.Color4.BLUE, layer = math.huge - 5 }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Sight({ range = 12, fov = true }),
		prism.components.Mover({ "walk" }),
		prism.components.Hearing(),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.behaviours.ListenBehaviour(),
			prism.BehaviorTree.Selector({
				-- Flee scary monsters
				prism.behaviours.FleeSubroutine(),
				-- Hunt Subroutine (only actual foes)
				prism.behaviours.HuntSubroutine(15, 1, 100),
			}),
			prism.behaviours.RandomMoveBehaviour(),
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(30),
		prism.components.Attacker(10),
		prism.components.BelongsToFaction({ "BeetleFaction" }),
		prism.components.AfraidOf({ "KoboldFaction", "OlmFaction" }),
		prism.components.DropTable({
			chance = 1,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Beetle(),
		prism.components.Speed(50),
	})
end)

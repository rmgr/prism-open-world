prism.register(prism.Component:extend("OlmNest"))
prism.register(prism.Component:extend("Olm"))
prism.registerActor("Olm", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Olm"),
		prism.components.Position(),
		prism.components.Drawable({ index = "O", color = prism.Color4.NAVY }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Sight({ range = 3, fov = true }),
		prism.components.Hearing(),
		prism.components.Mover({ "walk" }),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.behaviours.ListenBehaviour(),
			prism.BehaviorTree.Selector({
				-- Hunger Subroutine
				prism.behaviours.HungerSubroutine(),
				-- Flee scary monsters
				prism.behaviours.FleeSubroutine(),
				-- Hunt Subroutine (only actual foes)
				prism.behaviours.HuntSubroutine(15, 1, 8),
			}),
			prism.BehaviorTree.Sequence({
				--	prism.behaviours.FindNearestRoomNotContainingEnemyBehaviour(),
				prism.behaviours.FindHomeBehaviour(),
				prism.behaviours.MoveBehaviour(),
			}),
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(200),
		prism.components.Attacker(50),
		prism.components.BelongsToFaction({ "OlmFaction" }),
		prism.components.DropTable({
			chance = 0.8,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Olm(),
		prism.components.Speed(75),
		prism.components.Satiety(1000),
		prism.components.Nesting(prism.components.OlmNest),
	})
end)

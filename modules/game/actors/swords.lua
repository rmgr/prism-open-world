prism.registerActor("Axe", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Axe"),
		prism.components.Drawable({
			index = "\\",
			color = prism.Color4.ORANGE,
		}),
		prism.components.Item(),
		prism.components.Equipment(
			"hand",
			prism.condition.Condition(prism.modifiers.KnockbackModifier(2), prism.modifiers.DamageModifier(5))
		),
		prism.components.Position(),
		prism.components.Description("And my axe!"),
	})
end)
prism.registerActor("LargeBranch", function()
	return prism.Actor.fromComponents({
		prism.components.Name("LargeBranch"),
		prism.components.Drawable({
			index = "/",
			color = prism.Color4.BROWN,
		}),
		prism.components.Item(),
		prism.components.Equipment(
			"hand",
			prism.condition.Condition(prism.modifiers.KnockbackModifier(1), prism.modifiers.DamageModifier(10))
		),
		prism.components.Position(),
		prism.components.Description("Big chunk of wood, good for hitting things."),
	})
end)
prism.registerActor("Sword", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Sword"),
		prism.components.Drawable({
			index = "/",
			color = prism.Color4.YELLOW,
		}),
		prism.components.Item(),
		prism.components.Equipment("hand", prism.condition.Condition(prism.modifiers.DamageModifier(10))),
		prism.components.Position(),
		prism.components.Description("The classic weapon of a knight"),
	})
end)
prism.registerActor("HugeSword", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Huge Sword"),
		prism.components.Drawable({
			index = "|",
			color = prism.Color4.YELLOW,
		}),
		prism.components.Item(),
		prism.components.Equipment(
			"hand",
			prism.condition.Condition(prism.modifiers.KnockbackModifier(3), prism.modifiers.DamageModifier(20))
		),
		prism.components.Position(),
		prism.components.Description("Something something anime."),
	})
end)

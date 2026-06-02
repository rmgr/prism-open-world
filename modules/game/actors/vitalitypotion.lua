prism.registerActor("VitalityPotion", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Potion of Vitality"),
		prism.components.Drawable({ index = "!", color = prism.Color4.RED }),
		prism.components.Item(),
		prism.components.Position(),
		prism.components.Drinkable({
			healing = 0,
			condition = prism.conditions.TickedCondition(10, prism.modifiers.HealthModifier(1)),
		}),
	})
end)

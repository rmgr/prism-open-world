prism.registerActor("LeatherArmour", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Leather Armour"),
		prism.components.Drawable({
			index = "&",
			color = prism.Color4.BROWN,
		}),
		prism.components.Item(),
		prism.components.Equipment("armour", prism.condition.Condition(prism.modifiers.DamageReductionModifier(1))),
		prism.components.Position(),
		prism.components.Description("Skin of a cow cured and scraped and boiled and stitched into clothes."),
	})
end)

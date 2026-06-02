prism.registerActor("MeatBrick", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Meat Brick"),
		prism.components.Position(),
		prism.components.Drawable({ index = "%", color = prism.Color4.RED }),
		prism.components.Item({
			stackable = "MeatBrick",
			stackLimit = 99,
		}),
		prism.components.Edible(20, 50),
		prism.components.Description(
			"A big ol' brick of meat. Are any of us really men made of anything else but meat?"
		),
		prism.components.Throwable(0),
	})
end)

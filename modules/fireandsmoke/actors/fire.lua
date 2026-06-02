prism.registerActor("Fire", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Fire"),
		prism.components.Drawable({
			index = "%",
			color = prism.Color4.ORANGE,
			background = prism.Color4.RED,
			layer = 9,
		}),
		prism.components.Position(),
		prism.components.Fire(),
		prism.components.BelongsToFaction({ "FireFaction" }),
	})
end)

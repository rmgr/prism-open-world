prism.registerCell("Gravel", function()
	return prism.Cell.fromComponents({
		prism.components.Name("Gravel"),
		prism.components.Drawable({ index = ";", color = prism.Color4.DARKGREY }),
		prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
		prism.components.Sound(10),
	})
end)

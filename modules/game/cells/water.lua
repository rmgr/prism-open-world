prism.registerCell("Water", function()
	return prism.Cell.fromComponents({
		prism.components.Name("Water"),
		prism.components.Drawable({ index = "~", color = prism.Color4.BLUE }),
		prism.components.Collider({ allowedMovetypes = { "swim" } }),
		prism.components.Water(),
	})
end)

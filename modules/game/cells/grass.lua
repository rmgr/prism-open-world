prism.cells.Grass = function()
	return prism.Cell.fromComponents({
		prism.components.Name("Grass"),
		prism.components.Drawable({ index = '"', color = prism.Color4.LIME }),
		prism.components.Flammable(16),
		prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
		prism.components.Sound(3),
	})
end

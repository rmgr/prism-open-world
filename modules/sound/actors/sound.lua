prism.registerActor("Sound", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Sound"),
		prism.components.Drawable({ index = "?", color = prism.Color4.RED, layer = math.huge }),
		prism.components.SoundIcon(),
		prism.components.Position(),
	})
end)

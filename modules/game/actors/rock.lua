prism.register(prism.Component:extend("Rock"))
prism.registerActor("Rock", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Rock"),
		prism.components.Position(),
		prism.components.Item(),
		prism.components.Drawable({ index = "o", color = prism.Color4.WHITE }),
		prism.components.Throwable(1),
		prism.components.Description(
			"Life's not about how hard of a hit you can give... it's about how many you can take, and still keep moving forward."
		),
	})
end)

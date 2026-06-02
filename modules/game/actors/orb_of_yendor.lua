prism.register(prism.Component:extend("OrbOfYendor"))
prism.registerActor("OrbOfYendor", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Orb of Yendor"),
		prism.components.Position(),
		prism.components.Drawable({ index = "o", color = prism.Color4.PURPLE }),
		prism.components.OrbOfYendor(),
		prism.components.Remembered(),
	})
end)

--[[
Written by Drew Harry
Copied here under MIT license
https://github.com/drewww/breach
]]
prism.registerActor("Smoke", function(volume)
	return prism.Actor.fromComponents({
		prism.components.Name("Smoke"),
		prism.components.Drawable({
			index = GAS_TYPES["smoke"].index,
			color = prism.Color4.BLACK,
			background = prism.Color4.DARKGREY,
			layer = 9,
		}),
		prism.components.Position(),
		prism.components.Gas("smoke", volume or 100),
	})
end)

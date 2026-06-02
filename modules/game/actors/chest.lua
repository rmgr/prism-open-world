prism.registerActor("Chest", function(contents)
	local inventory = prism.components.Inventory()
	local chest = prism.Actor.fromComponents({
		prism.components.Name("Chest"),
		prism.components.Position(),
		inventory,
		prism.components.Drawable({ index = "(", color = prism.Color4.YELLOW }),
		prism.components.Container(),
		prism.components.Collider(),
	})
	--- @cast contents Actor[]
	inventory:addItems(contents or {})
	return chest
end)

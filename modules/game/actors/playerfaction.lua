prism.registerFaction("PlayerFaction", function()
	return prism.Actor.fromComponents({
		prism.components.Name("PlayerFaction"),
		prism.components.Faction(),
	})
end)

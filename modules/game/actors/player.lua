prism.registerActor("Player", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Player"),
		prism.components.Drawable({ index = "@", color = prism.Color4.BLUE, layer = math.huge - 10 }),
		prism.components.Position(),
		prism.components.Collider(),
		prism.components.PlayerController(),
		prism.components.Senses(),
		prism.components.Sight({ range = 64, fov = true }),
		prism.components.Mover({ "walk", "swim" }),
		prism.components.Health(100),
		prism.components.Log(),
		prism.components.BelongsToFaction({ "PlayerFaction" }),
		prism.components.Inventory({
			limitCount = 25,
		}),
		prism.components.ConditionHolder(),
		prism.components.Scent({ strength = 30 }),
		prism.components.Hearing(),
		prism.components.Attacker(10),
		prism.components.Satiety(250),
		prism.components.Equipper({
			"hand",
			"armour",
		}),
		prism.components.Speed(100),
	})
end)

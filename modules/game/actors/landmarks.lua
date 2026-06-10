-- Generic landmark actors — Name, Position, Drawable, Landmark identity, and
-- capability MARKER components (RestSpot / FoodSource / Water) declaring what
-- each offers. Goals query by marker:
--   storage:query(prism.components.Landmark, prism.components.RestSpot):first()
-- The Drawable layer sits below creatures (math.huge - 5) so an actor standing
-- on a landmark draws on top of it. Glyphs are plain ASCII (atlas-safe).

local LANDMARK_LAYER = math.huge - 10

prism.registerActor("Campsite", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Campsite"),
		prism.components.Position(),
		prism.components.Drawable({ index = "C", color = prism.Color4.ORANGE, layer = LANDMARK_LAYER }),
		prism.components.Landmark("campsite"),
		prism.components.RestSpot(),
	})
end)

prism.registerActor("WateringHole", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Watering Hole"),
		prism.components.Position(),
		prism.components.Drawable({ index = "W", color = prism.Color4.BLUE, layer = LANDMARK_LAYER }),
		prism.components.Landmark("watering_hole"),
		prism.components.WaterSource(),
		prism.components.FoodSource(),
	})
end)

prism.registerActor("ForagePatch", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Forage Patch"),
		prism.components.Position(),
		prism.components.Drawable({ index = "F", color = prism.Color4.LIME, layer = LANDMARK_LAYER }),
		prism.components.Landmark("forage_patch"),
		prism.components.FoodSource(),
	})
end)

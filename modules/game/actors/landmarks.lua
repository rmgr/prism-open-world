-- Generic landmark actors — a Name, a Position, a Drawable, and a Landmark tag.
-- Placed by WorldSim:_buildDummyRoom to subdivide a zone into points of interest.
-- The Drawable layer sits below creatures (which use math.huge - 5) so an actor
-- standing on a landmark draws on top of it.
-- Glyphs are plain ASCII letters so they're guaranteed to exist in the atlas.

local LANDMARK_LAYER = math.huge - 10

prism.registerActor("Campsite", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Campsite"),
        prism.components.Position(),
        prism.components.Drawable({ index = "C", color = prism.Color4.ORANGE, layer = LANDMARK_LAYER }),
        prism.components.Landmark("campsite", { "shelter" }),
    })
end)

prism.registerActor("WateringHole", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Watering Hole"),
        prism.components.Position(),
        prism.components.Drawable({ index = "W", color = prism.Color4.BLUE, layer = LANDMARK_LAYER }),
        prism.components.Landmark("watering_hole", { "water", "food_source" }),
    })
end)

prism.registerActor("ForagePatch", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Forage Patch"),
        prism.components.Position(),
        prism.components.Drawable({ index = "F", color = prism.Color4.LIME, layer = LANDMARK_LAYER }),
        prism.components.Landmark("forage_patch", { "food_source" }),
    })
end)

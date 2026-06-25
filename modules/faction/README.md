# Faction Module

A Prism module for managing factions and their relationships. This module allows you to create groups of actors that share relationships with other factions, automatically managing Friend and Foe relations between faction members based on faction-level relationship strengths.

## Overview

The faction module provides:
- **Faction registry**: Separate registry for faction actors (`prism.factions`)
- **Faction entities**: Special actors that represent factions in your game
- **Membership tracking**: Components to assign actors to factions
- **Relationship management**: Automatic propagation of faction relationships to individual actors
- **Event-driven updates**: Relations updated when faction relationships change

### How It Works

1. Register faction actors using `prism.registerFaction()`
2. Assign actors to factions using the `BelongsToFaction` component
3. Define relationships between factions using `FactionRelationshipRelation`
4. The `FactionSystem` automatically manages individual actor relationships:
   - Initial relationships are established during level initialization
   - Updates occur when `ChangeFactionRelationship` actions are performed

Faction relationships use a strength value from -100 (hostile) to 100 (friendly):
- Strength >= 50: Members become Friends
- Strength <= -50: Members become Foes
- Between -50 and 50: Neutral (no automatic relations)

## Components

### Faction
Marks an actor as a faction entity. Faction actors typically have a `Name` component to identify them.

```lua
prism.components.Faction()
```

### BelongsToFaction
Assigns an actor to one or more factions by name.

```lua
prism.components.BelongsToFaction({ "FactionName1", "FactionName2" })
```

## Relations

### FactionRelationshipRelation
Defines the relationship strength between two factions. Applied to faction actors.

```lua
prism.relations.FactionRelationshipRelation(strength)
```
- `strength`: Number from -100 (hostile) to 100 (friendly)

### BelongsToFactionRelation
Automatically created to link actors to their faction entities. Inverse of `FactionContainsRelation`.

### FactionContainsRelation
Automatically created to link faction entities to their members. Inverse of `BelongsToFactionRelation`.

## Actions

### ChangeFactionRelationship
Action to modify faction relationships at runtime. This is the preferred way to change faction relationships.

```lua
prism.actions.ChangeFactionRelationship(owner, fromFactionName, toFactionName, deltaStrength)
```
- `owner`: The actor performing the action
- `fromFactionName`: Name of the first faction
- `toFactionName`: Name of the second faction
- `deltaStrength`: Amount to change the relationship strength (can be positive or negative)

The action automatically:
- Clamps the final strength to the range -100 to 100
- Creates a new relationship if one doesn't exist

## System

### FactionSystem
Manages faction membership and propagates faction relationships to individual actors.

```lua
prism.systems.FactionSystem(factions)
```
- `factions`: Optional table of faction actors to add to the level

#### Behavior

The system operates at two key points:

1. **Level Initialization** (`postInitialize`):
   - Adds provided faction actors to the level
   - Links all actors with `BelongsToFaction` components to their faction entities
   - Establishes initial Friend/Foe relations based on faction relationships

2. **After Actions** (`afterAction`):
   - Monitors for `ChangeFactionRelationship` actions
   - Re-evaluates and updates all actor relationships when faction relationships change


## Registering Factions

Factions should be registered using `prism.registerFaction()` to keep them separate from regular game actors:

```lua
-- modules/game/actors/humanfaction.lua
prism.registerFaction("HumanFaction", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Humans"),
        prism.components.Faction(),
    })
end)

-- modules/game/actors/orcfaction.lua
prism.registerFaction("OrcFaction", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Orcs"),
        prism.components.Faction(),
    })
end)
```

Factions are then instantiated via the `prism.factions` registry:

```lua
local humanFaction = prism.factions.HumanFaction()
local orcFaction = prism.factions.OrcFaction()
```

## Generic Example

Here's a basic example of adding factions to a level:

```lua
-- Create faction instances (assuming they're already registered)
local humanFaction = prism.factions.HumanFaction()
local orcFaction = prism.factions.OrcFaction()

-- Set faction relationship (hostile)
humanFaction:addRelation(
    prism.relations.FactionRelationshipRelation(-100),
    orcFaction
)

-- Create actors that belong to factions
local warrior = prism.Actor.fromComponents({
    prism.components.Name("Warrior"),
    prism.components.BelongsToFaction({ "Humans" }),
    -- ... other components
})

local orcRaider = prism.Actor.fromComponents({
    prism.components.Name("Orc Raider"),
    prism.components.BelongsToFaction({ "Orcs" }),
    -- ... other components
})

-- Build the level
local builder = prism.LevelBuilder(prism.cells.Floor)
builder:addSystems(prism.systems.FactionSystem({ humanFaction, orcFaction }))
builder:addActor(warrior, 5, 5)
builder:addActor(orcRaider, 10, 10)
local level = builder:build()

-- The FactionSystem will automatically make the warrior and orc enemies
```

### Advanced: Multiple Factions

Actors can belong to multiple factions:

```lua
prism.registerActor("HalfOrc", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Half-Orc"),
        -- Belongs to both human and orc factions
        prism.components.BelongsToFaction({ "Humans", "Orcs" }),
    })
end)
```

### Advanced: Changing Relationships

Modify faction relationships at runtime using the `ChangeFactionRelationship` action:

```lua
-- Change relationship between PlayerFaction and KoboldFaction
-- Increase relationship by 50 points (making them friendlier)
local changeRelationship = prism.actions.ChangeFactionRelationship(
    player,  -- The actor performing the action
    "PlayerFaction",
    "KoboldFaction",
    50  -- Delta to apply to the relationship
)
level:tryPerform(changeRelationship)

-- This automatically:
-- 1. Updates the faction relationship strength (clamped to -100 to 100)
-- 2. Triggers FactionSystem to recalculate all actor relationships
-- 3. Applies/removes Friend/Foe relations as needed
```

**Important:** Always use the `ChangeFactionRelationship` action to modify relationships. Direct manipulation of faction relationships will not trigger the FactionSystem to update individual actor relations.

## Notes

- Faction actors are registered using `prism.registerFaction()` and kept in a separate `prism.factions` registry
- Faction entities are automatically added to the level by the FactionSystem if provided in the constructor
- The system uses the `BelongsToFaction` component's faction names to match against faction entity `Name` components
- Faction relationships are bidirectional - setting a relationship automatically creates the inverse
- The FactionSystem uses an event-driven approach:
  - Relationships are established once during level initialization (`postInitialize`)
  - Updates only occur when `ChangeFactionRelationship` actions are performed (`afterAction`)
- Friend and Foe relations are mutually exclusive - setting one removes the other
- Use `ChangeFactionRelationship` action to modify relationships at runtime - it automatically triggers relationship updates

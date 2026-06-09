--- A 'SimSystem' is the world-sim counterpart to a prism.System. Where a
--- System reacts to events on a live Level (turns, moves, actions), a SimSystem
--- advances the state of a *dormant* ZoneRecord over a span of elapsed ticks.
---
--- SimSystems hold no per-zone state — they are pure behaviour. State lives on
--- the actors (real Actor objects in record.storage) and on the ZoneRecord
--- itself. This is why SimSystems are NOT prism Objects and are not serialised:
--- WorldSim reconstructs its simSystems list fresh on load.
---
--- Extend this and override onSimTick (and optionally the lifecycle hooks).
--- Register instances in WorldSim:__new, mirroring how a Level registers Systems.
---
---     local SatietySimSystem = SimSystem:extend("SatietySimSystem")
---     function SatietySimSystem:onSimTick(record, ticksDelta, rng, worldSim)
---         for actor in record.storage:query(prism.components.Satiety):iter() do
---             ...
---         end
---     end
---
--- @class SimSystem : Object
--- @field name string  Human-readable name, defaults to the class name.
local SimSystem = prism.Object:extend("SimSystem")

--- Constructor. Subclasses that need their own state should call
--- SimSystem.__new(self) via self.super, then add fields.
function SimSystem:__new()
	self.name = self.className
end

--- Called once per WorldSim:advance, for every dormant zone, in registration
--- order. This is the main hook — advance the zone's state by ticksDelta turns.
--- Override this.
--- @param record ZoneRecord    The dormant zone being ticked. Mutate freely.
--- @param ticksDelta integer   Turns elapsed since this zone was last ticked.
--- @param rng RNG              Deterministic RNG for this zone+tick.
--- @param worldSim WorldSim    The owning sim — for cross-zone reads/moves.
function SimSystem:onSimTick(record, ticksDelta, rng, worldSim) end

--- Called once when WorldSim first creates/registers this system, before any
--- ticks run. Use for one-time setup (caching faction tables, etc.).
--- @param worldSim WorldSim
function SimSystem:initialize(worldSim) end

--- Called when a zone is about to deflate (player leaving). Lets a system
--- react to fresh state arriving from a live level before it goes dormant.
--- @param record ZoneRecord
--- @param worldSim WorldSim
function SimSystem:onZoneDeflated(record, worldSim) end

--- Called when a zone is about to hydrate (player entering). Lets a system
--- clean up any sim-only state before the zone becomes a live level — e.g.
--- stripping transient components added during ticks.
--- @param record ZoneRecord
--- @param worldSim WorldSim
function SimSystem:onZoneHydrating(record, worldSim) end

return SimSystem

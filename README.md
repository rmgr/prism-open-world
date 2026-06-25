There is exactly one WorldSim module, following the structure of the tutorial, it is stored on the Game singleton. The simulation is tied to player actions. Every player move/wait in GameLevelState:updateDecision calls Game.worldSim:advance(activeX, activeY). 

WorldSim handles hydrating/deflating zones. Deflation involves pulling the actorStorage off of the level and persisting it in WorldSim itself, then serialising the compressed level cell data to the disk. Hydration rebuild the level from the saved cells and reinjects the actors. 

While off-screen actors are dormant and controlled via SimSystems.

Currently, an actor's goal is dictated by it's Needs component.
```
		prism.components.Needs({
			safety = {
				threshold = 0.5,
				score = prism.needscomparators.HpValueComparator(),
				goal = prism.needsactions.SeekRestAction(),
			},
			hunger = {
				score = prism.needscomparators.SatietyValueComparator(),
				goal = prism.needsactions.SeekFoodAction(),
			},
			rest = {
				score = prism.needscomparators.ConstantComparator(0.3),
				goal = prism.needsactions.SeekRestAction(),
			},
		}),
```
Needs are composed at actor definition time from NeedsComparators and NeedsActions (I want to rename NeedsActions to GoalFactories at some stage). The GoalSimSystem checks if any actors have no goal, and if so calls WorldSim:pickNextGoal() to find the most pressing need and then call it's NeedsAction/GoalFactory to assign a new relevant goal.

Goal defines five functions for children to override; isAtTargetZone, resolve, complete, findLiveTarget and liveAction. 

Resolve is called by GoalSimSystem when the actor is at the target zone and handles putting the actor in the relevant position and setting up for goal execution.

Complete is a lifecycle event for anything that needs to happen when a goal is completed. For example, SeekFoodGoal updates satiety to max.

findLiveTarget returns an actor in the current zone which the goal needs to be performed upon. For example, a campsite to rest at or an actor to hunt.

liveAction returns an action to be performed by the actor during live simulation.

Actors can have a pursueGoalBehaviour node in their behaviour tree. This node handles walking to a goal point (returned by findLiveTarget), then executing an action while that goal is active (by calling liveAction()).

## Outstanding Work
I want to move the active state from the GoalSimSystem onto the goal itself so that we can handle goals that don't have a duration. For example, a hunt goal would only be finished when the target is dead. 

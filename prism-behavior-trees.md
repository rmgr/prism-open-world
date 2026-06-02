# Behavior Trees
The ```BehaviorTree``` system is composed of a set of core building blocks that work together to drive decision-making. Each turn, the entire tree is evaluated from top to bottom, ultimately producing a single action.

## Behavior Tree Nodes
### BehaviorTree.Node
This is the base class that all other behavior nodes inherit from. Custom behaviors are created by extending this class.
```
--- @class WaitBehavior : BehaviorTree.Node
local WaitBehavior = prism.BehaviorTree.Node:extend("WaitBehavior")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action
function WaitBehavior:run(level, actor, controller)
    return prism.actions.Wait(actor)
end

return WaitBehavior
```

### BehaviorTree.Root
The entry point of the tree. It evaluates its children in order and returns the first action it encounters.

### BehaviorTree.Sequence
Executes each child in order. If every child succeeds, the sequence succeeds. If any child fails, the sequence fails. If a child returns an ```Action```, execution pauses and that action is returned immediately.
```
prism.BehaviorTree.Sequence({
    prism.behaviors.FindTargetBehavior(),
    prism.behaviors.AttackBehavior(),
})
```

### BehaviorTree.Selector
Evaluates children in order, returning the first successful result. If a child produces an ```Action```, that action is returned right away. Think of it as “try this, otherwise that.”
```
prism.BehaviorTree.Selector({
    prism.behaviors.EatBehavior(),
    prism.behaviors.HuntBehavior(),
    prism.behaviors.WaitBehavior(),
})
```

### BehaviorTree.Succeeder
Always reports success, no matter what its child returns. Handy when you want to ignore failure and keep things moving.

### BehaviorTree.Conditional
Evaluates a condition function. Returns `true` if the condition passes, otherwise `false`.
```
prism.BehaviorTree.Conditional(function(level, actor, controller)
    return actor:get(prism.components.Health).current > 50
end)
```

## Using Behavior Trees in an Entity
One useful pattern is to embed a behavior tree inside a custom controller. This lets you express complex logic cleanly while still returning a single action each turn.

```
--- @class BTController : Controller
--- @overload fun() : BTController
local BTController = prism.components.Controller:extend("BTController")

function BTController:__new(tree)
    self.tree = tree
end

function BTController:act(level, actor)
    self.blackboard = {}
    return self.tree:run(level, actor, self)
    
end

return BTController
---
```

To use it, you would do something like this:
```
prism.register(prism.Component:extend("Beetle"))
prism.registerActor("Beetle", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Beetle"),
        prism.components.BTController(
            prism.BehaviorTree.Root({
                prism.behaviors.RandomMoveBehavior(),
                prism.behaviors.WaitBehavior(),
            })),
    })
end)

```

## Controller blackboard pattern
The controller includes a shared `blackboard`, a simple table used to store state between nodes. This allows different parts of the tree to communicate and build on each other’s results.

Important: The blackboard is **not automatically cleared**, so you’ll need to manage its contents intentionally.

```
--- @class FindEnemyBehavior : BehaviorTree.Node
local FindEnemyBehavior = prism.BehaviorTree.Node:extend("FindEnemyBehavior")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function FindEnemy:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)

	if not senses then
		return false
	end

	local target =
		senses:query(level, prism.components.Controller):first()
	if not target then
		return false
	end

    -- Persist the target for subsequent nodes
	controller.blackboard["target"] = target

	return true
end

return FindEnemyBehavior
```

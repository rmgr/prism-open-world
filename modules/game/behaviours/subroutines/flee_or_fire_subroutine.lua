local FleeOrFireSubroutine = prism.BehaviorTree.Sequence:extend("FleeOrFireSubroutine")

function FleeOrFireSubroutine:__new()
	return prism.BehaviorTree.Sequence.__new(self, {
		prism.BehaviorTree.Sequence({
			prism.behaviours.FindFearedBehaviour(),
			prism.BehaviorTree.Selector({
				prism.BehaviorTree.Sequence({
					prism.behaviours.RandomChanceBehaviour(10),
					prism.behaviours.CheckTargetInRangeBehaviour(2),
					prism.behaviours.SpitFireBehaviour(),
				}),
				prism.BehaviorTree.Sequence({
					prism.behaviours.CheckRoomTargetBehaviour(),
					prism.behaviours.MoveBehaviour(),
				}),
				prism.BehaviorTree.Sequence({
					prism.behaviours.FindNearestRoomNotContainingEnemyBehaviour(),
					prism.behaviours.MoveBehaviour(),
				}),
			}),
		}),
	})
end

return FleeOrFireSubroutine

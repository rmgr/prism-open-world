local HungerSubroutine = prism.BehaviorTree.Sequence:extend("HungerSubroutine")

function HungerSubroutine:__new(satietyThreshold)
	satietyThreshold = satietyThreshold or 80

	return prism.BehaviorTree.Sequence.__new(self, {
		prism.behaviours.SatietyBelowPercentageCheckBehaviour(satietyThreshold),
		prism.BehaviorTree.Selector({
			-- Try to find actual food first
			prism.BehaviorTree.Sequence({
				prism.behaviours.FindEdibleBehaviour(),
				prism.BehaviorTree.Selector({
					prism.BehaviorTree.Sequence({
						prism.behaviours.CheckTargetInRangeBehaviour(0),
						prism.behaviours.EatBehaviour(),
					}),
					prism.behaviours.MoveBehaviour(0),
				}),
			}),
			-- If no food found, hunt anyone
			prism.BehaviorTree.Sequence({
				prism.behaviours.FindActorBehaviour({}),
				prism.BehaviorTree.Selector({
					prism.BehaviorTree.Sequence({
						prism.behaviours.CheckTargetInRangeBehaviour(1),
						prism.behaviours.AttackBehaviour(),
					}),
					prism.behaviours.MoveBehaviour(),
				}),
			}),
		}),
	})
end

return HungerSubroutine

local HuntSubroutine = prism.BehaviorTree.Selector:extend("HuntSubroutine")

function HuntSubroutine:__new(hpCutoffThreshold, range, aggroRange)
	hpCutoffThreshold = hpCutoffThreshold or 34
	range = range or 1
	aggroRange = aggroRange or 99

	return prism.BehaviorTree.Selector.__new(self, {
		prism.BehaviorTree.Sequence({
			prism.behaviours.HPBelowPercentageCheckBehaviour(hpCutoffThreshold),
			prism.behaviours.FearBehaviour(),
		}),
		prism.BehaviorTree.Sequence({
			prism.behaviours.FindActorBehaviour({ prism.relations.FoeRelation }),
			prism.BehaviorTree.Selector({
				prism.BehaviorTree.Sequence({
					prism.behaviours.CheckTargetInRangeBehaviour(range),
					prism.behaviours.AttackBehaviour(),
				}),
				prism.BehaviorTree.Sequence({
					prism.behaviours.CheckTargetInRangeBehaviour(aggroRange),
					prism.behaviours.MoveBehaviour(),
				}),
			}),
		}),
	})
end

return HuntSubroutine

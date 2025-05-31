extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    if actor.munitions.active_munition != null:
        if actor.munitions.loaded_munitions[actor.munitions.active_munition] > 1:
            return SUCCESS
    return FAILURE
